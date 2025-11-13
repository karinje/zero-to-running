const logger = require('../config/logger');

function errorHandler(err, req, res, next) {
  const correlationId = req.correlationId || 'unknown';
  const errorLogger = logger.child({ 
    correlationId,
    service: 'backend',
    error: true,
  });

  errorLogger.error('Request error', {
    message: err.message,
    stack: err.stack,
    statusCode: err.statusCode || 500,
    method: req.method,
    url: req.originalUrl,
  });

  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';

  res.status(statusCode).json({
    error: {
      message,
      statusCode,
      correlationId,
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    },
  });
}

module.exports = errorHandler;

