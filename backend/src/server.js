const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const morgan = require('morgan');
const cookieParser = require('cookie-parser');
const path = require('path');
const fs = require('fs');

// Import configurations
require('dotenv').config();
const { connectDB } = require('./config/database');
const { setupLogging } = require('./config/logging');
const { setupSwagger } = require('./config/swagger');
const { errorHandler, notFound } = require('./middleware/errorHandler');
const { initializeRBAC } = require('./middleware/rbac');

const app = express();

// Setup logging
const logger = setupLogging();

// Connect to MongoDB Atlas (temporarily disabled for development)
// connectDB();

// Security middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  crossOriginEmbedderPolicy: false
}));

// CORS configuration
const corsOptions = {
  origin: function (origin, callback) {
    const allowedOrigins = process.env.CORS_ORIGINS?.split(',') || [
      'http://localhost:3000',
      'http://localhost:8080',
      'http://localhost:8081',
      'http://localhost:8082',
      'http://localhost:8083',
      'http://localhost:8084',
      'http://localhost:8085',
      'http://localhost:45749', // Flutter web development server
      'http://127.0.0.1:45749', // Alternative localhost format
    ];
    
    // Allow requests with no origin (mobile apps, Postman, etc.)
    if (!origin) return callback(null, true);
    
    // Allow all localhost origins for development
    if (origin.includes('localhost') || origin.includes('127.0.0.1')) {
      return callback(null, true);
    }
    
    if (allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  optionsSuccessStatus: 200,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
};

app.use(cors(corsOptions));

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  message: {
    error: 'Too many requests from this IP, please try again later.',
    retryAfter: Math.ceil((parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000) / 1000)
  },
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => {
    // Skip rate limiting for health checks
    return req.path === '/health';
  }
});

app.use('/api/', limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(cookieParser(process.env.COOKIE_SECRET));

// Compression middleware
app.use(compression());

// Logging middleware
if (process.env.NODE_ENV === 'production') {
  app.use(morgan('combined', {
    stream: fs.createWriteStream(path.join(__dirname, '../logs/access.log'), { flags: 'a' })
  }));
} else {
  app.use(morgan('dev'));
}

// Static files
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
    version: process.env.npm_package_version || '1.0.0',
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    database: 'development_mode' // Temporarily disabled for development
  });
});

// API Routes
app.use('/api/auth', require('./routes/mock_auth')); // Using mock auth for development
// app.use('/api/auth', require('./routes/auth')); // Original auth (requires database)
app.use('/api/roles', require('./routes/roles'));
app.use('/api/technical', require('./routes/technical'));

// TODO: Implement these routes
// app.use('/api/users', require('./routes/users'));
// app.use('/api/tenants', require('./routes/tenants'));
// app.use('/api/admin', require('./routes/admin'));
// app.use('/api/customers', require('./routes/customers'));
// app.use('/api/vendors', require('./routes/vendors'));

// Setup Swagger documentation
setupSwagger(app);

// Error handling middleware (must be last)
app.use(notFound);
app.use(errorHandler);

// Initialize RBAC system (temporarily disabled)
// initializeRBAC().catch((error) => {
//   logger.error('Failed to initialize RBAC system:', error);
//   // Don't exit the process, continue without RBAC
//   logger.warn('Continuing without RBAC - some features may be limited');
// });

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  mongoose.connection.close(() => {
    logger.info('MongoDB connection closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  mongoose.connection.close(() => {
    logger.info('MongoDB connection closed');
    process.exit(0);
  });
});

const PORT = process.env.PORT || 5000;
const HOST = process.env.HOST || '0.0.0.0';

app.listen(PORT, HOST, () => {
  logger.info(`🚀 Maritime Procurement ERP Backend running on ${HOST}:${PORT}`);
  logger.info(`📊 Environment: ${process.env.NODE_ENV}`);
  logger.info(`🔗 Health check: http://${HOST}:${PORT}/health`);
  logger.info(`📚 API Documentation: http://${HOST}:${PORT}/api-docs`);
});

module.exports = app;
