const { createClient } = require('redis');
const { env } = require('./env');
const logger = require('./logger');

let client = null;

function getRedisClient() {
  if (client && client.isOpen) {
    return client;
  }

  client = createClient({
    socket: {
      host: env.redis.host,
      port: env.redis.port,
    },
    password: env.redis.password,
  });

  const redisLogger = logger.child({ service: 'redis' });
  client.on('error', (err) => {
    redisLogger.error('Redis Client Error', {
      error: err.message,
      stack: err.stack,
    });
  });

  client.on('connect', () => {
    redisLogger.info('Redis connecting...');
  });

  client.on('ready', () => {
    redisLogger.info('Redis connection established', {
      host: env.redis.host,
      port: env.redis.port,
    });
  });

  return client;
}

async function connect() {
  const redisLogger = logger.child({ service: 'redis' });
  try {
    const redisClient = getRedisClient();
    if (!redisClient.isOpen) {
      await redisClient.connect();
    }
    return redisClient;
  } catch (error) {
    redisLogger.error('Redis connection failed', {
      error: error.message,
      stack: error.stack,
    });
    throw error;
  }
}

async function testConnection() {
  const redisLogger = logger.child({ service: 'redis' });
  try {
    const redisClient = await connect();
    await redisClient.ping();
    redisLogger.info('Redis connection test successful');
    return true;
  } catch (error) {
    redisLogger.error('Redis connection test failed', {
      error: error.message,
      stack: error.stack,
    });
    return false;
  }
}

function getClient() {
  return getRedisClient();
}

module.exports = {
  connect,
  testConnection,
  getClient,
};

