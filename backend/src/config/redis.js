const { createClient } = require('redis');
const { env } = require('./env');
const logger = require('../utils/logger');

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

  client.on('error', (err) => {
    logger.error('Redis Client Error:', err);
  });

  client.on('connect', () => {
    logger.info('🔄 Redis connecting...');
  });

  client.on('ready', () => {
    logger.info('✅ Redis connection established');
    logger.info(`   Redis: ${env.redis.host}:${env.redis.port}`);
  });

  return client;
}

async function connect() {
  try {
    const redisClient = getRedisClient();
    if (!redisClient.isOpen) {
      await redisClient.connect();
    }
    return redisClient;
  } catch (error) {
    logger.error('❌ Redis connection failed:', error.message);
    throw error;
  }
}

async function testConnection() {
  try {
    const redisClient = await connect();
    await redisClient.ping();
    logger.info('✅ Redis connection test successful');
    return true;
  } catch (error) {
    logger.error('❌ Redis connection test failed:', error.message);
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

