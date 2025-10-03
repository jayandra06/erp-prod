const casbinService = require('../config/casbin');
const { createLogger } = require('../config/logging');
const { AppError, asyncHandler } = require('./errorHandler');

const logger = createLogger('rbac');

/**
 * Initialize Casbin RBAC system
 */
const initializeRBAC = async () => {
  try {
    await casbinService.initEnforcer();
    logger.info('🔐 Maritime Procurement RBAC system initialized successfully');
  } catch (error) {
    logger.error('Failed to initialize RBAC system:', error);
    throw error;
  }
};

/**
 * Check permission using Casbin
 * @param {string} resource - The resource being accessed (e.g., '/api/users')
 * @param {string} action - The action being performed (e.g., 'GET', 'POST')
 */
const checkPermission = (resource, action) => {
  return asyncHandler(async (req, res, next) => {
    try {
      // Ensure user is authenticated
      if (!req.user || !req.tenant) {
        return next(new AppError('Authentication required', 401));
      }

      const userId = req.user._id.toString();
      const tenantId = req.tenant._id.toString();

      // Check permission using Casbin
      const hasPermission = await casbinService.checkPermission(
        userId,
        resource,
        action,
        tenantId
      );

      if (!hasPermission) {
        logger.warn(`Access denied for user ${userId} to ${resource}:${action} in tenant ${tenantId}`);
        return next(new AppError(
          'Access denied: Insufficient permissions',
          403
        ));
      }

      logger.debug(`Permission granted for user ${userId} to ${resource}:${action} in tenant ${tenantId}`);
      next();
    } catch (error) {
      logger.error('Permission check error:', error);
      next(new AppError('Permission check failed', 500));
    }
  });
};

/**
 * Dynamic permission checker that uses the actual request path and method
 */
const checkDynamicPermission = () => {
  return asyncHandler(async (req, res, next) => {
    try {
      if (!req.user || !req.tenant) {
        return next(new AppError('Authentication required', 401));
      }

      const userId = req.user._id.toString();
      const tenantId = req.tenant._id.toString();
      const resource = req.path;
      const action = req.method;

      const hasPermission = await casbinService.checkPermission(
        userId,
        resource,
        action,
        tenantId
      );

      if (!hasPermission) {
        logger.warn(`Dynamic access denied for user ${userId} to ${resource}:${action} in tenant ${tenantId}`);
        return next(new AppError(
          'Access denied: Insufficient permissions',
          403
        ));
      }

      next();
    } catch (error) {
      logger.error('Dynamic permission check error:', error);
      next(new AppError('Permission check failed', 500));
    }
  });
};

/**
 * Portal-specific access control
 * Ensures users can only access their designated portal
 */
const checkPortalAccess = (allowedPortals) => {
  return (req, res, next) => {
    if (!req.user) {
      return next(new AppError('Authentication required', 401));
    }

    const userPortal = req.user.userType;
    
    if (!allowedPortals.includes(userPortal)) {
      logger.warn(`Portal access denied for user ${req.user._id} (${userPortal}) to ${allowedPortals.join(', ')}`);
      return next(new AppError(
        `Access denied: This portal is restricted to ${allowedPortals.join(', ')} users`,
        403
      ));
    }

    next();
  };
};

/**
 * Maritime Procurement specific permission checks
 */
const checkMaritimePermission = (permission) => {
  return asyncHandler(async (req, res, next) => {
    try {
      if (!req.user || !req.tenant) {
        return next(new AppError('Authentication required', 401));
      }

      const userId = req.user._id.toString();
      const tenantId = req.tenant._id.toString();

      // Maritime-specific resource mapping
      const resourceMap = {
        'rfq.create': '/api/technical/rfq',
        'rfq.read': '/api/technical/rfq',
        'rfq.update': '/api/technical/rfq',
        'rfq.delete': '/api/technical/rfq',
        'quote.create': '/api/vendors/quotes',
        'quote.read': '/api/vendors/quotes',
        'quote.update': '/api/vendors/quotes',
        'quote.delete': '/api/vendors/quotes',
        'user.manage': '/api/users',
        'tenant.manage': '/api/tenants'
      };

      const resource = resourceMap[permission] || `/${permission}`;
      const action = req.method;

      const hasPermission = await casbinService.checkPermission(
        userId,
        resource,
        action,
        tenantId
      );

      if (!hasPermission) {
        logger.warn(`Maritime permission denied for user ${userId} to ${permission} in tenant ${tenantId}`);
        return next(new AppError(
          `Access denied: Insufficient permissions for ${permission}`,
          403
        ));
      }

      next();
    } catch (error) {
      logger.error('Maritime permission check error:', error);
      next(new AppError('Permission check failed', 500));
    }
  });
};

/**
 * Auto-assign roles based on user type and global role
 */
const autoAssignUserRole = asyncHandler(async (req, res, next) => {
  try {
    if (!req.user || !req.tenant) {
      return next();
    }

    const userId = req.user._id.toString();
    const tenantId = req.tenant._id.toString();
    const user = req.user;

    // If user has a global role, assign it
    if (user.globalRole) {
      const existingRoles = await casbinService.getUserRoles(userId, tenantId);
      if (!existingRoles.includes(user.globalRole)) {
        await casbinService.addUserRole(userId, user.globalRole, tenantId);
        logger.info(`✅ Auto-assigned global role ${user.globalRole} to user ${userId}`);
      }
    } else {
      // Legacy mapping for users without global roles
      const roleMapping = {
        'admin': 'admin',
        'technical': 'tech',
        'customer': 'customer_admin',
        'vendor': 'vendor_admin'
      };

      const role = roleMapping[user.userType];
      if (role) {
        const existingRoles = await casbinService.getUserRoles(userId, tenantId);
        if (!existingRoles.includes(role)) {
          await casbinService.addUserRole(userId, role, tenantId);
          logger.info(`✅ Auto-assigned legacy role ${role} to user ${userId} in tenant ${tenantId}`);
        }
      }
    }

    // Assign tenant and internal roles
    if (user.tenantRoles && user.tenantRoles.length > 0) {
      for (const roleId of user.tenantRoles) {
        const role = await mongoose.model('Role').findById(roleId);
        if (role) {
          const existingRoles = await casbinService.getUserRoles(userId, tenantId);
          if (!existingRoles.includes(role.name)) {
            await casbinService.addUserRole(userId, role.name, tenantId);
            logger.info(`✅ Auto-assigned tenant role ${role.name} to user ${userId}`);
          }
        }
      }
    }

    if (user.internalRoles && user.internalRoles.length > 0) {
      for (const roleId of user.internalRoles) {
        const role = await mongoose.model('Role').findById(roleId);
        if (role) {
          const existingRoles = await casbinService.getUserRoles(userId, tenantId);
          if (!existingRoles.includes(role.name)) {
            await casbinService.addUserRole(userId, role.name, tenantId);
            logger.info(`✅ Auto-assigned internal role ${role.name} to user ${userId}`);
          }
        }
      }
    }

    next();
  } catch (error) {
    logger.error('Auto-assign role error:', error);
    next(); // Continue even if role assignment fails
  }
});

/**
 * Check if user is tech (global super admin)
 */
const checkTechAccess = () => {
  return (req, res, next) => {
    if (!req.user) {
      return next(new AppError('Authentication required', 401));
    }

    if (!req.user.isTech()) {
      logger.warn(`Tech access denied for user ${req.user._id} (${req.user.userType})`);
      return next(new AppError(
        'Access denied: Tech portal access required',
        403
      ));
    }

    next();
  };
};

/**
 * Check if user is admin (platform admin)
 */
const checkAdminAccess = () => {
  return (req, res, next) => {
    if (!req.user) {
      return next(new AppError('Authentication required', 401));
    }

    if (!req.user.isAdmin()) {
      logger.warn(`Admin access denied for user ${req.user._id} (${req.user.userType})`);
      return next(new AppError(
        'Access denied: Admin portal access required',
        403
      ));
    }

    next();
  };
};

/**
 * Check if user is customer admin
 */
const checkCustomerAdminAccess = () => {
  return (req, res, next) => {
    if (!req.user) {
      return next(new AppError('Authentication required', 401));
    }

    if (!req.user.isCustomerAdmin()) {
      logger.warn(`Customer admin access denied for user ${req.user._id} (${req.user.userType})`);
      return next(new AppError(
        'Access denied: Customer admin access required',
        403
      ));
    }

    next();
  };
};

/**
 * Check if user is vendor admin
 */
const checkVendorAdminAccess = () => {
  return (req, res, next) => {
    if (!req.user) {
      return next(new AppError('Authentication required', 401));
    }

    if (!req.user.isVendorAdmin()) {
      logger.warn(`Vendor admin access denied for user ${req.user._id} (${req.user.userType})`);
      return next(new AppError(
        'Access denied: Vendor admin access required',
        403
      ));
    }

    next();
  };
};

/**
 * Ensure user has proper tenant context
 */
const ensureTenantContext = asyncHandler(async (req, res, next) => {
  try {
    if (!req.user) {
      return next();
    }

    // If tenant is already set, continue
    if (req.tenant) {
      return next();
    }

    // Get user's tenant
    const user = await User.findById(req.user._id).populate('tenantId');
    if (user && user.tenantId) {
      req.tenant = user.tenantId;
    }

    next();
  } catch (error) {
    logger.error('Tenant context error:', error);
    next();
  }
});

module.exports = {
  initializeRBAC,
  checkPermission,
  checkDynamicPermission,
  checkPortalAccess,
  checkMaritimePermission,
  autoAssignUserRole,
  ensureTenantContext,
  checkTechAccess,
  checkAdminAccess,
  checkCustomerAdminAccess,
  checkVendorAdminAccess
};
