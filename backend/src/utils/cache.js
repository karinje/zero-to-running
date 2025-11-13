const { getClient } = require('../config/redis');
const logger = require('../config/logger');

const cacheLogger = logger.child({ service: 'cache' });

class CacheService {
  constructor() {
    this.client = null;
    this.defaultTTL = 3600; // 1 hour
  }

  async connect() {
    if (!this.client) {
      this.client = await getClient();
    }
    return this.client;
  }

  async get(key) {
    try {
      await this.connect();
      const value = await this.client.get(key);
      if (value) {
        cacheLogger.debug('Cache hit', { key });
        return JSON.parse(value);
      }
      cacheLogger.debug('Cache miss', { key });
      return null;
    } catch (error) {
      cacheLogger.error('Cache get error', { key, error: error.message });
      return null;
    }
  }

  async set(key, value, ttl = this.defaultTTL) {
    try {
      await this.connect();
      const serialized = JSON.stringify(value);
      await this.client.setEx(key, ttl, serialized);
      cacheLogger.debug('Cache set', { key, ttl });
      return true;
    } catch (error) {
      cacheLogger.error('Cache set error', { key, error: error.message });
      return false;
    }
  }

  async del(key) {
    try {
      await this.connect();
      await this.client.del(key);
      cacheLogger.debug('Cache deleted', { key });
      return true;
    } catch (error) {
      cacheLogger.error('Cache delete error', { key, error: error.message });
      return false;
    }
  }

  async clear(pattern) {
    try {
      await this.connect();
      const keys = await this.client.keys(pattern);
      if (keys.length > 0) {
        await this.client.del(keys);
        cacheLogger.debug('Cache cleared', { pattern, count: keys.length });
      }
      return keys.length;
    } catch (error) {
      cacheLogger.error('Cache clear error', { pattern, error: error.message });
      return 0;
    }
  }
}

module.exports = new CacheService();

