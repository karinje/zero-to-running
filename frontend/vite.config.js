import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0',
    port: 3000,
    https: process.env.ENABLE_SSL === 'true' ? {
      cert: process.env.SSL_CERT_PATH || './certs/localhost-cert.pem',
      key: process.env.SSL_KEY_PATH || './certs/localhost-key.pem',
    } : false,
    watch: {
      usePolling: true, // Required for Docker hot reload
    },
    hmr: {
      clientPort: 3000, // Match the exposed port
    },
  },
  resolve: {
    alias: {
      '@': '/src',
    },
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './tests/setup.js',
  },
});

