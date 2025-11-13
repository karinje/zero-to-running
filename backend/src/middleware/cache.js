const cache = require('../utils/cache');

function cacheMiddleware(ttl = 3600) {
  return async (req, res, next) => {
    // Only cache GET requests
    if (req.method !== 'GET') {
      return next();
    }

    const cacheKey = `cache:${req.originalUrl}`;
    
    // Try to get from cache
    const cached = await cache.get(cacheKey);
    if (cached) {
      return res.json(cached);
    }

    // Store original json method
    const originalJson = res.json.bind(res);
    
    // Override json to cache response
    res.json = function (data) {
      // Cache the response
      cache.set(cacheKey, data, ttl).catch(err => {
        // Log but don't fail request
        console.error('Cache set error:', err);
      });
      
      // Call original json
      return originalJson(data);
    };

    next();
  };
}

module.exports = cacheMiddleware;

