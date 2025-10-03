const Role = require('../models/Role');
const User = require('../models/User');
const Tenant = require('../models/Tenant');
const { createLogger } = require('../config/logging');
const casbinService = require('../config/casbin');

const logger = createLogger('rbac-init');

/**
 * Initialize default roles for the Maritime Procurement ERP system
 */
const initializeDefaultRoles = async () => {
  try {
    logger.info('🚀 Initializing default RBAC roles...');

    // Check if roles already exist
    const existingRoles = await Role.countDocuments();
    if (existingRoles > 0) {
      logger.info('📋 Default roles already exist, skipping initialization');
      return;
    }

    // ===== GLOBAL ROLES =====
    const globalRoles = [
      {
        name: 'Tech Super Admin',
        description: 'Global super administrator with access to all systems and tenants',
        roleType: 'global',
        globalRole: 'tech',
        permissions: [
          { resource: '/*', actions: ['*'] },
          { resource: '/api/*', actions: ['*'] },
          { resource: '/api/tenants/*', actions: ['*'] },
          { resource: '/api/users/*', actions: ['*'] },
          { resource: '/api/roles/*', actions: ['*'] }
        ],
        maritimeFeatures: {
          vesselManagement: true,
          rfqManagement: true,
          quoteManagement: true,
          orderManagement: true,
          vendorManagement: true,
          analyticsAccess: true,
          systemAdmin: true
        },
        isSystemRole: true
      },
      {
        name: 'Platform Admin',
        description: 'Platform administrator for EuroAsianNGroup',
        roleType: 'global',
        globalRole: 'admin',
        permissions: [
          { resource: '/api/admin/*', actions: ['*'] },
          { resource: '/api/tenants', actions: ['POST'] },
          { resource: '/api/tenants/*', actions: ['GET', 'PUT'] },
          { resource: '/api/users', actions: ['GET', 'POST'] },
          { resource: '/api/users/*', actions: ['PUT', 'DELETE'] },
          { resource: '/api/roles', actions: ['GET', 'POST'] },
          { resource: '/api/roles/*', actions: ['PUT', 'DELETE'] }
        ],
        maritimeFeatures: {
          vesselManagement: true,
          rfqManagement: true,
          quoteManagement: true,
          orderManagement: true,
          vendorManagement: true,
          analyticsAccess: true,
          systemAdmin: false
        },
        isSystemRole: true
      },
      {
        name: 'Customer Admin',
        description: 'Customer organization administrator',
        roleType: 'global',
        globalRole: 'customer_admin',
        permissions: [
          { resource: '/api/customers/*', actions: ['*'] },
          { resource: '/api/users', actions: ['GET', 'POST'] },
          { resource: '/api/users/*', actions: ['PUT', 'DELETE'] },
          { resource: '/api/roles', actions: ['GET', 'POST'] },
          { resource: '/api/roles/*', actions: ['PUT', 'DELETE'] },
          { resource: '/api/rfq/*', actions: ['*'] },
          { resource: '/api/quotes/*', actions: ['*'] },
          { resource: '/api/orders/*', actions: ['*'] }
        ],
        maritimeFeatures: {
          vesselManagement: true,
          rfqManagement: true,
          quoteManagement: true,
          orderManagement: true,
          vendorManagement: false,
          analyticsAccess: true,
          systemAdmin: false
        },
        isSystemRole: true
      },
      {
        name: 'Vendor Admin',
        description: 'Vendor organization administrator',
        roleType: 'global',
        globalRole: 'vendor_admin',
        permissions: [
          { resource: '/api/vendors/*', actions: ['*'] },
          { resource: '/api/users', actions: ['GET', 'POST'] },
          { resource: '/api/users/*', actions: ['PUT', 'DELETE'] },
          { resource: '/api/roles', actions: ['GET', 'POST'] },
          { resource: '/api/roles/*', actions: ['PUT', 'DELETE'] },
          { resource: '/api/rfq/*', actions: ['GET'] },
          { resource: '/api/quotes/*', actions: ['*'] },
          { resource: '/api/orders/*', actions: ['GET'] }
        ],
        maritimeFeatures: {
          vesselManagement: false,
          rfqManagement: false,
          quoteManagement: true,
          orderManagement: false,
          vendorManagement: true,
          analyticsAccess: true,
          systemAdmin: false
        },
        isSystemRole: true
      }
    ];

    // Create global roles
    for (const roleData of globalRoles) {
      const role = new Role({
        ...roleData,
        createdBy: null // System created
      });
      await role.save();
      logger.info(`✅ Created global role: ${role.name}`);
    }

    // ===== DEFAULT INTERNAL ROLES =====
    const defaultInternalRoles = [
      // Customer internal roles
      {
        name: 'Fleet Manager',
        description: 'Manages vessel fleet operations and maintenance',
        roleType: 'internal',
        tenantType: 'customer',
        permissions: [
          { resource: '/api/customers/vessels/*', actions: ['*'] },
          { resource: '/api/customers/maintenance/*', actions: ['*'] },
          { resource: '/api/rfq', actions: ['GET', 'POST'] },
          { resource: '/api/rfq/*', actions: ['GET', 'PUT'] }
        ],
        maritimeFeatures: {
          vesselManagement: true,
          rfqManagement: true,
          quoteManagement: false,
          orderManagement: false,
          vendorManagement: false,
          analyticsAccess: true,
          systemAdmin: false
        }
      },
      {
        name: 'Procurement Officer',
        description: 'Handles procurement processes and vendor relationships',
        roleType: 'internal',
        tenantType: 'customer',
        permissions: [
          { resource: '/api/rfq/*', actions: ['*'] },
          { resource: '/api/quotes/*', actions: ['GET', 'PUT'] },
          { resource: '/api/orders/*', actions: ['GET', 'POST'] },
          { resource: '/api/vendors', actions: ['GET'] }
        ],
        maritimeFeatures: {
          vesselManagement: false,
          rfqManagement: true,
          quoteManagement: true,
          orderManagement: true,
          vendorManagement: false,
          analyticsAccess: true,
          systemAdmin: false
        }
      },
      {
        name: 'Finance Approver',
        description: 'Approves financial transactions and budgets',
        roleType: 'internal',
        tenantType: 'customer',
        permissions: [
          { resource: '/api/quotes/*', actions: ['GET', 'PUT'] },
          { resource: '/api/orders/*', actions: ['GET', 'PUT'] },
          { resource: '/api/customers/budget/*', actions: ['*'] }
        ],
        maritimeFeatures: {
          vesselManagement: false,
          rfqManagement: false,
          quoteManagement: true,
          orderManagement: true,
          vendorManagement: false,
          analyticsAccess: true,
          systemAdmin: false
        }
      },
      // Vendor internal roles
      {
        name: 'Sales Representative',
        description: 'Handles sales activities and customer relationships',
        roleType: 'internal',
        tenantType: 'vendor',
        permissions: [
          { resource: '/api/rfq/*', actions: ['GET'] },
          { resource: '/api/quotes', actions: ['GET', 'POST'] },
          { resource: '/api/quotes/*', actions: ['GET', 'PUT'] },
          { resource: '/api/orders/*', actions: ['GET'] }
        ],
        maritimeFeatures: {
          vesselManagement: false,
          rfqManagement: false,
          quoteManagement: true,
          orderManagement: false,
          vendorManagement: true,
          analyticsAccess: true,
          systemAdmin: false
        }
      },
      {
        name: 'Pricing Manager',
        description: 'Manages pricing strategies and quote approvals',
        roleType: 'internal',
        tenantType: 'vendor',
        permissions: [
          { resource: '/api/quotes/*', actions: ['*'] },
          { resource: '/api/vendors/pricing/*', actions: ['*'] }
        ],
        maritimeFeatures: {
          vesselManagement: false,
          rfqManagement: false,
          quoteManagement: true,
          orderManagement: false,
          vendorManagement: true,
          analyticsAccess: true,
          systemAdmin: false
        }
      },
      {
        name: 'Technical Support',
        description: 'Provides technical support and product expertise',
        roleType: 'internal',
        tenantType: 'vendor',
        permissions: [
          { resource: '/api/rfq/*', actions: ['GET'] },
          { resource: '/api/quotes/*', actions: ['GET', 'PUT'] },
          { resource: '/api/vendors/products/*', actions: ['*'] }
        ],
        maritimeFeatures: {
          vesselManagement: false,
          rfqManagement: false,
          quoteManagement: true,
          orderManagement: false,
          vendorManagement: true,
          analyticsAccess: false,
          systemAdmin: false
        }
      }
    ];

    // Create default internal roles (these will be available for assignment to tenants)
    for (const roleData of defaultInternalRoles) {
      const role = new Role({
        ...roleData,
        createdBy: null // System created
      });
      await role.save();
      logger.info(`✅ Created default internal role: ${role.name} (${role.tenantType})`);
    }

    logger.info('🎉 Default RBAC roles initialized successfully!');
    
  } catch (error) {
    logger.error('Failed to initialize default roles:', error);
    throw error;
  }
};

/**
 * Create a default tech user for system administration
 */
const createDefaultTechUser = async () => {
  try {
    // Check if tech users already exist
    const existingTechUsers = await User.findByGlobalRole('tech');
    if (existingTechUsers.length > 0) {
      logger.info('📋 Tech users already exist, skipping creation');
      return;
    }

    // Create a default tech tenant
    const techTenant = new Tenant({
      name: 'Maritime Procurement System',
      slug: 'maritime-procurement-system',
      description: 'System administration tenant',
      tenantType: 'admin',
      companyInfo: {
        registrationNumber: 'SYSTEM',
        address: {
          country: 'Global'
        },
        email: 'system@maritime-procurement.com'
      },
      subscription: {
        plan: 'enterprise',
        status: 'active',
        maxUsers: 999999,
        maxStorage: 999999,
        maxRFQs: 999999,
        maxQuotes: 999999
      },
      features: {
        multiPortal: true,
        advancedReporting: true,
        apiAccess: true,
        customBranding: true,
        sso: true,
        advancedAnalytics: true,
        customIntegrations: true,
        prioritySupport: true
      },
      maritimeFeatures: {
        vesselTracking: true,
        portIntegration: true,
        weatherIntegration: true,
        fuelOptimization: true,
        maintenanceScheduling: true,
        complianceTracking: true
      },
      owner: null, // Will be set after user creation
      createdBy: null // System created
    });

    await techTenant.save();

    // Create default tech user
    const techUser = new User({
      email: 'tech@maritime-procurement.com',
      password: 'TechAdmin123!', // Change this in production
      firstName: 'System',
      lastName: 'Administrator',
      userType: 'technical',
      globalRole: 'tech',
      tenantId: techTenant._id,
      companyName: 'Maritime Procurement System',
      jobTitle: 'System Administrator',
      isActive: true,
      isVerified: true,
      isEmailVerified: true
    });

    await techUser.save();

    // Update tenant owner
    techTenant.owner = techUser._id;
    await techTenant.save();

    logger.info('✅ Created default tech user: tech@maritime-procurement.com');
    logger.warn('⚠️  Please change the default tech user password in production!');

  } catch (error) {
    logger.error('Failed to create default tech user:', error);
    throw error;
  }
};

/**
 * Initialize the complete RBAC system
 */
const initializeRBACSystem = async () => {
  try {
    logger.info('🚀 Initializing Maritime Procurement RBAC System...');
    
    // Initialize default roles
    await initializeDefaultRoles();
    
    // Create default tech user
    await createDefaultTechUser();
    
    // Initialize Casbin policies
    await casbinService.initializeDefaultPolicies();
    
    logger.info('🎉 RBAC System initialization completed successfully!');
    
  } catch (error) {
    logger.error('Failed to initialize RBAC system:', error);
    throw error;
  }
};

module.exports = {
  initializeDefaultRoles,
  createDefaultTechUser,
  initializeRBACSystem
};






