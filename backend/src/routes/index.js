const express = require('express');
const router = express.Router();
const { env } = require('../config/env');

router.get('/', (req, res) => {
  res.json({
    message: 'Wander Backend API',
    version: env.server.apiVersion,
    environment: env.server.nodeEnv,
    timestamp: new Date().toISOString(),
  });
});

module.exports = router;

