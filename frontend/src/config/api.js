/**
 * API Configuration
 * Centralized configuration for API endpoints
 */

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:4000';
const API_VERSION = import.meta.env.VITE_API_VERSION || 'v1';

export const API_CONFIG = {
  baseURL: API_URL,
  apiVersion: API_VERSION,
  timeout: 10000,
};

export const API_ENDPOINTS = {
  health: '/health',
  api: `/api/${API_VERSION}`,
};

export default API_CONFIG;

