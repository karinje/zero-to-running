const { Pool } = require('pg');
const { env } = require('./env');
const logger = require('../utils/logger');

let pool = null;

function createPool() {
  if (pool) {
    return pool;
  }

  pool = new Pool({
    host: env.postgres.host,
    port: env.postgres.port,
    database: env.postgres.database,
    user: env.postgres.user,
    password: env.postgres.password,
    max: 20, // Maximum number of clients in the pool
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
  });

  pool.on('error', (err) => {
    logger.error('Unexpected error on idle PostgreSQL client', err);
  });

  return pool;
}

async function testConnection() {
  try {
    const testPool = createPool();
    const result = await testPool.query('SELECT NOW()');
    logger.info('✅ PostgreSQL connection established');
    logger.info(`   Database: ${env.postgres.database} on ${env.postgres.host}:${env.postgres.port}`);
    return true;
  } catch (error) {
    logger.error('❌ PostgreSQL connection failed:', error.message);
    return false;
  }
}

async function query(text, params) {
  const dbPool = createPool();
  const start = Date.now();
  try {
    const result = await dbPool.query(text, params);
    const duration = Date.now() - start;
    logger.debug(`Query executed in ${duration}ms: ${text.substring(0, 50)}...`);
    return result;
  } catch (error) {
    logger.error('Database query error:', error);
    throw error;
  }
}

module.exports = {
  createPool,
  testConnection,
  query,
  getPool: createPool,
};

