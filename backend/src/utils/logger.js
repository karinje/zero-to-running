const { env } = require('../config/env');

const logLevels = {
  error: 0,
  warn: 1,
  info: 2,
  debug: 3,
};

const currentLogLevel = logLevels[env.server.logLevel] || logLevels.info;

function getTimestamp() {
  return new Date().toISOString();
}

function formatMessage(level, message, ...args) {
  const timestamp = getTimestamp();
  const prefix = `[${timestamp}] [${level.toUpperCase()}]`;
  
  if (args.length > 0) {
    return `${prefix} ${message} ${args.join(' ')}`;
  }
  return `${prefix} ${message}`;
}

const logger = {
  error: (message, ...args) => {
    if (currentLogLevel >= logLevels.error) {
      console.error(formatMessage('error', message, ...args));
    }
  },
  
  warn: (message, ...args) => {
    if (currentLogLevel >= logLevels.warn) {
      console.warn(formatMessage('warn', message, ...args));
    }
  },
  
  info: (message, ...args) => {
    if (currentLogLevel >= logLevels.info) {
      console.log(formatMessage('info', message, ...args));
    }
  },
  
  debug: (message, ...args) => {
    if (currentLogLevel >= logLevels.debug) {
      console.log(formatMessage('debug', message, ...args));
    }
  },
};

module.exports = logger;

