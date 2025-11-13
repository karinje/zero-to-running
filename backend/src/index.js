const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
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
app.listen(PORT, '0.0.0.0', () => {
  const serverLogger = logger.child({ service: 'backend' });
  serverLogger.info('🚀 Backend server starting...', {
    environment: env.server.nodeEnv,
    port: PORT,
    apiVersion: env.server.apiVersion,
    corsOrigin: env.server.corsOrigin,
  });
  serverLogger.info(`✅ Server running at http://0.0.0.0:${PORT}`);
  serverLogger.info(`   Health check: http://0.0.0.0:${PORT}/health`);
});

// Graceful shutdown
const serverLogger = logger.child({ service: 'backend' });
process.on('SIGTERM', () => {
  serverLogger.info('SIGTERM received, shutting down gracefully...');
  process.exit(0);
});

process.on('SIGINT', () => {
  serverLogger.info('SIGINT received, shutting down gracefully...');
  process.exit(0);
});

module.exports = app;

