const express = require('express');
const router = express.Router();
const db = require('../config/database');
const redis = require('../config/redis');

router.get('/', async (req, res) => {
  const health = {
    status: 'ok',
    timestamp: new Date().toISOString(),
    services: {
      database: 'unknown',
      redis: 'unknown',
    },
  };

  try {
    // Test database connection
    const dbHealthy = await db.testConnection();
    health.services.database = dbHealthy ? 'healthy' : 'unhealthy';

    // Test Redis connection
    const redisHealthy = await redis.testConnection();
    health.services.redis = redisHealthy ? 'healthy' : 'unhealthy';

    // Overall status
    const allHealthy = dbHealthy && redisHealthy;
    health.status = allHealthy ? 'ok' : 'degraded';

    const statusCode = allHealthy ? 200 : 503;
    res.status(statusCode).json(health);
  } catch (error) {
    health.status = 'error';
    health.error = error.message;
    res.status(503).json(health);
  }
});

module.exports = router;

