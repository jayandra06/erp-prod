const { newEnforcer } = require('casbin');
const MongoAdapter = require('casbin-mongodb-adapter');
const path = require('path');
const { createLogger } = require('./logging');

const logger = createLogger('casbin');

class MaritimeProcurementRBAC {
  constructor() {
    this.enforcer = null;
    this.adapter = null;
  }

  async initEnforcer() {
    try {
      // Initialize MongoDB adapter for Casbin
      this.adapter = new MongoAdapter(process.env.MONGODB_URI);

      // Load the RBAC model
      const modelPath = path.join(__dirname, 'rbac_model.conf');
      this.enforcer = await newEnforcer(modelPath, this.adapter);

      // Load policies from database
      await this.enforcer.loadPolicy();

      logger.info('🔐 Maritime Procurement RBAC system initialized successfully');
      
      // Initialize default policies if none exist
      await this.initializeDefaultPolicies();
      
      return this.enforcer;
    } catch (error) {
      logger.error('Failed to initialize Casbin RBAC:', error);
      // Don't throw error, just log it and continue without RBAC
      logger.warn('⚠️  Continuing without RBAC - some features may be limited');
      return null;
    }
  }

  async initializeDefaultPolicies() {
    try {
      // Check if policies already exist
      const policies = await this.enforcer.getPolicy();
      if (policies.length > 0) {
        logger.info('📋 Existing RBAC policies found, skipping initialization');
        return;
      }

      logger.info('🔧 Initializing Maritime Procurement RBAC policies...');

      // Maritime Procurement specific policies
      const defaultPolicies = [
        // ===== GLOBAL ROLES (Tech Portal - Super Admin) =====
        // Tech users have global access to everything
        ['tech', '/*', '*', '*'],
        ['tech', '/api/*', '*', '*'],
        ['tech', '/api/tenants/*', '*', '*'],
        ['tech', '/api/users/*', '*', '*'],
        ['tech', '/api/roles/*', '*', '*'],
        ['tech', '/api/technical/*', '*', '*'],
        ['tech', '/api/admin/*', '*', '*'],
        ['tech', '/api/customers/*', '*', '*'],
        ['tech', '/api/vendors/*', '*', '*'],

        // ===== ADMIN ROLES (Admin Portal - EuroAsianNGroup) =====
        // Admin users can manage their own tenant and create customers/vendors
        ['admin', '/api/admin/*', '*', 'admin_tenant'],
        ['admin', '/api/users', 'GET', 'admin_tenant'],
        ['admin', '/api/users', 'POST', 'admin_tenant'],
        ['admin', '/api/users/*', 'PUT', 'admin_tenant'],
        ['admin', '/api/users/*', 'DELETE', 'admin_tenant'],
        ['admin', '/api/tenants', 'POST', 'admin_tenant'], // Create customers/vendors
        ['admin', '/api/tenants/*', 'GET', 'admin_tenant'],
        ['admin', '/api/tenants/*', 'PUT', 'admin_tenant'],
        ['admin', '/api/roles', 'GET', 'admin_tenant'],
        ['admin', '/api/roles', 'POST', 'admin_tenant'],
        ['admin', '/api/roles/*', 'PUT', 'admin_tenant'],
        ['admin', '/api/roles/*', 'DELETE', 'admin_tenant'],
        ['admin', '/api/auth/me', 'GET', 'admin_tenant'],

        // ===== CUSTOMER ADMIN ROLES (Customer Portal - Ship Management) =====
        // Customer admins can manage their own tenant and create internal roles
        ['customer_admin', '/api/customers/*', '*', 'customer_tenant'],
        ['customer_admin', '/api/users', 'GET', 'customer_tenant'],
        ['customer_admin', '/api/users', 'POST', 'customer_tenant'],
        ['customer_admin', '/api/users/*', 'PUT', 'customer_tenant'],
        ['customer_admin', '/api/users/*', 'DELETE', 'customer_tenant'],
        ['customer_admin', '/api/roles', 'GET', 'customer_tenant'],
        ['customer_admin', '/api/roles', 'POST', 'customer_tenant'],
        ['customer_admin', '/api/roles/*', 'PUT', 'customer_tenant'],
        ['customer_admin', '/api/roles/*', 'DELETE', 'customer_tenant'],
        ['customer_admin', '/api/rfq/*', '*', 'customer_tenant'],
        ['customer_admin', '/api/quotes/*', '*', 'customer_tenant'],
        ['customer_admin', '/api/orders/*', '*', 'customer_tenant'],
        ['customer_admin', '/api/auth/me', 'GET', 'customer_tenant'],

        // ===== VENDOR ADMIN ROLES (Vendor Portal - Suppliers) =====
        // Vendor admins can manage their own tenant and create internal roles
        ['vendor_admin', '/api/vendors/*', '*', 'vendor_tenant'],
        ['vendor_admin', '/api/users', 'GET', 'vendor_tenant'],
        ['vendor_admin', '/api/users', 'POST', 'vendor_tenant'],
        ['vendor_admin', '/api/users/*', 'PUT', 'vendor_tenant'],
        ['vendor_admin', '/api/users/*', 'DELETE', 'vendor_tenant'],
        ['vendor_admin', '/api/roles', 'GET', 'vendor_tenant'],
        ['vendor_admin', '/api/roles', 'POST', 'vendor_tenant'],
        ['vendor_admin', '/api/roles/*', 'PUT', 'vendor_tenant'],
        ['vendor_admin', '/api/roles/*', 'DELETE', 'vendor_tenant'],
        ['vendor_admin', '/api/rfq/*', 'GET', 'vendor_tenant'],
        ['vendor_admin', '/api/quotes/*', '*', 'vendor_tenant'],
        ['vendor_admin', '/api/orders/*', 'GET', 'vendor_tenant'],
        ['vendor_admin', '/api/auth/me', 'GET', 'vendor_tenant'],

        // ===== INTERNAL ROLES (Custom roles within tenants) =====
        // These will be dynamically created based on tenant needs
        // Example: Fleet Manager, Procurement Officer, Sales Rep, etc.
        ['customer', '/api/customers/rfq/*', '*', 'maritime-procurement'],
        ['customer', '/api/customers/orders/*', '*', 'maritime-procurement'],
        ['customer', '/api/customers/profile', '*', 'maritime-procurement'],
        ['customer', '/api/auth/me', 'GET', 'maritime-procurement'],

        // Vendor User policies (vendor portal)
        ['vendor', '/api/vendors/*', '*', 'maritime-procurement'],
        ['vendor', '/api/vendors/dashboard', 'GET', 'maritime-procurement'],
        ['vendor', '/api/vendors/products/*', '*', 'maritime-procurement'],
        ['vendor', '/api/vendors/quotes/*', '*', 'maritime-procurement'],
        ['vendor', '/api/vendors/orders/*', '*', 'maritime-procurement'],
        ['vendor', '/api/vendors/profile', '*', 'maritime-procurement'],
        ['vendor', '/api/auth/me', 'GET', 'maritime-procurement'],

        // Public access policies
        ['public', '/api/auth/login', 'POST', 'maritime-procurement'],
        ['public', '/api/auth/register', 'POST', 'maritime-procurement'],
        ['public', '/api/auth/forgot-password', 'POST', 'maritime-procurement'],
        ['public', '/api/auth/reset-password', 'POST', 'maritime-procurement'],
        ['public', '/health', 'GET', 'maritime-procurement'],
      ];

      // Add policies to Casbin
      for (const policy of defaultPolicies) {
        await this.enforcer.addPolicy(...policy);
      }

      // Add role assignments for existing users
      const roleAssignments = [
        // Platform admin (if exists)
        ['platform-admin@maritime-procurement.com', 'platform_admin', 'maritime-procurement'],
        
        // Tenant admin
        ['admin@maritime-procurement.com', 'tenant_admin', 'maritime-procurement'],
        
        // Technical users
        ['technical@maritime-procurement.com', 'technical', 'maritime-procurement'],
      ];

      for (const assignment of roleAssignments) {
        await this.enforcer.addRoleForUser(...assignment);
      }

      // Save policies to database
      await this.enforcer.savePolicy();

      logger.info('✅ Maritime Procurement RBAC policies initialized successfully');
    } catch (error) {
      logger.error('Failed to initialize default RBAC policies:', error);
    }
  }

  async checkPermission(userId, resource, action, tenantId) {
    try {
      if (!this.enforcer) {
        logger.warn('⚠️  Casbin not initialized, allowing access');
        return true;
      }

      // First check if user is tech (global super admin)
      const isTech = await this.enforcer.enforce(userId, resource, action, '*');
      if (isTech) {
        logger.debug(`🔍 Tech user ${userId} has global access to ${resource}:${action}`);
        return true;
      }

      // Check tenant-specific permission
      const hasPermission = await this.enforcer.enforce(userId, resource, action, tenantId);
      logger.debug(`🔍 Permission check: ${userId} -> ${resource}:${action}@${tenantId} = ${hasPermission}`);
      
      return hasPermission;
    } catch (error) {
      logger.error('Permission check error:', error);
      return false;
    }
  }

  /**
   * Check if user is tech (global super admin)
   * @param {string} userId - User ID
   */
  async isTechUser(userId) {
    try {
      if (!this.enforcer) {
        return false;
      }

      // Check if user has tech role
      const hasTechRole = await this.enforcer.hasRoleForUser(userId, 'tech');
      return hasTechRole;
    } catch (error) {
      logger.error('Tech user check error:', error);
      return false;
    }
  }

  async addUserRole(userId, role, tenantId) {
    try {
      if (!this.enforcer) return false;
      
      await this.enforcer.addRoleForUser(userId, role, tenantId);
      await this.enforcer.savePolicy();
      
      logger.info(`✅ Added role ${role} for user ${userId} in tenant ${tenantId}`);
      return true;
    } catch (error) {
      logger.error('Failed to add user role:', error);
      return false;
    }
  }

  async removeUserRole(userId, role, tenantId) {
    try {
      if (!this.enforcer) return false;
      
      await this.enforcer.deleteRoleForUser(userId, role, tenantId);
      await this.enforcer.savePolicy();
      
      logger.info(`✅ Removed role ${role} for user ${userId} in tenant ${tenantId}`);
      return true;
    } catch (error) {
      logger.error('Failed to remove user role:', error);
      return false;
    }
  }

  async getUserRoles(userId, tenantId) {
    try {
      if (!this.enforcer) return [];
      
      const roles = await this.enforcer.getRolesForUser(userId, tenantId);
      return roles;
    } catch (error) {
      logger.error('Failed to get user roles:', error);
      return [];
    }
  }

  async addPolicy(subject, resource, action, tenantId) {
    try {
      if (!this.enforcer) return false;
      
      await this.enforcer.addPolicy(subject, resource, action, tenantId);
      await this.enforcer.savePolicy();
      
      logger.info(`✅ Added policy: ${subject} -> ${resource}:${action}@${tenantId}`);
      return true;
    } catch (error) {
      logger.error('Failed to add policy:', error);
      return false;
    }
  }

  async removePolicy(subject, resource, action, tenantId) {
    try {
      if (!this.enforcer) return false;
      
      await this.enforcer.removePolicy(subject, resource, action, tenantId);
      await this.enforcer.savePolicy();
      
      logger.info(`✅ Removed policy: ${subject} -> ${resource}:${action}@${tenantId}`);
      return true;
    } catch (error) {
      logger.error('Failed to remove policy:', error);
      return false;
    }
  }

  async getPolicies() {
    try {
      if (!this.enforcer) return [];
      
      return await this.enforcer.getPolicy();
    } catch (error) {
      logger.error('Failed to get policies:', error);
      return [];
    }
  }
}

module.exports = new MaritimeProcurementRBAC();
