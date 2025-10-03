const mongoose = require('mongoose');
const { createLogger } = require('./logging');

const logger = createLogger('database');

const connectDB = async () => {
  try {
    const mongoURI = process.env.MONGODB_URI;
    
    if (!mongoURI) {
      throw new Error('MONGODB_URI environment variable is not set');
    }

    const options = {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
      bufferCommands: false
    };

    // Parse additional options from environment
    if (process.env.MONGODB_OPTIONS) {
      try {
        const additionalOptions = JSON.parse(process.env.MONGODB_OPTIONS);
        Object.assign(options, additionalOptions);
      } catch (error) {
        logger.warn('Failed to parse MONGODB_OPTIONS, using defaults');
      }
    }

    const conn = await mongoose.connect(mongoURI, options);

    logger.info(`📊 MongoDB Connected: ${conn.connection.host}`);

    // Connection event handlers
    mongoose.connection.on('connected', () => {
      logger.info('MongoDB connection established');
    });

    mongoose.connection.on('error', (err) => {
      logger.error('MongoDB connection error:', err);
    });

    mongoose.connection.on('disconnected', () => {
      logger.warn('MongoDB disconnected');
    });

    // Handle application termination
    process.on('SIGINT', async () => {
      await mongoose.connection.close();
      logger.info('MongoDB connection closed through app termination');
      process.exit(0);
    });

  } catch (error) {
    logger.error('Database connection failed:', error);
    process.exit(1);
  }
};

module.exports = { connectDB };
