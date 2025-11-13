# Troubleshooting Guide

This guide helps you resolve common issues when setting up and running the Zero-to-Running Developer Environment.

## Quick Decision Tree

```
Having an issue?
│
├─ Services won't start?
│  ├─ Docker not running? → Start Docker Desktop
│  ├─ Port conflicts? → Free ports (3000, 4000, 5432, 6379)
│  └─ Missing .env? → Copy .env.example to .env
│
├─ Services start but crash?
│  ├─ Check logs: make logs
│  ├─ Database connection failed? → Check POSTGRES_* vars
│  └─ Redis connection failed? → Check REDIS_PASSWORD
│
├─ Can't access services?
│  ├─ Check ports: make check-ports
│  ├─ Check health: make health
│  └─ Check firewall/antivirus
│
└─ Other issues?
   └─ See sections below
```

## Common Issues

### 1. Docker Not Installed or Running

**Symptoms:**
- `Error: Docker is not installed`
- `Error: Docker is not running`

**Solutions:**
1. Install Docker Desktop: https://www.docker.com/products/docker-desktop
2. Start Docker Desktop application
3. Wait for Docker to fully start (whale icon in system tray)
4. Verify: `docker info`

**See:** [INSTALL_DOCKER.md](./INSTALL_DOCKER.md)

### 2. Port Conflicts

**Symptoms:**
- `Port 3000 is in use`
- `Port 4000 is in use`
- Services fail to start

**Solutions:**

**macOS/Linux:**
```bash
# Find process using port
lsof -ti:3000

# Kill process
lsof -ti:3000 | xargs kill
```

**Windows:**
```powershell
# Find process
netstat -ano | findstr :3000

# Kill process (replace PID)
taskkill /PID <PID> /F
```

**Prevention:**
- Run `make check-ports` before starting
- Stop other services using these ports

### 3. Missing .env File

**Symptoms:**
- `Error: .env file not found`
- Services can't connect to database

**Solutions:**
```bash
# Copy example file
cp .env.example .env

# Edit if needed
nano .env  # or use your preferred editor
```

### 4. Database Connection Failed

**Symptoms:**
- `PostgreSQL connection failed`
- Health check shows database as unhealthy

**Solutions:**
1. Check environment variables:
   ```bash
   make validate-env
   ```

2. Verify database is running:
   ```bash
   make ps
   make logs-db
   ```

3. Check credentials in `.env`:
   - `POSTGRES_USER`
   - `POSTGRES_PASSWORD`
   - `POSTGRES_DB`

4. Reset database:
   ```bash
   make db-reset
   ```

### 5. Redis Connection Failed

**Symptoms:**
- `Redis connection failed`
- Health check shows redis as unhealthy

**Solutions:**
1. Check `REDIS_PASSWORD` in `.env`
2. Verify Redis is running: `make logs-redis`
3. Test connection: `make shell-redis`

### 6. Permission Denied Errors

**Symptoms:**
- `Permission denied` when running commands
- Can't access Docker

**Solutions:**

**Linux:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in
```

**macOS/Windows:**
- Usually not an issue with Docker Desktop
- Check Docker Desktop is running with proper permissions

### 7. Out of Disk Space

**Symptoms:**
- `No space left on device`
- Docker build fails

**Solutions:**
```bash
# Clean up Docker
make clean
docker system prune -a

# Check disk space
df -h
```

### 8. Container Crashes on Startup

**Symptoms:**
- Container starts then immediately stops
- `make ps` shows containers as "Exited"

**Solutions:**
1. Check logs:
   ```bash
   make logs
   make logs-backend  # or specific service
   ```

2. Check environment variables:
   ```bash
   make validate-env
   ```

3. Rebuild containers:
   ```bash
   make down
   docker-compose build --no-cache
   make dev
   ```

### 9. Hot Reload Not Working

**Symptoms:**
- Code changes don't reflect in running app
- Need to restart manually

**Solutions:**
1. Check volume mounts in `docker-compose.yml`
2. Verify file changes are being detected:
   ```bash
   make logs-backend
   # Should see nodemon restart messages
   ```

3. Restart service:
   ```bash
   make restart
   ```

### 10. Environment Variables Not Loading

**Symptoms:**
- Services use wrong configuration
- Default values being used

**Solutions:**
1. Verify `.env` file exists and has correct values
2. Check variable names match `.env.example`
3. Restart services:
   ```bash
   make down
   make dev
   ```

### 11. CORS Errors

**Symptoms:**
- `Access-Control-Allow-Origin` errors in browser
- Frontend can't call backend API

**Solutions:**
1. Check `CORS_ORIGIN` in `.env`:
   ```bash
   CORS_ORIGIN=http://localhost:3000
   ```

2. Verify backend is running: `make health`
3. Check browser console for specific error

### 12. Network Connectivity Issues

**Symptoms:**
- Services can't communicate
- Connection timeouts

**Solutions:**
1. Check Docker network:
   ```bash
   docker network ls
   docker network inspect wander-network
   ```

2. Verify services are on same network
3. Check firewall/antivirus isn't blocking Docker

## Platform-Specific Issues

### macOS (M1/M2)

**Issue:** Images not compatible with ARM architecture

**Solution:**
- Use `--platform linux/amd64` flag (if needed)
- Most images now support ARM natively

### Windows (WSL2)

**Issue:** Docker Desktop not using WSL2

**Solution:**
1. Enable WSL2 in Docker Desktop settings
2. Install WSL2: `wsl --install`
3. Restart Docker Desktop

**Issue:** File permissions in WSL2

**Solution:**
- Files should be in WSL2 filesystem, not Windows
- Use `/home/username/...` paths, not `/mnt/c/...`

### Linux

**Issue:** Docker daemon not running

**Solution:**
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

## Debugging Techniques

### 1. Check Service Health
```bash
make health
```

### 2. View All Logs
```bash
make logs
```

### 3. View Specific Service Logs
```bash
make logs-backend
make logs-frontend
make logs-db
make logs-redis
```

### 4. Filter Logs
```bash
make logs-filter LEVEL=error
make logs-filter SERVICE=backend
```

### 5. Access Container Shell
```bash
make shell-backend
make shell-frontend
make shell-db
make shell-redis
```

### 6. Check Running Containers
```bash
make ps
docker ps -a
```

### 7. Inspect Container
```bash
docker inspect wander-backend
docker inspect wander-frontend
```

### 8. Check Network
```bash
docker network ls
docker network inspect wander-network
```

### 9. Check Volumes
```bash
docker volume ls
docker volume inspect wander_postgres-data
```

### 10. Run Pre-flight Checks
```bash
make pre-flight
```

## Getting Help

If you've tried the solutions above and still have issues:

1. **Check logs:** `make logs` and look for error messages
2. **Run pre-flight:** `make pre-flight` to identify issues
3. **Check documentation:** Review README.md and other docs
4. **Search issues:** Check if others have encountered the same problem
5. **Create issue:** Include:
   - Error messages
   - Logs (`make logs`)
   - Platform (macOS/Linux/Windows)
   - Docker version (`docker --version`)
   - Steps to reproduce

## Prevention

To avoid common issues:

1. **Always run pre-flight checks:**
   ```bash
   make pre-flight
   ```

2. **Keep Docker updated:**
   - Update Docker Desktop regularly
   - Check for Docker updates

3. **Monitor disk space:**
   ```bash
   df -h
   ```

4. **Clean up regularly:**
   ```bash
   make clean  # When you don't need data
   docker system prune  # Remove unused resources
   ```

5. **Use version control:**
   - Commit `.env.example`
   - Never commit `.env` (it's in `.gitignore`)

## Still Stuck?

1. Review the [FAQ](./FAQ.md)
2. Check [Common Errors](./COMMON_ERRORS.md)
3. See [Debugging Guide](./DEBUGGING.md)
4. Open an issue with:
   - Full error logs
   - Platform information
   - Steps to reproduce

