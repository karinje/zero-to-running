import axios from 'axios';
import { API_CONFIG, API_ENDPOINTS } from '../config/api';

/**
 * Create axios instance with default configuration
 */
const apiClient = axios.create({
  baseURL: API_CONFIG.baseURL,
  timeout: API_CONFIG.timeout,
  headers: {
    'Content-Type': 'application/json',
  },
});

/**
 * Request interceptor
 */
apiClient.interceptors.request.use(
  (config) => {
    // Add any auth tokens or headers here if needed
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

/**
 * Response interceptor
 */
apiClient.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    // Handle common errors
    if (error.response) {
      // Server responded with error status
      console.error('API Error:', error.response.status, error.response.data);
    } else if (error.request) {
      // Request made but no response
      console.error('Network Error:', error.request);
    } else {
      // Something else happened
      console.error('Error:', error.message);
    }
    return Promise.reject(error);
  }
);

/**
 * API Service Methods
 */
export const apiService = {
  /**
   * Check backend health
   */
  async checkHealth() {
    const response = await apiClient.get(API_ENDPOINTS.health);
    return response.data;
  },

  /**
   * Get API info
   */
  async getApiInfo() {
    const response = await apiClient.get(API_ENDPOINTS.api);
    return response.data;
  },
};

export default apiService;

