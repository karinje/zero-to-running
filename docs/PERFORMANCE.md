# Performance Optimization & Caching

This document describes performance optimizations and caching strategies implemented in the Zero-to-Running Developer Environment.

## Redis Caching

### Cache Service

The backend includes a Redis-based caching service for frequently accessed data.

**Usage**:
```javascript
const cache = require('./utils/cache');

// Get from cache
const data = await cache.get('user:123');

// Set in cache (TTL: 1 hour default)
await cache.set('user:123', userData);

// Set with custom TTL (seconds)
await cache.set('user:123', userData, 1800); // 30 minutes

// Delete from cache
await cache.del('user:123');

// Clear by pattern
await cache.clear('user:*');
```

### Cache Middleware

Automatic caching for GET endpoints:

```javascript
const cacheMiddleware = require('./middleware/cache');

// Cache for 1 hour (default)
app.get('/api/users', cacheMiddleware(), getUsers);

// Cache for 30 minutes
app.get('/api/products', cacheMiddleware(1800), getProducts);
```

## Database Query Optimization

### Connection Pooling

PostgreSQL connection pooling is configured for optimal performance:
- Max connections: 20
- Idle timeout: 30 seconds
- Connection timeout: 2 seconds

### Query Optimization Tips

1. **Use indexes** on frequently queried columns
2. **Limit results** with pagination
3. **Use SELECT specific columns** instead of SELECT *
4. **Batch operations** when possible
5. **Use transactions** for multiple related operations

## Best Practices

1. **Cache expensive operations** - Database queries, API calls
2. **Set appropriate TTLs** - Balance freshness vs performance
3. **Invalidate cache** - When data changes, clear related cache
4. **Monitor cache hit rates** - Adjust caching strategy based on metrics
5. **Use cache patterns** - Consistent key naming (e.g., `user:123`, `product:456`)

## Performance Monitoring

Check Redis cache statistics:

```bash
make shell-redis
> INFO stats
```

## Cache Invalidation

When data changes, invalidate related cache:

```javascript
// After updating user
await updateUser(userId, data);
await cache.del(`user:${userId}`);
await cache.clear('users:list:*');
```

