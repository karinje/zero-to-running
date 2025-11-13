# Redis Documentation

## Overview

The development environment uses **Redis 7.0.5** running in a Docker container. Redis serves as a cache and session store for the application. Each developer has their own isolated Redis instance with no external dependencies.

## Connection Details

### From Host Machine

```bash
# Using redis-cli command line
redis-cli -h localhost -p 6379 -a dev_redis_password

# Or if redis-cli is not installed, use Docker
docker exec -it wander-redis redis-cli -a dev_redis_password
```

### From Backend Application

```javascript
// Connection string format
redis://:dev_redis_password@redis:6379

// Using environment variables
const redis = require('redis');
const client = redis.createClient({
  host: process.env.REDIS_HOST,
  port: process.env.REDIS_PORT,
  password: process.env.REDIS_PASSWORD
});
```

### From Docker Containers

Services connect using the service name `redis` (not `localhost`):

```javascript
// Correct (from within Docker network)
host: 'redis'
port: 6379

// Wrong (won't work from containers)
host: 'localhost'
```

## Environment Variables

All Redis configuration is managed via `.env` file:

```bash
REDIS_HOST=redis                    # Docker service name
REDIS_PORT=6379                     # Port exposed to host
REDIS_PASSWORD=dev_redis_password   # Redis password
```

## Data Persistence

Redis data is stored in a Docker volume named `redis_data`. This means:

- ✅ Data persists when containers are stopped (`make down`)
- ✅ Data persists when containers are restarted
- ✅ AOF (Append Only File) enabled for durability
- ❌ Data is removed when volumes are deleted (`make clean`)

## Configuration

Redis uses a custom configuration file at `docker/redis/redis.conf` with:

- **Persistence**: AOF enabled with `everysec` sync
- **Memory**: 256MB limit with LRU eviction policy
- **Security**: Password protected (development password)
- **Databases**: 16 databases available (0-15)

## Health Checks

The Redis service includes a health check that verifies:

- Redis is accepting commands
- Connection is working
- Health check runs every 5 seconds

## Common Operations

### Connect via Docker

```bash
# Access Redis CLI
docker exec -it wander-redis redis-cli -a dev_redis_password

# Or using docker-compose
docker-compose exec redis redis-cli -a dev_redis_password
```

### Basic Redis Commands

```redis
# Test connection
PING
# Should return: PONG

# Set a key
SET mykey "Hello Redis"

# Get a key
GET mykey

# Check if key exists
EXISTS mykey

# Set expiration (TTL)
SET mykey "value" EX 60

# List all keys (use with caution in production)
KEYS *

# Get info
INFO

# Flush all data (WARNING: deletes everything)
FLUSHALL
```

### View Redis Logs

```bash
docker-compose logs redis
# or
make logs-redis
```

### Monitor Commands in Real-Time

```bash
docker exec -it wander-redis redis-cli -a dev_redis_password MONITOR
```

## Connection Pooling

### Node.js Example

```javascript
const redis = require('redis');

// Create connection pool
const client = redis.createClient({
  socket: {
    host: process.env.REDIS_HOST,
    port: process.env.REDIS_PORT
  },
  password: process.env.REDIS_PASSWORD
});

// Handle connection events
client.on('error', (err) => console.error('Redis Client Error', err));
client.on('connect', () => console.log('Redis Connected'));
client.on('ready', () => console.log('Redis Ready'));

await client.connect();

// Use connection
await client.set('key', 'value');
const value = await client.get('key');
```

### Python Example

```python
import redis

# Create connection pool
r = redis.Redis(
    host=os.getenv('REDIS_HOST', 'redis'),
    port=int(os.getenv('REDIS_PORT', 6379)),
    password=os.getenv('REDIS_PASSWORD'),
    decode_responses=True
)

# Test connection
r.ping()  # Returns True if connected

# Use connection
r.set('key', 'value')
value = r.get('key')
```

## Troubleshooting

### Connection Refused

**Problem**: Can't connect to Redis

**Solutions**:
1. Check if container is running: `docker ps | grep redis`
2. Check health status: `make health`
3. Check logs: `make logs-redis`
4. Verify environment variables in `.env`

### Port Already in Use

**Problem**: Port 6379 is already in use

**Solutions**:
1. Change `REDIS_PASSWORD` in `.env` to a different port (e.g., 6380)
2. Stop other Redis instances: `brew services stop redis` (Mac)

### Authentication Failed

**Problem**: Getting "NOAUTH Authentication required"

**Solutions**:
1. Verify password in `.env` matches what you're using
2. Use `-a` flag with redis-cli: `redis-cli -a your_password`
3. Check Redis config file has correct password

### Data Not Persisting

**Problem**: Data disappears after restart

**Solutions**:
1. Verify volume exists: `docker volume ls | grep redis_data`
2. Check volume mount in `docker-compose.yml`
3. Ensure AOF is enabled in `redis.conf`
4. Use `make down` (not `make clean`) to preserve data

### Memory Limit Reached

**Problem**: Redis returns errors about memory

**Solutions**:
1. Check memory usage: `docker exec wander-redis redis-cli INFO memory`
2. Increase `maxmemory` in `redis.conf` (if needed)
3. Clear old keys: `docker exec wander-redis redis-cli FLUSHDB`

## Production Notes

⚠️ **This is a development Redis instance only!**

- Uses simple password authentication (not production-ready)
- No SSL/TLS encryption
- Limited memory (256MB)
- No replication or clustering
- Data stored locally (not replicated)

For production, use:
- Managed Redis service (AWS ElastiCache, Redis Cloud, etc.)
- Proper secret management
- SSL/TLS encryption
- Higher memory limits
- Replication and high availability
- Connection pooling with proper limits

