const mongoose = require('mongoose');

const tenantSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Tenant name is required'],
    trim: true,
    maxlength: [100, 'Tenant name cannot exceed 100 characters']
  },
  slug: {
    type: String,
    required: [true, 'Tenant slug is required'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^[a-z0-9-]+$/, 'Slug can only contain lowercase letters, numbers, and hyphens']
  },
  description: {
    type: String,
    trim: true,
    maxlength: [500, 'Description cannot exceed 500 characters']
  },

  // Maritime Company Information
  companyInfo: {
    registrationNumber: {
      type: String,
      trim: true
    },
    taxId: {
      type: String,
      trim: true
    },
    imoNumber: {
      type: String,
      trim: true,
      match: [/^\d{7}$/, 'IMO number must be 7 digits']
    },
    address: {
      street: String,
      city: String,
      state: String,
      country: String,
      zipCode: String,
      coordinates: {
        latitude: Number,
        longitude: Number
      }
    },
    phone: String,
    email: String,
    website: String,
    establishedYear: Number,
    fleetSize: {
      type: Number,
      min: 0
    },
    vesselTypes: [{
      type: String,
      enum: ['cargo', 'tanker', 'container', 'bulk_carrier', 'cruise', 'fishing', 'offshore', 'other']
    }]
  },

  // Subscription and billing
  subscription: {
    plan: {
      type: String,
      enum: ['basic', 'standard', 'premium', 'enterprise'],
      default: 'basic'
    },
    status: {
      type: String,
      enum: ['active', 'inactive', 'suspended', 'trial', 'cancelled'],
      default: 'trial'
    },
    startDate: {
      type: Date,
      default: Date.now
    },
    endDate: Date,
    trialEndDate: {
      type: Date,
      default: () => new Date(Date.now() + 14 * 24 * 60 * 60 * 1000) // 14 days trial
    },
    maxUsers: {
      type: Number,
      default: 10,
      min: 1
    },
    maxStorage: {
      type: Number,
      default: 1024, // MB
      min: 100
    },
    maxRFQs: {
      type: Number,
      default: 100,
      min: 10
    },
    maxQuotes: {
      type: Number,
      default: 500,
      min: 50
    },
    billingCycle: {
      type: String,
      enum: ['monthly', 'quarterly', 'yearly'],
      default: 'monthly'
    },
    currency: {
      type: String,
      enum: ['USD', 'EUR', 'GBP', 'JPY', 'CNY', 'INR'],
      default: 'USD'
    }
  },

  // Feature flags
  features: {
    multiPortal: {
      type: Boolean,
      default: true
    },
    advancedReporting: {
      type: Boolean,
      default: false
    },
    apiAccess: {
      type: Boolean,
      default: false
    },
    customBranding: {
      type: Boolean,
      default: false
    },
    sso: {
      type: Boolean,
      default: false
    },
    advancedAnalytics: {
      type: Boolean,
      default: false
    },
    customIntegrations: {
      type: Boolean,
      default: false
    },
    prioritySupport: {
      type: Boolean,
      default: false
    }
  },

  // Maritime Procurement Specific Features
  maritimeFeatures: {
    vesselTracking: {
      type: Boolean,
      default: false
    },
    portIntegration: {
      type: Boolean,
      default: false
    },
    weatherIntegration: {
      type: Boolean,
      default: false
    },
    fuelOptimization: {
      type: Boolean,
      default: false
    },
    maintenanceScheduling: {
      type: Boolean,
      default: false
    },
    complianceTracking: {
      type: Boolean,
      default: false
    }
  },

  // Branding
  branding: {
    logo: String,
    favicon: String,
    primaryColor: {
      type: String,
      default: '#1976d2',
      match: [/^#[0-9A-F]{6}$/i, 'Primary color must be a valid hex color']
    },
    secondaryColor: {
      type: String,
      default: '#dc004e',
      match: [/^#[0-9A-F]{6}$/i, 'Secondary color must be a valid hex color']
    },
    customCSS: String,
    customJavaScript: String
  },

  // Settings
  settings: {
    timezone: {
      type: String,
      default: 'UTC'
    },
    language: {
      type: String,
      default: 'en',
      enum: ['en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'zh', 'ja', 'ko', 'ar']
    },
    dateFormat: {
      type: String,
      default: 'MM/DD/YYYY',
      enum: ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD']
    },
    timeFormat: {
      type: String,
      default: '12h',
      enum: ['12h', '24h']
    },
    currency: {
      type: String,
      default: 'USD',
      enum: ['USD', 'EUR', 'GBP', 'JPY', 'CNY', 'INR']
    },
    notifications: {
      email: {
        type: Boolean,
        default: true
      },
      push: {
        type: Boolean,
        default: true
      },
      sms: {
        type: Boolean,
        default: false
      }
    }
  },

  // Tenant Type
  tenantType: {
    type: String,
    enum: ['admin', 'customer', 'vendor'],
    required: true
  },
  
  // Owner and admins
  owner: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  admins: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  
  // Created by (who created this tenant)
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },

  // Status
  isActive: {
    type: Boolean,
    default: true
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  verificationDate: Date,

  // Statistics
  stats: {
    totalUsers: {
      type: Number,
      default: 0
    },
    totalRFQs: {
      type: Number,
      default: 0
    },
    totalQuotes: {
      type: Number,
      default: 0
    },
    totalOrders: {
      type: Number,
      default: 0
    },
    lastActivity: {
      type: Date,
      default: Date.now
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
tenantSchema.index({ slug: 1 }, { unique: true });
tenantSchema.index({ isActive: 1 });
tenantSchema.index({ 'subscription.status': 1 });
tenantSchema.index({ owner: 1 });
tenantSchema.index({ name: 1 });

// Pre-save middleware to generate slug if not provided
tenantSchema.pre('save', function(next) {
  if (!this.slug && this.name) {
    this.slug = this.name
      .toLowerCase()
      .replace(/[^a-z0-9]/g, '-')
      .replace(/-+/g, '-')
      .replace(/^-|-$/g, '');
  }
  next();
});

// Virtual for subscription status
tenantSchema.virtual('isSubscriptionActive').get(function() {
  return this.subscription.status === 'active' || 
         (this.subscription.status === 'trial' && this.subscription.trialEndDate > new Date());
});

// Virtual for days until trial ends
tenantSchema.virtual('trialDaysRemaining').get(function() {
  if (this.subscription.status !== 'trial') return 0;
  const days = Math.ceil((this.subscription.trialEndDate - new Date()) / (1000 * 60 * 60 * 24));
  return Math.max(0, days);
});

// Instance method to check if user is admin
tenantSchema.methods.isAdmin = function(userId) {
  return this.owner.toString() === userId.toString() || 
         this.admins.some(admin => admin.toString() === userId.toString());
};

// Instance method to add admin
tenantSchema.methods.addAdmin = function(userId) {
  if (!this.admins.includes(userId)) {
    this.admins.push(userId);
  }
};

// Instance method to remove admin
tenantSchema.methods.removeAdmin = function(userId) {
  this.admins = this.admins.filter(admin => admin.toString() !== userId.toString());
};

// Static method to find by slug
tenantSchema.statics.findBySlug = function(slug) {
  return this.findOne({ slug, isActive: true });
};

// Static method to find active tenants
tenantSchema.statics.findActive = function() {
  return this.find({ isActive: true });
};

module.exports = mongoose.model('Tenant', tenantSchema);
