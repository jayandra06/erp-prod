const { createLogger } = require('../config/logging');
const axios = require('axios');

const logger = createLogger('errorHandler');

// Custom error class for application errors
class AppError extends Error {
  constructor(message, statusCode, isOperational = true) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';

    Error.captureStackTrace(this, this.constructor);
  }
}

// Handle different types of errors
const handleCastErrorDB = (err) => {
  const message = `Invalid ${err.path}: ${err.value}`;
  return new AppError(message, 400);
};

const handleDuplicateFieldsDB = (err) => {
  const value = err.errmsg.match(/(["'])(\\?.)*?\1/)[0];
  const message = `Duplicate field value: ${value}. Please use another value!`;
  return new AppError(message, 400);
};

const handleValidationErrorDB = (err) => {
  const errors = Object.values(err.errors).map(el => el.message);
  const message = `Invalid input data. ${errors.join('. ')}`;
  return new AppError(message, 400);
};

const handleJWTError = () =>
  new AppError('Invalid token. Please log in again!', 401);

const handleJWTExpiredError = () =>
  new AppError('Your token has expired! Please log in again.', 401);

// Send error to Jira (for production monitoring)
const sendErrorToJira = async (error, req) => {
  try {
    if (process.env.NODE_ENV !== 'production' || !process.env.JIRA_URL) {
      return;
    }

    const jiraData = {
      fields: {
        project: { key: process.env.JIRA_PROJECT_KEY || 'MPE' },
        summary: `Backend Error: ${error.message}`,
        description: `
**Error Details:**
- Message: ${error.message}
- Stack: \`\`\`${error.stack}\`\`\`
- URL: ${req.originalUrl}
- Method: ${req.method}
- IP: ${req.ip}
- User Agent: ${req.get('User-Agent')}
- Timestamp: ${new Date().toISOString()}
        `,
        issuetype: { name: 'Bug' },
        priority: { name: error.statusCode >= 500 ? 'High' : 'Medium' },
        labels: ['backend-error', 'maritime-procurement']
      }
    };

    await axios.post(
      `${process.env.JIRA_URL}/rest/api/3/issue`,
      jiraData,
      {
        headers: {
          'Authorization': `Basic ${Buffer.from(`${process.env.JIRA_USERNAME}:${process.env.JIRA_API_TOKEN}`).toString('base64')}`,
          'Content-Type': 'application/json'
        }
      }
    );

    logger.info('Error sent to Jira successfully');
  } catch (jiraError) {
    logger.error('Failed to send error to Jira:', jiraError);
  }
};

// Development error response
const sendErrorDev = (err, res) => {
  res.status(err.statusCode).json({
    status: err.status,
    error: err,
    message: err.message,
    stack: err.stack
  });
};

// Production error response
const sendErrorProd = (err, res) => {
  // Operational, trusted error: send message to client
  if (err.isOperational) {
    res.status(err.statusCode).json({
      status: err.status,
      message: err.message
    });
  } else {
    // Programming or other unknown error: don't leak error details
    logger.error('ERROR 💥', err);
    
    res.status(500).json({
      status: 'error',
      message: 'Something went wrong!'
    });
  }
};

// Main error handling middleware
const errorHandler = async (err, req, res, next) => {
  err.statusCode = err.statusCode || 500;
  err.status = err.status || 'error';

  // Log the error
  logger.error('Error occurred:', {
    message: err.message,
    stack: err.stack,
    url: req.originalUrl,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('User-Agent')
  });

  // Send critical errors to Jira
  if (err.statusCode >= 500) {
    await sendErrorToJira(err, req);
  }

  let error = { ...err };
  error.message = err.message;

  if (error.name === 'CastError') error = handleCastErrorDB(error);
  if (error.code === 11000) error = handleDuplicateFieldsDB(error);
  if (error.name === 'ValidationError') error = handleValidationErrorDB(error);
  if (error.name === 'JsonWebTokenError') error = handleJWTError();
  if (error.name === 'TokenExpiredError') error = handleJWTExpiredError();

  if (process.env.NODE_ENV === 'development') {
    sendErrorDev(error, res);
  } else {
    sendErrorProd(error, res);
  }
};

// 404 handler
const notFound = (req, res, next) => {
  const error = new AppError(`Not found - ${req.originalUrl}`, 404);
  next(error);
};

// Async error wrapper
const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

module.exports = {
  AppError,
  errorHandler,
  notFound,
  asyncHandler
};
