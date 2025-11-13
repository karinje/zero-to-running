# Debugging Guide

Techniques and tools for debugging issues in the Zero-to-Running Developer Environment.

## Quick Debugging Checklist

1. ✅ Run pre-flight checks: `make pre-flight`
2. ✅ Check service health: `make health`
3. ✅ View logs: `make logs`
4. ✅ Check running containers: `make ps`
5. ✅ Verify environment: `make validate-env`

## Service Health Checks

### Check All Services
```bash
make health
```

Expected output:
```
✓ Frontend: healthy
✓ Backend: healthy
✓ Database: healthy
✓ Redis: healthy
```

### Check Individual Service
```bash
# Backend health endpoint
curl http://localhost:4000/health

# Should return:
{
  "status": "ok",
  "services": {
    "database": "healthy",
    "redis": "healthy"
  }
}
```

## Log Analysis

### View All Logs
```bash
make logs
```

### View Service-Specific Logs
```bash
make logs-backend
make logs-frontend
make logs-db
make logs-redis
```

### Filter Logs by Level
```bash
make logs-filter LEVEL=error
make logs-filter LEVEL=warn
```

### Filter Logs by Service
```bash
make logs-filter SERVICE=backend
```

### Aggregate Logs
```bash
make logs-aggregate
```

### Search Logs
```bash
# Search for errors
docker-compose logs | grep -i error

# Search for specific correlation ID
docker-compose logs | grep "req-123-456"

# Search last 100 lines
docker-compose logs --tail=100 | grep "error"
```

## Container Inspection

### List Running Containers
```bash
make ps
# or
docker ps
```

### Inspect Container
```bash
# Get container details
docker inspect wander-backend

# Get container logs
docker logs wander-backend

# Get container stats
docker stats wander-backend
```

### Access Container Shell
```bash
make shell-backend
make shell-frontend
make shell-db
make shell-redis
```

### Execute Commands in Container
```bash
# Run command in backend
docker-compose exec backend npm list

# Run command in database
docker-compose exec postgres psql -U wander_user -d wander_dev -c "SELECT version();"
```

## Network Debugging

### List Networks
```bash
docker network ls
```

### Inspect Network
```bash
docker network inspect wander-network
```

### Test Connectivity
```bash
# From host to backend
curl http://localhost:4000/health

# From backend container to database
docker-compose exec backend ping postgres

# From backend container to redis
docker-compose exec backend ping redis
```

### Check Port Mappings
```bash
docker port wander-backend
docker port wander-frontend
```

## Database Debugging

### Connect to Database
```bash
make shell-db
```

### Run SQL Queries
```bash
# Direct query
docker-compose exec -T postgres psql -U wander_user -d wander_dev -c "SELECT COUNT(*) FROM app.users;"

# Interactive shell
make shell-db
```

### Check Database Size
```bash
docker-compose exec postgres psql -U wander_user -d wander_dev -c "SELECT pg_size_pretty(pg_database_size('wander_dev'));"
```

### List Tables
```bash
docker-compose exec postgres psql -U wander_user -d wander_dev -c "\dt app.*"
```

### Check Connections
```bash
docker-compose exec postgres psql -U wander_user -d wander_dev -c "SELECT count(*) FROM pg_stat_activity;"
```

## Redis Debugging

### Connect to Redis
```bash
make shell-redis
```

### Test Redis Connection
```bash
docker-compose exec redis redis-cli -a dev_redis_password ping
# Should return: PONG
```

### Get Redis Info
```bash
docker-compose exec redis redis-cli -a dev_redis_password INFO
```

### Monitor Redis Commands
```bash
docker-compose exec redis redis-cli -a dev_redis_password MONITOR
```

## Backend Debugging

### Check Backend Logs
```bash
make logs-backend
```

### Test API Endpoints
```bash
# Health check
curl http://localhost:4000/health

# With correlation ID
curl -H "X-Correlation-ID: debug-123" http://localhost:4000/health

# Verbose output
curl -v http://localhost:4000/health
```

### Check Environment Variables
```bash
docker-compose exec backend env | grep -E "POSTGRES|REDIS|NODE"
```

### Check Node Version
```bash
docker-compose exec backend node --version
```

### Check Installed Packages
```bash
docker-compose exec backend npm list
```

## Frontend Debugging

### Check Frontend Logs
```bash
make logs-frontend
```

### Access Frontend in Browser
```bash
# Open in browser
open http://localhost:3000  # macOS
xdg-open http://localhost:3000  # Linux
start http://localhost:3000  # Windows
```

### Check Browser Console
- Open DevTools (F12)
- Check Console tab for errors
- Check Network tab for API calls

### Test API Connection
```bash
# From browser console
fetch('http://localhost:4000/health')
  .then(r => r.json())
  .then(console.log)
```

## Performance Debugging

### Check Resource Usage
```bash
docker stats
```

### Check Disk Usage
```bash
df -h
docker system df
```

### Check Memory Usage
```bash
# macOS/Linux
free -h  # Linux
vm_stat  # macOS

# Docker
docker stats --no-stream
```

## Common Debugging Scenarios

### Services Won't Start
```bash
# 1. Check pre-flight
make pre-flight

# 2. Check Docker
docker info

# 3. Check ports
make check-ports

# 4. Check logs
make logs
```

### Database Connection Issues
```bash
# 1. Check database is running
make ps

# 2. Check database logs
make logs-db

# 3. Test connection
make shell-db
# Then: SELECT 1;

# 4. Check environment variables
make validate-env
```

### API Not Responding
```bash
# 1. Check backend is running
make health

# 2. Check backend logs
make logs-backend

# 3. Test endpoint
curl http://localhost:4000/health

# 4. Check CORS
curl -H "Origin: http://localhost:3000" http://localhost:4000/health
```

### Frontend Can't Connect to Backend
```bash
# 1. Check backend is running
curl http://localhost:4000/health

# 2. Check CORS configuration
grep CORS_ORIGIN .env

# 3. Check browser console for errors
# 4. Check network tab in DevTools
```

## Advanced Debugging

### Enable Debug Logging
```bash
# In .env
LOG_LEVEL=debug

# Restart services
make restart
```

### Trace Requests
```bash
# Use correlation ID
curl -H "X-Correlation-ID: trace-123" http://localhost:4000/api/v1/users

# Then filter logs
make logs-filter SERVICE=backend | grep "trace-123"
```

### Monitor Real-time Logs
```bash
# Follow all logs
make logs

# Follow specific service
make logs-backend
```

### Check Docker Events
```bash
docker events
```

## Debugging Tools

### Docker Compose Commands
```bash
# Validate configuration
docker-compose config

# Show service dependencies
docker-compose config --services

# Show environment variables
docker-compose config | grep -A 5 "environment:"
```

### System Information
```bash
# Docker version
docker --version
docker-compose --version

# System info
uname -a
```

## Getting Help

When asking for help, include:

1. **Error message** (full text)
2. **Logs**: `make logs > logs.txt`
3. **Platform**: macOS/Linux/Windows
4. **Docker version**: `docker --version`
5. **Steps to reproduce**
6. **What you've tried**

## Still Stuck?

1. Review [Troubleshooting Guide](./TROUBLESHOOTING.md)
2. Check [Common Errors](./COMMON_ERRORS.md)
3. Review [FAQ](./FAQ.md)
4. Open an issue with debugging information

