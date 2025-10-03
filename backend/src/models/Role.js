const mongoose = require('mongoose');

const roleSchema = new mongoose.Schema({
  // Basic Information
  name: {
    type: String,
    required: [true, 'Role name is required'],
    trim: true,
    maxlength: [100, 'Role name cannot exceed 100 characters']
  },
  description: {
    type: String,
    trim: true,
    maxlength: [500, 'Description cannot exceed 500 characters']
  },
  
  // Role Classification
  roleType: {
    type: String,
    enum: ['global', 'tenant', 'internal'],
    required: true
  },
  
  // Global roles (Tech Portal)
  globalRole: {
    type: String,
    enum: ['tech', 'admin', 'customer_admin', 'vendor_admin', null],
    default: null
  },
  
  // Tenant Information
  tenantId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Tenant',
    required: function() {
      return this.roleType === 'tenant' || this.roleType === 'internal';
    }
  },
  
  // Tenant Type (for tenant-level roles)
  tenantType: {
    type: String,
    enum: ['admin', 'customer', 'vendor', null],
    default: null
  },
  
  // Permissions
  permissions: [{
    resource: {
      type: String,
      required: true,
      trim: true
    },
    actions: [{
      type: String,
      enum: ['create', 'read', 'update', 'delete', 'manage', 'view', 'approve', 'reject'],
      required: true
    }],
    conditions: {
      type: Map,
      of: mongoose.Schema.Types.Mixed,
      default: new Map()
    }
  }],
  
  // Role Hierarchy
  parentRole: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Role',
    default: null
  },
  childRoles: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Role'
  }],
  
  // Role Scope
  scope: {
    type: String,
    enum: ['global', 'tenant', 'department', 'project'],
    default: 'tenant'
  },
  
  // Maritime Specific
  maritimeFeatures: {
    vesselManagement: { type: Boolean, default: false },
    rfqManagement: { type: Boolean, default: false },
    quoteManagement: { type: Boolean, default: false },
    orderManagement: { type: Boolean, default: false },
    vendorManagement: { type: Boolean, default: false },
    analyticsAccess: { type: Boolean, default: false },
    systemAdmin: { type: Boolean, default: false }
  },
  
  // Role Status
  isActive: {
    type: Boolean,
    default: true
  },
  isSystemRole: {
    type: Boolean,
    default: false
  },
  
  // Created by
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  
  // Additional metadata
  metadata: {
    type: Map,
    of: mongoose.Schema.Types.Mixed,
    default: new Map()
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for performance
roleSchema.index({ name: 1, tenantId: 1 }, { unique: true });
roleSchema.index({ roleType: 1 });
roleSchema.index({ globalRole: 1 });
roleSchema.index({ tenantId: 1, tenantType: 1 });
roleSchema.index({ isActive: 1 });

// Virtual for role hierarchy level
roleSchema.virtual('hierarchyLevel').get(function() {
  if (this.globalRole) return 0; // Global roles
  if (this.roleType === 'tenant') return 1; // Tenant-level roles
  return 2; // Internal roles
});

// Pre-save middleware to validate role structure
roleSchema.pre('save', function(next) {
  // Validate global roles
  if (this.globalRole && this.roleType !== 'global') {
    return next(new Error('Global roles must have roleType: global'));
  }
  
  // Validate tenant roles
  if (this.roleType === 'tenant' && !this.tenantId) {
    return next(new Error('Tenant roles must have tenantId'));
  }
  
  // Validate internal roles
  if (this.roleType === 'internal' && !this.tenantId) {
    return next(new Error('Internal roles must have tenantId'));
  }
  
  next();
});

// Static method to find global roles
roleSchema.statics.findGlobalRoles = function() {
  return this.find({ roleType: 'global', isActive: true });
};

// Static method to find tenant roles
roleSchema.statics.findTenantRoles = function(tenantId) {
  return this.find({ tenantId, roleType: 'tenant', isActive: true });
};

// Static method to find internal roles
roleSchema.statics.findInternalRoles = function(tenantId) {
  return this.find({ tenantId, roleType: 'internal', isActive: true });
};

// Static method to find roles by global role type
roleSchema.statics.findByGlobalRole = function(globalRole) {
  return this.findOne({ globalRole, isActive: true });
};

// Instance method to check if role has permission
roleSchema.methods.hasPermission = function(resource, action) {
  const permission = this.permissions.find(p => p.resource === resource);
  if (!permission) return false;
  return permission.actions.includes(action) || permission.actions.includes('manage');
};

// Instance method to add permission
roleSchema.methods.addPermission = function(resource, actions) {
  const existingPermission = this.permissions.find(p => p.resource === resource);
  if (existingPermission) {
    // Merge actions
    const newActions = [...new Set([...existingPermission.actions, ...actions])];
    existingPermission.actions = newActions;
  } else {
    this.permissions.push({ resource, actions });
  }
};

// Instance method to remove permission
roleSchema.methods.removePermission = function(resource, action) {
  const permission = this.permissions.find(p => p.resource === resource);
  if (permission) {
    permission.actions = permission.actions.filter(a => a !== action);
    if (permission.actions.length === 0) {
      this.permissions = this.permissions.filter(p => p.resource !== resource);
    }
  }
};

module.exports = mongoose.model('Role', roleSchema);






