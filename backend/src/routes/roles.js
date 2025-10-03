const express = require('express');
const { body, validationResult } = require('express-validator');
const Role = require('../models/Role');
const User = require('../models/User');
const Tenant = require('../models/Tenant');
const { authenticate } = require('../middleware/auth');
const { checkPermission } = require('../middleware/rbac');
const { AppError, asyncHandler } = require('../middleware/errorHandler');
const { createLogger } = require('../config/logging');
const casbinService = require('../config/casbin');

const router = express.Router();
const logger = createLogger('roles');

// Validation rules
const createRoleValidation = [
  body('name').notEmpty().trim().withMessage('Role name is required'),
  body('description').optional().trim().isLength({ max: 500 }).withMessage('Description too long'),
  body('roleType').isIn(['global', 'tenant', 'internal']).withMessage('Invalid role type'),
  body('globalRole').optional().isIn(['tech', 'admin', 'customer_admin', 'vendor_admin']),
  body('tenantType').optional().isIn(['admin', 'customer', 'vendor']),
  body('permissions').isArray().withMessage('Permissions must be an array'),
  body('permissions.*.resource').notEmpty().withMessage('Permission resource is required'),
  body('permissions.*.actions').isArray().withMessage('Permission actions must be an array'),
  body('maritimeFeatures').optional().isObject()
];

const updateRoleValidation = [
  body('name').optional().notEmpty().trim(),
  body('description').optional().trim().isLength({ max: 500 }),
  body('permissions').optional().isArray(),
  body('permissions.*.resource').optional().notEmpty(),
  body('permissions.*.actions').optional().isArray(),
  body('maritimeFeatures').optional().isObject()
];

/**
 * @swagger
 * /api/roles:
 *   get:
 *     summary: Get all roles (filtered by user permissions)
 *     tags: [Roles]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Roles retrieved successfully
 *       401:
 *         description: Authentication required
 *       403:
 *         description: Insufficient permissions
 */
router.get('/', authenticate, checkPermission('/api/roles', 'GET'), asyncHandler(async (req, res) => {
  const user = req.user;
  const tenant = req.tenant;
  
  let roles = [];
  
  // Tech users can see all roles
  if (user.isTech()) {
    roles = await Role.find({ isActive: true }).populate('tenantId', 'name tenantType');
  }
  // Admin users can see admin tenant roles and global roles
  else if (user.isAdmin()) {
    roles = await Role.find({
      $or: [
        { roleType: 'global' },
        { tenantId: tenant._id, roleType: 'tenant' },
        { tenantId: tenant._id, roleType: 'internal' }
      ],
      isActive: true
    }).populate('tenantId', 'name tenantType');
  }
  // Customer/Vendor admins can see their tenant roles
  else if (user.isCustomerAdmin() || user.isVendorAdmin()) {
    roles = await Role.find({
      tenantId: tenant._id,
      isActive: true
    }).populate('tenantId', 'name tenantType');
  }
  // Regular users can only see their assigned roles
  else {
    const userRoles = await user.getAllRoles();
    roles = userRoles.filter(role => role.isActive);
  }

  res.json({
    success: true,
    count: roles.length,
    roles
  });
}));

/**
 * @swagger
 * /api/roles:
 *   post:
 *     summary: Create a new role
 *     tags: [Roles]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - roleType
 *               - permissions
 *             properties:
 *               name:
 *                 type: string
 *               description:
 *                 type: string
 *               roleType:
 *                 type: string
 *                 enum: [global, tenant, internal]
 *               globalRole:
 *                 type: string
 *                 enum: [tech, admin, customer_admin, vendor_admin]
 *               tenantType:
 *                 type: string
 *                 enum: [admin, customer, vendor]
 *               permissions:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     resource:
 *                       type: string
 *                     actions:
 *                       type: array
 *                       items:
 *                         type: string
 *               maritimeFeatures:
 *                 type: object
 *     responses:
 *       201:
 *         description: Role created successfully
 *       400:
 *         description: Validation error
 *       403:
 *         description: Insufficient permissions
 */
router.post('/', authenticate, checkPermission('/api/roles', 'POST'), createRoleValidation, asyncHandler(async (req, res) => {
  // Check validation errors
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array()
    });
  }

  const user = req.user;
  const tenant = req.tenant;
  const {
    name,
    description,
    roleType,
    globalRole,
    tenantType,
    permissions,
    maritimeFeatures
  } = req.body;

  // Permission checks based on user type
  if (roleType === 'global' && !user.isTech()) {
    return res.status(403).json({
      success: false,
      message: 'Only tech users can create global roles'
    });
  }

  if (roleType === 'tenant' && !user.isTech() && !user.isAdmin()) {
    return res.status(403).json({
      success: false,
      message: 'Only tech and admin users can create tenant roles'
    });
  }

  if (roleType === 'internal' && !user.isTech() && !user.isAdmin() && !user.isCustomerAdmin() && !user.isVendorAdmin()) {
    return res.status(403).json({
      success: false,
      message: 'Only admin users can create internal roles'
    });
  }

  // Check if role name already exists in the same scope
  const existingRole = await Role.findOne({
    name,
    tenantId: roleType === 'global' ? null : tenant._id,
    isActive: true
  });

  if (existingRole) {
    return res.status(400).json({
      success: false,
      message: 'Role name already exists in this scope'
    });
  }

  // Create the role
  const role = new Role({
    name,
    description,
    roleType,
    globalRole: roleType === 'global' ? globalRole : null,
    tenantId: roleType === 'global' ? null : tenant._id,
    tenantType: roleType === 'tenant' ? tenantType : null,
    permissions,
    maritimeFeatures: maritimeFeatures || {},
    createdBy: user._id
  });

  await role.save();

  // Add role to Casbin if it's a global role
  if (roleType === 'global' && globalRole) {
    // Global roles are handled by the default policies
    logger.info(`✅ Created global role: ${globalRole}`);
  }

  logger.info(`✅ Created ${roleType} role: ${name} by user ${user._id}`);

  res.status(201).json({
    success: true,
    message: 'Role created successfully',
    role
  });
}));

/**
 * @swagger
 * /api/roles/{id}:
 *   get:
 *     summary: Get role by ID
 *     tags: [Roles]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Role retrieved successfully
 *       404:
 *         description: Role not found
 */
router.get('/:id', authenticate, checkPermission('/api/roles/*', 'GET'), asyncHandler(async (req, res) => {
  const role = await Role.findById(req.params.id).populate('tenantId', 'name tenantType');
  
  if (!role) {
    return res.status(404).json({
      success: false,
      message: 'Role not found'
    });
  }

  // Check if user has permission to view this role
  const user = req.user;
  if (!user.isTech() && role.tenantId && role.tenantId._id.toString() !== req.tenant._id.toString()) {
    return res.status(403).json({
      success: false,
      message: 'Access denied: Cannot view roles from other tenants'
    });
  }

  res.json({
    success: true,
    role
  });
}));

/**
 * @swagger
 * /api/roles/{id}:
 *   put:
 *     summary: Update role
 *     tags: [Roles]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               description:
 *                 type: string
 *               permissions:
 *                 type: array
 *               maritimeFeatures:
 *                 type: object
 *     responses:
 *       200:
 *         description: Role updated successfully
 *       404:
 *         description: Role not found
 *       403:
 *         description: Insufficient permissions
 */
router.put('/:id', authenticate, checkPermission('/api/roles/*', 'PUT'), updateRoleValidation, asyncHandler(async (req, res) => {
  // Check validation errors
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array()
    });
  }

  const role = await Role.findById(req.params.id);
  
  if (!role) {
    return res.status(404).json({
      success: false,
      message: 'Role not found'
    });
  }

  // Check permissions
  const user = req.user;
  if (!user.isTech() && role.tenantId && role.tenantId.toString() !== req.tenant._id.toString()) {
    return res.status(403).json({
      success: false,
      message: 'Access denied: Cannot modify roles from other tenants'
    });
  }

  // Prevent modification of system roles
  if (role.isSystemRole && !user.isTech()) {
    return res.status(403).json({
      success: false,
      message: 'Access denied: Cannot modify system roles'
    });
  }

  // Update role
  const updatedRole = await Role.findByIdAndUpdate(
    req.params.id,
    { $set: req.body },
    { new: true, runValidators: true }
  );

  logger.info(`✅ Updated role: ${updatedRole.name} by user ${user._id}`);

  res.json({
    success: true,
    message: 'Role updated successfully',
    role: updatedRole
  });
}));

/**
 * @swagger
 * /api/roles/{id}:
 *   delete:
 *     summary: Delete role
 *     tags: [Roles]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Role deleted successfully
 *       404:
 *         description: Role not found
 *       403:
 *         description: Insufficient permissions
 */
router.delete('/:id', authenticate, checkPermission('/api/roles/*', 'DELETE'), asyncHandler(async (req, res) => {
  const role = await Role.findById(req.params.id);
  
  if (!role) {
    return res.status(404).json({
      success: false,
      message: 'Role not found'
    });
  }

  // Check permissions
  const user = req.user;
  if (!user.isTech() && role.tenantId && role.tenantId.toString() !== req.tenant._id.toString()) {
    return res.status(403).json({
      success: false,
      message: 'Access denied: Cannot delete roles from other tenants'
    });
  }

  // Prevent deletion of system roles
  if (role.isSystemRole && !user.isTech()) {
    return res.status(403).json({
      success: false,
      message: 'Access denied: Cannot delete system roles'
    });
  }

  // Check if role is assigned to any users
  const usersWithRole = await User.find({
    $or: [
      { globalRole: role.globalRole },
      { tenantRoles: role._id },
      { internalRoles: role._id }
    ]
  });

  if (usersWithRole.length > 0) {
    return res.status(400).json({
      success: false,
      message: `Cannot delete role: ${usersWithRole.length} user(s) are assigned to this role`
    });
  }

  // Soft delete the role
  await Role.findByIdAndUpdate(req.params.id, { isActive: false });

  logger.info(`✅ Deleted role: ${role.name} by user ${user._id}`);

  res.json({
    success: true,
    message: 'Role deleted successfully'
  });
}));

/**
 * @swagger
 * /api/roles/{id}/assign:
 *   post:
 *     summary: Assign role to user
 *     tags: [Roles]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - userId
 *             properties:
 *               userId:
 *                 type: string
 *     responses:
 *       200:
 *         description: Role assigned successfully
 *       404:
 *         description: Role or user not found
 */
router.post('/:id/assign', authenticate, checkPermission('/api/roles/*', 'POST'), asyncHandler(async (req, res) => {
  const { userId } = req.body;
  
  if (!userId) {
    return res.status(400).json({
      success: false,
      message: 'User ID is required'
    });
  }

  const role = await Role.findById(req.params.id);
  const user = await User.findById(userId);
  
  if (!role) {
    return res.status(404).json({
      success: false,
      message: 'Role not found'
    });
  }

  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'User not found'
    });
  }

  // Check permissions
  const currentUser = req.user;
  if (!currentUser.isTech() && role.tenantId && role.tenantId.toString() !== req.tenant._id.toString()) {
    return res.status(403).json({
      success: false,
      message: 'Access denied: Cannot assign roles from other tenants'
    });
  }

  // Assign role based on type
  if (role.roleType === 'global') {
    user.globalRole = role.globalRole;
  } else if (role.roleType === 'tenant') {
    if (!user.tenantRoles.includes(role._id)) {
      user.tenantRoles.push(role._id);
    }
  } else if (role.roleType === 'internal') {
    if (!user.internalRoles.includes(role._id)) {
      user.internalRoles.push(role._id);
    }
  }

  await user.save();

  // Add to Casbin
  await casbinService.addUserRole(userId, role.name, req.tenant._id.toString());

  logger.info(`✅ Assigned role ${role.name} to user ${userId} by ${currentUser._id}`);

  res.json({
    success: true,
    message: 'Role assigned successfully'
  });
}));

/**
 * @swagger
 * /api/roles/{id}/unassign:
 *   post:
 *     summary: Unassign role from user
 *     tags: [Roles]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - userId
 *             properties:
 *               userId:
 *                 type: string
 *     responses:
 *       200:
 *         description: Role unassigned successfully
 */
router.post('/:id/unassign', authenticate, checkPermission('/api/roles/*', 'POST'), asyncHandler(async (req, res) => {
  const { userId } = req.body;
  
  if (!userId) {
    return res.status(400).json({
      success: false,
      message: 'User ID is required'
    });
  }

  const role = await Role.findById(req.params.id);
  const user = await User.findById(userId);
  
  if (!role || !user) {
    return res.status(404).json({
      success: false,
      message: 'Role or user not found'
    });
  }

  // Check permissions
  const currentUser = req.user;
  if (!currentUser.isTech() && role.tenantId && role.tenantId.toString() !== req.tenant._id.toString()) {
    return res.status(403).json({
      success: false,
      message: 'Access denied: Cannot unassign roles from other tenants'
    });
  }

  // Unassign role based on type
  if (role.roleType === 'global') {
    user.globalRole = null;
  } else if (role.roleType === 'tenant') {
    user.tenantRoles = user.tenantRoles.filter(roleId => roleId.toString() !== role._id.toString());
  } else if (role.roleType === 'internal') {
    user.internalRoles = user.internalRoles.filter(roleId => roleId.toString() !== role._id.toString());
  }

  await user.save();

  // Remove from Casbin
  await casbinService.removeUserRole(userId, role.name, req.tenant._id.toString());

  logger.info(`✅ Unassigned role ${role.name} from user ${userId} by ${currentUser._id}`);

  res.json({
    success: true,
    message: 'Role unassigned successfully'
  });
}));

module.exports = router;





