require('dotenv').config();

const requiredEnvVars = [
  'POSTGRES_HOST',
  'POSTGRES_PORT',
  'POSTGRES_DB',
  'POSTGRES_USER',
  'POSTGRES_PASSWORD',
  'REDIS_HOST',
  'REDIS_PORT',
  'REDIS_PASSWORD',
  'BACKEND_PORT'
];

function validateEnv() {
  const missing = requiredEnvVars.filter(key => !process.env[key]);
  
  if (missing.length > 0) {
    console.error('❌ Missing required environment variables:');
    missing.forEach(key => console.error(`   - ${key}`));
    console.error('\nPlease check your .env file.');
    process.exit(1);
  }
  
  console.log('✅ Environment variables validated');
}

module.exports = {
  validateEnv,
  env: {
    // Database
    postgres: {
      host: process.env.POSTGRES_HOST,
      port: parseInt(process.env.POSTGRES_PORT, 10),
      database: process.env.POSTGRES_DB,
      user: process.env.POSTGRES_USER,
      password: process.env.POSTGRES_PASSWORD,
    },
    // Redis
    redis: {
      host: process.env.REDIS_HOST,
      port: parseInt(process.env.REDIS_PORT, 10),
      password: process.env.REDIS_PASSWORD,
    },
    // Server
    server: {
      port: parseInt(process.env.BACKEND_PORT, 10) || 4000,
      nodeEnv: process.env.NODE_ENV || 'development',
      logLevel: process.env.LOG_LEVEL || 'info',
      apiVersion: process.env.API_VERSION || 'v1',
      corsOrigin: process.env.CORS_ORIGIN || 'http://localhost:3000',
      enableSSL: process.env.ENABLE_SSL === 'true',
      sslCert: process.env.SSL_CERT_PATH || './certs/localhost-cert.pem',
      sslKey: process.env.SSL_KEY_PATH || './certs/localhost-key.pem',
    },
  },
};

