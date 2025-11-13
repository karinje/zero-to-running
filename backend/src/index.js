const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const https = require('https');
const fs = require('fs');
const path = require('path');
const { validateEnv, env } = require('./config/env');
const requestLogger = require('./middleware/requestLogger');
const errorHandler = require('./middleware/errorHandler');
const indexRoutes = require('./routes/index');
const healthRoutes = require('./routes/health');
const logger = require('./config/logger');

// Validate environment variables
validateEnv();

// Initialize Express app
const app = express();

// Security middleware
app.use(helmet());

// CORS configuration
app.use(cors({
  origin: env.server.corsOrigin,
  credentials: true,
}));

// Request logging
if (env.server.nodeEnv === 'development') {
  app.use(morgan('dev'));
}
app.use(requestLogger);

// Body parsing middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use(`/api/${env.server.apiVersion}`, indexRoutes);
app.use('/health', healthRoutes);

// Root route
app.get('/', (req, res) => {
  res.json({
    message: 'Wander Backend API',
    version: env.server.apiVersion,
    endpoints: {
      health: '/health',
      api: `/api/${env.server.apiVersion}`,
    },
  });
});

// Error handling middleware (must be last)
app.use(errorHandler);

// Start server
const PORT = env.server.port;
const serverLogger = logger.child({ service: 'backend' });

if (env.server.enableSSL) {
  // HTTPS server
  const certPath = path.resolve(env.server.sslCert);
  const keyPath = path.resolve(env.server.sslKey);
  
  if (!fs.existsSync(certPath) || !fs.existsSync(keyPath)) {
    serverLogger.error('SSL certificates not found', {
      certPath,
      keyPath,
    });
    serverLogger.error('Generate certificates: make generate-certs');
    process.exit(1);
  }
  
  const options = {
    cert: fs.readFileSync(certPath),
    key: fs.readFileSync(keyPath),
  };
  
  https.createServer(options, app).listen(PORT, '0.0.0.0', () => {
    serverLogger.info('🚀 Backend server starting (HTTPS)...', {
      environment: env.server.nodeEnv,
      port: PORT,
      apiVersion: env.server.apiVersion,
      corsOrigin: env.server.corsOrigin,
      ssl: true,
    });
    serverLogger.info(`✅ Server running at https://0.0.0.0:${PORT}`);
    serverLogger.info(`   Health check: https://0.0.0.0:${PORT}/health`);
  });
} else {
  // HTTP server
  app.listen(PORT, '0.0.0.0', () => {
    serverLogger.info('🚀 Backend server starting...', {
      environment: env.server.nodeEnv,
      port: PORT,
      apiVersion: env.server.apiVersion,
      corsOrigin: env.server.corsOrigin,
      ssl: false,
    });
    serverLogger.info(`✅ Server running at http://0.0.0.0:${PORT}`);
    serverLogger.info(`   Health check: http://0.0.0.0:${PORT}/health`);
  });
}

// Graceful shutdown
process.on('SIGTERM', () => {
  serverLogger.info('SIGTERM received, shutting down gracefully...');
  process.exit(0);
});

process.on('SIGINT', () => {
  serverLogger.info('SIGINT received, shutting down gracefully...');
  process.exit(0);
});

module.exports = app;

