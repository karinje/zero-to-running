const logger = require('../config/logger');

// Generate correlation ID if not present
function generateCorrelationId() {
  return `req-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}

function requestLogger(req, res, next) {
  // Generate or use existing correlation ID
  const correlationId = req.headers['x-correlation-id'] || generateCorrelationId();
  req.correlationId = correlationId;
  
  // Add correlation ID to response headers
  res.setHeader('X-Correlation-ID', correlationId);
  
  // Create child logger with correlation ID and service name
  req.logger = logger.child({
    correlationId,
    service: 'backend',
  });
  
  const start = Date.now();
  
  // Log request
  req.logger.info('Incoming request', {
    method: req.method,
    url: req.originalUrl,
    ip: req.ip,
    userAgent: req.get('user-agent'),
  });
  
  // Log response when finished
  res.on('finish', () => {
    const duration = Date.now() - start;
    const logData = {
      method: req.method,
      url: req.originalUrl,
      statusCode: res.statusCode,
      duration: `${duration}ms`,
      ip: req.ip,
    };
    
    if (res.statusCode >= 500) {
      req.logger.error('Request failed', logData);
    } else if (res.statusCode >= 400) {
      req.logger.warn('Request error', logData);
    } else {
      req.logger.info('Request completed', logData);
    }
  });
  
  next();
}

module.exports = requestLogger;

