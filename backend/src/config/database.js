const { Pool } = require('pg');
const { env } = require('./env');
const logger = require('./logger');

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

  const dbLogger = logger.child({ service: 'database' });
  pool.on('error', (err) => {
    dbLogger.error('Unexpected error on idle PostgreSQL client', { error: err.message, stack: err.stack });
  });

  return pool;
}

async function testConnection() {
  const dbLogger = logger.child({ service: 'database' });
  try {
    const testPool = createPool();
    const result = await testPool.query('SELECT NOW()');
    dbLogger.info('PostgreSQL connection established', {
      database: env.postgres.database,
      host: env.postgres.host,
      port: env.postgres.port,
    });
    return true;
  } catch (error) {
    dbLogger.error('PostgreSQL connection failed', {
      error: error.message,
      stack: error.stack,
    });
    return false;
  }
}

async function query(text, params) {
  const dbLogger = logger.child({ service: 'database' });
  const dbPool = createPool();
  const start = Date.now();
  try {
    const result = await dbPool.query(text, params);
    const duration = Date.now() - start;
    dbLogger.debug('Query executed', {
      duration: `${duration}ms`,
      query: text.substring(0, 100),
    });
    return result;
  } catch (error) {
    dbLogger.error('Database query error', {
      error: error.message,
      stack: error.stack,
      query: text.substring(0, 100),
    });
    throw error;
  }
}

module.exports = {
  createPool,
  testConnection,
  query,
  getPool: createPool,
};

