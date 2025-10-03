const express = require('express');
const jwt = require('jsonwebtoken');
const { createLogger } = require('../config/logging');

const router = express.Router();
const logger = createLogger('mock-auth');

// Mock user data for development
const mockUsers = {
  'jayandraa5@gmail.com': {
    id: '68df022a9fc753b3b2ed06d0',
    email: 'jayandraa5@gmail.com',
    firstName: 'Jayandra',
    lastName: 'Admin',
    fullName: 'Jayandra Admin',
    userType: 'technical',
    globalRole: 'tech',
    companyName: 'Maritime Procurement System',
    vesselType: 'other',
    preferredCurrency: 'USD',
    isVerified: true,
    tenant: {
      id: '68df022a9fc753b3b2ed06cd',
      name: 'Maritime Procurement System',
      slug: 'maritime-procurement-system',
      subscription: {
        plan: 'enterprise',
        status: 'active',
        maxUsers: 999999,
        maxStorage: 999999,
        maxRFQs: 999999,
        maxQuotes: 999999
      }
    }
  }
};

// Mock passwords for development
const mockPasswords = {
  'jayandraa5@gmail.com': 'J@yandra06'
};

/**
 * Mock login endpoint for development
 */
router.post('/login', (req, res) => {
  try {
    const { email, password, userType } = req.body;

    // Validate required fields
    if (!email || !password || !userType) {
      return res.status(400).json({
        message: 'Email, password, and userType are required'
      });
    }

    // Check if user exists
    const user = mockUsers[email.toLowerCase()];
    if (!user) {
      return res.status(401).json({
        message: 'Invalid credentials'
      });
    }

    // Check password
    if (mockPasswords[email.toLowerCase()] !== password) {
      return res.status(401).json({
        message: 'Invalid credentials'
      });
    }

    // Check user type
    if (user.userType !== userType) {
      return res.status(401).json({
        message: 'Invalid user type for this portal'
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET || 'dev-secret',
      { expiresIn: '7d' }
    );

    logger.info(`✅ Mock login successful: ${email} (${userType})`);

    res.json({
      message: 'Login successful',
      token: token,
      user: user
    });

  } catch (error) {
    logger.error('Mock login error:', error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
});

/**
 * Mock current user endpoint
 */
router.get('/me', (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        message: 'Authorization token required'
      });
    }

    const token = authHeader.substring(7);
    
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'dev-secret');
      const user = mockUsers[decoded.email];
      
      if (!user) {
        return res.status(401).json({
          message: 'Invalid token'
        });
      }

      res.json({
        user: user
      });
    } catch (jwtError) {
      return res.status(401).json({
        message: 'Invalid token'
      });
    }

  } catch (error) {
    logger.error('Mock me error:', error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
});

/**
 * Mock logout endpoint
 */
router.post('/logout', (req, res) => {
  logger.info('✅ Mock logout successful');
  res.json({
    message: 'Logout successful'
  });
});

module.exports = router;

