const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  // Basic Information
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please enter a valid email']
  },
  password: {
    type: String,
    required: [true, 'Password is required'],
    minlength: [6, 'Password must be at least 6 characters'],
    select: false
  },
  firstName: {
    type: String,
    required: [true, 'First name is required'],
    trim: true,
    maxlength: [50, 'First name cannot exceed 50 characters']
  },
  lastName: {
    type: String,
    required: [true, 'Last name is required'],
    trim: true,
    maxlength: [50, 'Last name cannot exceed 50 characters']
  },
  phone: {
    type: String,
    trim: true,
    match: [/^[\+]?[1-9][\d]{0,15}$/, 'Please enter a valid phone number']
  },
  avatar: {
    type: String,
    default: null
  },

  // Maritime Procurement Specific Fields
  companyName: {
    type: String,
    trim: true,
    maxlength: [100, 'Company name cannot exceed 100 characters']
  },
  jobTitle: {
    type: String,
    trim: true,
    maxlength: [100, 'Job title cannot exceed 100 characters']
  },
  department: {
    type: String,
    trim: true,
    maxlength: [100, 'Department cannot exceed 100 characters']
  },
  vesselType: {
    type: String,
    enum: ['cargo', 'tanker', 'container', 'bulk_carrier', 'cruise', 'fishing', 'offshore', 'other'],
    default: 'other'
  },
  vesselSize: {
    type: String,
    enum: ['small', 'medium', 'large', 'very_large'],
    default: 'medium'
  },
  procurementExperience: {
    type: Number,
    min: 0,
    max: 50,
    default: 0
  },
  preferredCurrency: {
    type: String,
    enum: ['USD', 'EUR', 'GBP', 'JPY', 'CNY', 'INR'],
    default: 'USD'
  },
  timezone: {
    type: String,
    default: 'UTC'
  },

  // Multi-tenant support
  tenantId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Tenant',
    required: true
  },

  // RBAC - Role-Based Access Control
  globalRole: {
    type: String,
    enum: ['tech', 'admin', 'customer_admin', 'vendor_admin', null],
    default: null
  },
  
  // Tenant-specific roles
  tenantRoles: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Role'
  }],
  
  // Internal roles within tenant
  internalRoles: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Role'
  }],

  // User type for different portals (legacy - will be derived from globalRole)
  userType: {
    type: String,
    enum: ['admin', 'technical', 'customer', 'vendor'],
    required: true
  },

  // Account status
  isActive: {
    type: Boolean,
    default: true
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  isEmailVerified: {
    type: Boolean,
    default: false
  },
  isPhoneVerified: {
    type: Boolean,
    default: false
  },

  // Login tracking
  lastLogin: {
    type: Date,
    default: null
  },
  loginAttempts: {
    type: Number,
    default: 0
  },
  lockUntil: {
    type: Date,
    default: null
  },
  isLocked: {
    type: Boolean,
    default: false
  },

  // Password reset
  resetPasswordToken: String,
  resetPasswordExpire: Date,

  // Email verification
  emailVerificationToken: String,
  emailVerificationExpire: Date,

  // Phone verification
  phoneVerificationCode: String,
  phoneVerificationExpire: Date,

  // Maritime Procurement Preferences
  preferences: {
    notifications: {
      email: {
        rfqUpdates: { type: Boolean, default: true },
        quoteUpdates: { type: Boolean, default: true },
        orderUpdates: { type: Boolean, default: true },
        systemUpdates: { type: Boolean, default: true }
      },
      push: {
        rfqUpdates: { type: Boolean, default: true },
        quoteUpdates: { type: Boolean, default: true },
        orderUpdates: { type: Boolean, default: true }
      }
    },
    dashboard: {
      defaultView: {
        type: String,
        enum: ['overview', 'rfq', 'quotes', 'orders', 'analytics'],
        default: 'overview'
      },
      itemsPerPage: {
        type: Number,
        default: 10,
        min: 5,
        max: 100
      }
    },
    procurement: {
      autoApproveQuotes: { type: Boolean, default: false },
      requireApproval: { type: Boolean, default: true },
      defaultCurrency: {
        type: String,
        enum: ['USD', 'EUR', 'GBP', 'JPY', 'CNY', 'INR'],
        default: 'USD'
      }
    }
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
userSchema.index({ email: 1, tenantId: 1 }, { unique: true });
userSchema.index({ tenantId: 1, userType: 1 });
userSchema.index({ tenantId: 1, isActive: 1 });
userSchema.index({ email: 1 });
userSchema.index({ companyName: 1 });
userSchema.index({ vesselType: 1 });

// Virtual for full name
userSchema.virtual('fullName').get(function() {
  return `${this.firstName} ${this.lastName}`;
});

// Virtual for account lock status
userSchema.virtual('isAccountLocked').get(function() {
  return !!(this.lockUntil && this.lockUntil > Date.now());
});

// Pre-save middleware to hash password
userSchema.pre('save', async function(next) {
  // Only hash the password if it has been modified (or is new)
  if (!this.isModified('password')) return next();

  try {
    // Hash password with cost of 12
    const saltRounds = parseInt(process.env.BCRYPT_ROUNDS) || 12;
    this.password = await bcrypt.hash(this.password, saltRounds);
    next();
  } catch (error) {
    next(error);
  }
});

// Instance method to check password
userSchema.methods.comparePassword = async function(candidatePassword) {
  try {
    return await bcrypt.compare(candidatePassword, this.password);
  } catch (error) {
    throw new Error('Password comparison failed');
  }
};

// Instance method to increment login attempts
userSchema.methods.incLoginAttempts = async function() {
  // If we have a previous lock that has expired, restart at 1
  if (this.lockUntil && this.lockUntil < Date.now()) {
    return this.updateOne({
      $unset: { lockUntil: 1 },
      $set: { loginAttempts: 1 }
    });
  }

  const updates = { $inc: { loginAttempts: 1 } };
  
  // Lock account after 5 failed attempts for 2 hours
  if (this.loginAttempts + 1 >= 5 && !this.isLocked) {
    updates.$set = { lockUntil: Date.now() + 2 * 60 * 60 * 1000 }; // 2 hours
  }

  return this.updateOne(updates);
};

// Instance method to reset login attempts
userSchema.methods.resetLoginAttempts = async function() {
  return this.updateOne({
    $unset: { loginAttempts: 1, lockUntil: 1 },
    $set: { lastLogin: new Date() }
  });
};

// Static method to find by email and tenant
userSchema.statics.findByEmailAndTenant = function(email, tenantId) {
  return this.findOne({ email: email.toLowerCase(), tenantId });
};

// Static method to find active users in tenant
userSchema.statics.findActiveInTenant = function(tenantId) {
  return this.find({ tenantId, isActive: true });
};

// Static method to find users by global role
userSchema.statics.findByGlobalRole = function(globalRole) {
  return this.find({ globalRole, isActive: true });
};

// Static method to find tech users (global super admins)
userSchema.statics.findTechUsers = function() {
  return this.find({ globalRole: 'tech', isActive: true });
};

// Instance method to check if user is tech (global super admin)
userSchema.methods.isTech = function() {
  return this.globalRole === 'tech';
};

// Instance method to check if user is admin
userSchema.methods.isAdmin = function() {
  return this.globalRole === 'admin';
};

// Instance method to check if user is customer admin
userSchema.methods.isCustomerAdmin = function() {
  return this.globalRole === 'customer_admin';
};

// Instance method to check if user is vendor admin
userSchema.methods.isVendorAdmin = function() {
  return this.globalRole === 'vendor_admin';
};

// Instance method to check if user has global role
userSchema.methods.hasGlobalRole = function() {
  return this.globalRole !== null;
};

// Instance method to get all roles (global + tenant + internal)
userSchema.methods.getAllRoles = async function() {
  const Role = mongoose.model('Role');
  const roles = [];
  
  // Add global role
  if (this.globalRole) {
    const globalRole = await Role.findByGlobalRole(this.globalRole);
    if (globalRole) roles.push(globalRole);
  }
  
  // Add tenant roles
  if (this.tenantRoles.length > 0) {
    const tenantRoles = await Role.find({ _id: { $in: this.tenantRoles } });
    roles.push(...tenantRoles);
  }
  
  // Add internal roles
  if (this.internalRoles.length > 0) {
    const internalRoles = await Role.find({ _id: { $in: this.internalRoles } });
    roles.push(...internalRoles);
  }
  
  return roles;
};

module.exports = mongoose.model('User', userSchema);
