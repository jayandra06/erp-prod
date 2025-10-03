const express = require('express');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const Tenant = require('../models/Tenant');
const { 
  authenticate, 
  generateToken, 
  generateRefreshToken, 
  setTokenCookies, 
  clearTokenCookies,
  logout,
  refreshToken 
} = require('../middleware/auth');
const { autoAssignUserRole, ensureTenantContext } = require('../middleware/rbac');
const { AppError, asyncHandler } = require('../middleware/errorHandler');
const { createLogger } = require('../config/logging');

const router = express.Router();
const logger = createLogger('auth');

// Validation rules
const registerValidation = [
  body('email').isEmail().normalizeEmail().withMessage('Please provide a valid email'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  body('firstName').notEmpty().trim().withMessage('First name is required'),
  body('lastName').notEmpty().trim().withMessage('Last name is required'),
  body('userType').isIn(['admin', 'technical', 'customer', 'vendor']).withMessage('Invalid user type'),
  body('companyName').optional().trim().isLength({ max: 100 }).withMessage('Company name too long'),
  body('phone').optional().isMobilePhone().withMessage('Please provide a valid phone number'),
  body('vesselType').optional().isIn(['cargo', 'tanker', 'container', 'bulk_carrier', 'cruise', 'fishing', 'offshore', 'other']),
  body('preferredCurrency').optional().isIn(['USD', 'EUR', 'GBP', 'JPY', 'CNY', 'INR'])
];

const loginValidation = [
  body('email').isEmail().normalizeEmail().withMessage('Please provide a valid email'),
  body('password').notEmpty().withMessage('Password is required'),
  body('userType').isIn(['admin', 'technical', 'customer', 'vendor']).withMessage('Invalid user type')
];

/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     summary: Register a new user
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *               - firstName
 *               - lastName
 *               - userType
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *               password:
 *                 type: string
 *                 minLength: 6
 *               firstName:
 *                 type: string
 *               lastName:
 *                 type: string
 *               userType:
 *                 type: string
 *                 enum: [admin, technical, customer, vendor]
 *               companyName:
 *                 type: string
 *               phone:
 *                 type: string
 *               vesselType:
 *                 type: string
 *                 enum: [cargo, tanker, container, bulk_carrier, cruise, fishing, offshore, other]
 *               preferredCurrency:
 *                 type: string
 *                 enum: [USD, EUR, GBP, JPY, CNY, INR]
 *     responses:
 *       201:
 *         description: User registered successfully
 *       400:
 *         description: Validation error or user already exists
 *       500:
 *         description: Server error
 */
router.post('/register', registerValidation, asyncHandler(async (req, res) => {
  // Check validation errors
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      message: 'Validation failed',
      errors: errors.array()
    });
  }

  const { 
    email, 
    password, 
    firstName, 
    lastName, 
    userType, 
    companyName, 
    phone, 
    vesselType,
    preferredCurrency 
  } = req.body;

  // Check if user already exists
  const existingUser = await User.findOne({ email: email.toLowerCase() });
  if (existingUser) {
    return res.status(400).json({ message: 'User already exists' });
  }

  let tenant;

  // Handle tenant creation or assignment
  if (userType === 'admin') {
    // Create new tenant for admin users
    tenant = new Tenant({
      name: companyName || `${firstName} ${lastName} Company`,
      slug: companyName ? 
        companyName.toLowerCase().replace(/[^a-z0-9]/g, '-').replace(/-+/g, '-') :
        `${firstName}-${lastName}-company`.toLowerCase(),
      owner: null, // Will be set after user creation
      companyInfo: {
        registrationNumber: '',
        taxId: '',
        address: {
          country: 'Global'
        },
        phone,
        email: email.toLowerCase()
      }
    });
    await tenant.save();
  } else {
    // For non-admin users, they need to be invited to an existing tenant
    return res.status(400).json({ 
      message: 'Non-admin users must be invited by an existing tenant admin' 
    });
  }

  // Create user
  const user = new User({
    email: email.toLowerCase(),
    password,
    firstName,
    lastName,
    userType,
    tenantId: tenant._id,
    companyName,
    phone,
    vesselType: vesselType || 'other',
    preferredCurrency: preferredCurrency || 'USD',
    isActive: true,
    isVerified: userType === 'admin' // Auto-verify admin users
  });

  await user.save();

  // Update tenant owner
  if (userType === 'admin') {
    tenant.owner = user._id;
    await tenant.save();
  }

  // Generate tokens
  const accessToken = generateToken(user._id);
  const refreshTokenValue = generateRefreshToken(user._id);

  // Set HttpOnly cookies
  setTokenCookies(res, accessToken, refreshTokenValue);

  // Auto-assign role
  await autoAssignUserRole(req, res, () => {});

  logger.info(`✅ New user registered: ${email} (${userType}) in tenant ${tenant.name}`);

  res.status(201).json({
    message: 'User registered successfully',
    token: accessToken,
    user: {
      id: user._id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      fullName: user.fullName,
      userType: user.userType,
      companyName: user.companyName,
      vesselType: user.vesselType,
      preferredCurrency: user.preferredCurrency,
      isVerified: user.isVerified,
      tenant: {
        id: tenant._id,
        name: tenant.name,
        slug: tenant.slug
      }
    }
  });
}));

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     summary: Login user
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *               - userType
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *               password:
 *                 type: string
 *               userType:
 *                 type: string
 *                 enum: [admin, technical, customer, vendor]
 *     responses:
 *       200:
 *         description: Login successful
 *       401:
 *         description: Invalid credentials
 *       403:
 *         description: Account locked or tenant inactive
 */
router.post('/login', loginValidation, ensureTenantContext, autoAssignUserRole, asyncHandler(async (req, res) => {
  // Check validation errors
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      message: 'Validation failed',
      errors: errors.array()
    });
  }

  const { email, password, userType } = req.body;

  // Find user (include password field)
  const user = await User.findOne({ 
    email: email.toLowerCase(),
    userType 
  }).select('+password').populate('tenantId');

  if (!user) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }

  // Check if account is locked
  if (user.isLocked) {
    return res.status(401).json({ 
      message: 'Account is temporarily locked due to too many failed login attempts' 
    });
  }

  // Check password
  const isMatch = await user.comparePassword(password);
  if (!isMatch) {
    await user.incLoginAttempts();
    return res.status(401).json({ message: 'Invalid credentials' });
  }

  // Check if user is active
  if (!user.isActive) {
    return res.status(401).json({ message: 'Account is deactivated' });
  }

  // Check tenant status
  if (!user.tenantId || !user.tenantId.isActive || user.tenantId.subscription.status === 'suspended') {
    return res.status(403).json({ message: 'Tenant account is not active' });
  }

  // Reset login attempts and update last login
  await user.resetLoginAttempts();

  // Generate tokens
  const accessToken = generateToken(user._id);
  const refreshTokenValue = generateRefreshToken(user._id);

  // Set HttpOnly cookies
  setTokenCookies(res, accessToken, refreshTokenValue);

  logger.info(`✅ User logged in: ${email} (${userType}) in tenant ${user.tenantId.name}`);

  res.json({
    message: 'Login successful',
    token: accessToken,
    user: {
      id: user._id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      fullName: user.fullName,
      userType: user.userType,
      companyName: user.companyName,
      vesselType: user.vesselType,
      preferredCurrency: user.preferredCurrency,
      isVerified: user.isVerified,
      lastLogin: user.lastLogin,
      tenant: {
        id: user.tenantId._id,
        name: user.tenantId.name,
        slug: user.tenantId.slug,
        subscription: user.tenantId.subscription
      }
    }
  });
}));

/**
 * @swagger
 * /api/auth/refresh:
 *   post:
 *     summary: Refresh access token
 *     tags: [Authentication]
 *     responses:
 *       200:
 *         description: Token refreshed successfully
 *       401:
 *         description: Invalid refresh token
 */
router.post('/refresh', refreshToken);

/**
 * @swagger
 * /api/auth/logout:
 *   post:
 *     summary: Logout user
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Logged out successfully
 */
router.post('/logout', authenticate, logout);

/**
 * @swagger
 * /api/auth/me:
 *   get:
 *     summary: Get current user profile
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User profile retrieved successfully
 *       401:
 *         description: Authentication required
 */
router.get('/me', authenticate, asyncHandler(async (req, res) => {
  res.json({
    user: {
      id: req.user._id,
      email: req.user.email,
      firstName: req.user.firstName,
      lastName: req.user.lastName,
      fullName: req.user.fullName,
      userType: req.user.userType,
      companyName: req.user.companyName,
      jobTitle: req.user.jobTitle,
      department: req.user.department,
      vesselType: req.user.vesselType,
      preferredCurrency: req.user.preferredCurrency,
      isVerified: req.user.isVerified,
      lastLogin: req.user.lastLogin,
      preferences: req.user.preferences,
      tenant: {
        id: req.tenant._id,
        name: req.tenant.name,
        slug: req.tenant.slug,
        subscription: req.tenant.subscription,
        features: req.tenant.features
      }
    }
  });
}));

/**
 * @swagger
 * /api/auth/forgot-password:
 *   post:
 *     summary: Request password reset
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *     responses:
 *       200:
 *         description: Password reset email sent
 *       404:
 *         description: User not found
 */
router.post('/forgot-password', asyncHandler(async (req, res) => {
  const { email } = req.body;

  const user = await User.findOne({ email: email.toLowerCase() });
  if (!user) {
    return res.status(404).json({ message: 'User not found' });
  }

  // Generate reset token (in a real app, you'd send this via email)
  const resetToken = jwt.sign(
    { userId: user._id, type: 'password-reset' },
    process.env.JWT_SECRET,
    { expiresIn: '1h' }
  );

  user.resetPasswordToken = resetToken;
  user.resetPasswordExpire = Date.now() + 60 * 60 * 1000; // 1 hour
  await user.save();

  // TODO: Send email with reset link
  logger.info(`Password reset requested for user: ${email}`);

  res.json({
    message: 'Password reset email sent',
    resetToken // Remove this in production
  });
}));

module.exports = router;
