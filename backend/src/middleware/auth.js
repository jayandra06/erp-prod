const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Tenant = require('../models/Tenant');
const { AppError, asyncHandler } = require('./errorHandler');
const { createLogger } = require('../config/logging');

const logger = createLogger('auth');

// Generate JWT token
const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE || '7d'
  });
};

// Generate refresh token
const generateRefreshToken = (userId) => {
  return jwt.sign({ userId, type: 'refresh' }, process.env.JWT_REFRESH_SECRET, {
    expiresIn: process.env.JWT_REFRESH_EXPIRE || '30d'
  });
};

// Set HttpOnly cookies
const setTokenCookies = (res, accessToken, refreshToken) => {
  const cookieOptions = {
    httpOnly: process.env.COOKIE_HTTP_ONLY === 'true',
    secure: process.env.COOKIE_SECURE === 'true',
    sameSite: process.env.COOKIE_SAME_SITE || 'strict',
    domain: process.env.COOKIE_DOMAIN,
    maxAge: 7 * 24 * 60 * 60 * 1000 // 7 days
  };

  const refreshCookieOptions = {
    ...cookieOptions,
    maxAge: 30 * 24 * 60 * 60 * 1000 // 30 days
  };

  res.cookie('accessToken', accessToken, cookieOptions);
  res.cookie('refreshToken', refreshToken, refreshCookieOptions);
};

// Clear token cookies
const clearTokenCookies = (res) => {
  const cookieOptions = {
    httpOnly: process.env.COOKIE_HTTP_ONLY === 'true',
    secure: process.env.COOKIE_SECURE === 'true',
    sameSite: process.env.COOKIE_SAME_SITE || 'strict',
    domain: process.env.COOKIE_DOMAIN
  };

  res.clearCookie('accessToken', cookieOptions);
  res.clearCookie('refreshToken', cookieOptions);
};

// Authentication middleware
const authenticate = asyncHandler(async (req, res, next) => {
  let token;

  // Check for token in Authorization header
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }
  // Check for token in HttpOnly cookies
  else if (req.cookies && req.cookies.accessToken) {
    token = req.cookies.accessToken;
  }

  if (!token) {
    return next(new AppError('Access denied. No token provided.', 401));
  }

  try {
    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Get user from database
    const user = await User.findById(decoded.userId)
      .populate('tenantId')
      .populate('roles')
      .select('-password');

    if (!user) {
      return next(new AppError('Token is valid but user no longer exists.', 401));
    }

    // Check if user is active
    if (!user.isActive) {
      return next(new AppError('User account is deactivated.', 401));
    }

    // Check if tenant is active
    if (user.tenantId && !user.tenantId.isActive) {
      return next(new AppError('Tenant account is not active.', 403));
    }

    // Add user and tenant to request object
    req.user = user;
    req.tenant = user.tenantId;

    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return next(new AppError('Invalid token.', 401));
    }
    if (error.name === 'TokenExpiredError') {
      return next(new AppError('Token expired.', 401));
    }
    return next(new AppError('Token verification failed.', 401));
  }
});

// Refresh token middleware
const refreshToken = asyncHandler(async (req, res, next) => {
  const refreshToken = req.cookies.refreshToken;

  if (!refreshToken) {
    return next(new AppError('No refresh token provided.', 401));
  }

  try {
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    
    if (decoded.type !== 'refresh') {
      return next(new AppError('Invalid refresh token.', 401));
    }

    const user = await User.findById(decoded.userId).select('-password');
    
    if (!user || !user.isActive) {
      return next(new AppError('User not found or inactive.', 401));
    }

    // Generate new tokens
    const newAccessToken = generateToken(user._id);
    const newRefreshToken = generateRefreshToken(user._id);

    // Set new cookies
    setTokenCookies(res, newAccessToken, newRefreshToken);

    res.json({
      message: 'Token refreshed successfully',
      token: newAccessToken
    });
  } catch (error) {
    return next(new AppError('Invalid refresh token.', 401));
  }
});

// Authorization middleware (role-based)
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return next(new AppError('Access denied. Please log in.', 401));
    }

    if (!roles.includes(req.user.userType)) {
      return next(new AppError('Access denied. Insufficient permissions.', 403));
    }

    next();
  };
};

// Tenant isolation middleware
const tenantIsolation = (req, res, next) => {
  if (!req.user || !req.tenant) {
    return next(new AppError('Tenant context required.', 400));
  }

  // Add tenant filter to request
  req.tenantFilter = { tenantId: req.tenant._id };
  next();
};

// Optional authentication (for public endpoints that can benefit from user context)
const optionalAuth = asyncHandler(async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  } else if (req.cookies && req.cookies.accessToken) {
    token = req.cookies.accessToken;
  }

  if (token) {
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.userId)
        .populate('tenantId')
        .select('-password');

      if (user && user.isActive && user.tenantId && user.tenantId.isActive) {
        req.user = user;
        req.tenant = user.tenantId;
        req.tenantFilter = { tenantId: req.tenant._id };
      }
    } catch (error) {
      // Ignore token errors for optional auth
      logger.debug('Optional auth token verification failed:', error.message);
    }
  }

  next();
});

// Logout middleware
const logout = (req, res, next) => {
  clearTokenCookies(res);
  res.json({ message: 'Logged out successfully' });
};

module.exports = {
  generateToken,
  generateRefreshToken,
  setTokenCookies,
  clearTokenCookies,
  authenticate,
  refreshToken,
  authorize,
  tenantIsolation,
  optionalAuth,
  logout
};
