const winston = require('winston');
const DailyRotateFile = require('winston-daily-rotate-file');
const { env } = require('./env');
const path = require('path');

// Define log levels
const logLevels = {
  error: 0,
  warn: 1,
  info: 2,
  debug: 3,
};

// Create logs directory if it doesn't exist
const logsDir = path.join(__dirname, '../../logs');

// Define log format
const logFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss.SSS' }),
  winston.format.errors({ stack: true }),
  winston.format.splat(),
  winston.format.json()
);

// Console format (pretty print for development)
const consoleFormat = winston.format.combine(
  winston.format.colorize(),
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  winston.format.printf(({ timestamp, level, message, correlationId, service, ...meta }) => {
    let log = `${timestamp} [${level}]`;
    if (correlationId) log += ` [${correlationId}]`;
    if (service) log += ` [${service}]`;
    log += `: ${message}`;
    if (Object.keys(meta).length > 0) {
      log += ` ${JSON.stringify(meta)}`;
    }
    return log;
  })
);

// Create transports
const transports = [];

// Console transport (always enabled)
transports.push(
  new winston.transports.Console({
    format: env.server.nodeEnv === 'development' ? consoleFormat : logFormat,
    level: env.server.logLevel || 'info',
  })
);

// File transports (only in production or if LOG_TO_FILE is enabled)
if (env.server.nodeEnv === 'production' || process.env.LOG_TO_FILE === 'true') {
  // Error log file
  transports.push(
    new DailyRotateFile({
      filename: path.join(logsDir, 'error-%DATE%.log'),
      datePattern: 'YYYY-MM-DD',
      level: 'error',
      format: logFormat,
      maxSize: '20m',
      maxFiles: '14d',
      zippedArchive: true,
    })
  );

  // Combined log file
  transports.push(
    new DailyRotateFile({
      filename: path.join(logsDir, 'combined-%DATE%.log'),
      datePattern: 'YYYY-MM-DD',
      format: logFormat,
      maxSize: '20m',
      maxFiles: '14d',
      zippedArchive: true,
    })
  );
}

// Create logger instance
const logger = winston.createLogger({
  levels: logLevels,
  level: env.server.logLevel || 'info',
  format: logFormat,
  transports,
  exitOnError: false,
});

// Winston's child method is already available, no need to override

// Helper to generate correlation ID
logger.generateCorrelationId = () => {
  return `req-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
};

module.exports = logger;

