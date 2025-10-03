const mongoose = require('mongoose');
const User = require('../models/User');
const Tenant = require('../models/Tenant');
const { connectDB } = require('../config/database');
const { createLogger } = require('../config/logging');

const logger = createLogger('seed-tech-user');

/**
 * Seed a specific tech user for the Maritime Procurement ERP system
 */
const seedTechUser = async () => {
  try {
    // Connect to database
    await connectDB();
    
    const email = 'jayandraa5@gmail.com';
    const password = 'J@yandra06';
    
    logger.info(`🚀 Seeding tech user: ${email}`);
    
    // Check if user already exists
    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      logger.info(`📋 User ${email} already exists, updating to tech role...`);
      
      // Update existing user to tech role
      existingUser.globalRole = 'tech';
      existingUser.userType = 'technical';
      existingUser.isActive = true;
      existingUser.isVerified = true;
      existingUser.isEmailVerified = true;
      
      // Update password
      existingUser.password = password;
      
      await existingUser.save();
      
      logger.info(`✅ Updated user ${email} to tech role successfully!`);
      return;
    }
    
    // Check if tech tenant exists, if not create it
    let techTenant = await Tenant.findOne({ slug: 'maritime-procurement-system' });
    
    if (!techTenant) {
      logger.info('📋 Creating tech tenant...');
      
      // First create a temporary user for tenant creation
      const tempUser = new User({
        email: 'temp@system.com',
        password: 'TempPass123!',
        firstName: 'System',
        lastName: 'Temp',
        userType: 'technical',
        globalRole: 'tech',
        tenantId: new mongoose.Types.ObjectId(), // Temporary tenant ID
        isActive: true,
        isVerified: true
      });
      
      await tempUser.save();
      
      techTenant = new Tenant({
        name: 'Maritime Procurement System',
        slug: 'maritime-procurement-system',
        description: 'System administration tenant for tech users',
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
        owner: tempUser._id,
        createdBy: tempUser._id
      });
      
      await techTenant.save();
      
      // Update temp user with correct tenant ID
      tempUser.tenantId = techTenant._id;
      await tempUser.save();
      
      logger.info('✅ Created tech tenant');
    }
    
    // Create the tech user
    const techUser = new User({
      email: email.toLowerCase(),
      password: password,
      firstName: 'Jayandra',
      lastName: 'Admin',
      userType: 'technical',
      globalRole: 'tech',
      tenantId: techTenant._id,
      companyName: 'Maritime Procurement System',
      jobTitle: 'System Administrator',
      department: 'IT',
      vesselType: 'other',
      vesselSize: 'medium',
      procurementExperience: 0,
      preferredCurrency: 'USD',
      timezone: 'UTC',
      isActive: true,
      isVerified: true,
      isEmailVerified: true,
      isPhoneVerified: false,
      preferences: {
        notifications: {
          email: {
            rfqUpdates: true,
            quoteUpdates: true,
            orderUpdates: true,
            systemUpdates: true
          },
          push: {
            rfqUpdates: true,
            quoteUpdates: true,
            orderUpdates: true
          }
        },
        dashboard: {
          defaultView: 'overview',
          itemsPerPage: 20
        },
        procurement: {
          autoApproveQuotes: false,
          requireApproval: true,
          defaultCurrency: 'USD'
        }
      }
    });
    
    await techUser.save();
    
    // Update tenant owner
    techTenant.owner = techUser._id;
    techTenant.createdBy = techUser._id;
    await techTenant.save();
    
    logger.info(`✅ Successfully created tech user: ${email}`);
    logger.info(`🔑 Login credentials:`);
    logger.info(`   Email: ${email}`);
    logger.info(`   Password: ${password}`);
    logger.info(`   Role: Tech Super Admin (Global Access)`);
    logger.info(`   Portal: Technical Portal`);
    
    // Display user details
    const userDetails = {
      id: techUser._id,
      email: techUser.email,
      fullName: techUser.fullName,
      globalRole: techUser.globalRole,
      userType: techUser.userType,
      tenant: {
        id: techTenant._id,
        name: techTenant.name,
        slug: techTenant.slug
      },
      isActive: techUser.isActive,
      isVerified: techUser.isVerified
    };
    
    console.log('\n🎉 Tech User Created Successfully!');
    console.log('=====================================');
    console.log(JSON.stringify(userDetails, null, 2));
    console.log('=====================================');
    
  } catch (error) {
    logger.error('Failed to seed tech user:', error);
    throw error;
  }
};

/**
 * Run the seeding process
 */
const runSeed = async () => {
  try {
    await seedTechUser();
    logger.info('🎉 Tech user seeding completed successfully!');
    process.exit(0);
  } catch (error) {
    logger.error('❌ Tech user seeding failed:', error);
    process.exit(1);
  }
};

// Run if called directly
if (require.main === module) {
  runSeed();
}

module.exports = { seedTechUser };
