# Common Errors and Solutions

Quick reference for common error messages and their solutions.

## Docker Errors

### `Error: Docker is not installed`
**Solution:**
```bash
# Install Docker Desktop
# macOS: https://www.docker.com/products/docker-desktop
# Linux: See INSTALL_DOCKER.md
# Windows: Download Docker Desktop
```

### `Error: Docker is not running`
**Solution:**
- Start Docker Desktop application
- Wait for whale icon in system tray
- Verify: `docker info`

### `Cannot connect to the Docker daemon`
**Solution:**
```bash
# Linux: Start Docker service
sudo systemctl start docker

# macOS/Windows: Start Docker Desktop
```

## Port Errors

### `Port 3000 is in use`
**Solution:**
```bash
# macOS/Linux
lsof -ti:3000 | xargs kill

# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### `Bind for 0.0.0.0:4000 failed: port is already allocated`
**Solution:** Same as above, replace port number.

## Environment Errors

### `Error: .env file not found`
**Solution:**
```bash
cp .env.example .env
```

### `Missing required variable: POSTGRES_PASSWORD`
**Solution:**
1. Check `.env` file exists
2. Verify all required variables are set
3. Run: `make validate-env`

## Database Errors

### `PostgreSQL connection failed`
**Solution:**
1. Check database is running: `make ps`
2. Verify credentials in `.env`
3. Check logs: `make logs-db`
4. Reset database: `make db-reset`

### `FATAL: password authentication failed`
**Solution:**
- Check `POSTGRES_PASSWORD` in `.env` matches
- Reset database: `make db-reset`

### `database "wander_dev" does not exist`
**Solution:**
```bash
make db-reset
```

## Redis Errors

### `Redis connection failed`
**Solution:**
1. Check Redis is running: `make ps`
2. Verify `REDIS_PASSWORD` in `.env`
3. Check logs: `make logs-redis`

### `WRONGPASS invalid username-password pair`
**Solution:**
- Check `REDIS_PASSWORD` in `.env`
- Restart Redis: `make restart` (or restart specific service)

## Container Errors

### `Container "wander-backend" is restarting`
**Solution:**
1. Check logs: `make logs-backend`
2. Verify environment variables: `make validate-env`
3. Rebuild: `docker-compose build backend`

### `No such container: wander-backend`
**Solution:**
- Container hasn't started yet
- Check: `make ps`
- Start services: `make dev`

### `Cannot start service backend: driver failed programming external connectivity`
**Solution:**
- Port conflict (see port errors above)
- Check: `make check-ports`

## Network Errors

### `Network "wander-network" not found`
**Solution:**
```bash
make down
make dev
```

### `Cannot connect to the Docker daemon at unix:///var/run/docker.sock`
**Solution:**
- Docker daemon not running
- Start Docker Desktop
- Linux: `sudo systemctl start docker`

## File System Errors

### `Permission denied`
**Solution:**
```bash
# Linux: Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in
```

### `No space left on device`
**Solution:**
```bash
# Clean up Docker
make clean
docker system prune -a
```

## Build Errors

### `npm ERR! Missing script: "seed"`
**Solution:**
- Rebuild backend image:
```bash
docker-compose build backend
make dev
```

### `npm ERR! The npm ci command can only install with an existing package-lock.json`
**Solution:**
- This is fixed in the Dockerfile
- Rebuild: `docker-compose build --no-cache backend`

## Application Errors

### `ECONNREFUSED 127.0.0.1:5432`
**Solution:**
- Database not running
- Check: `make ps`
- Start: `make dev`

### `CORS policy: No 'Access-Control-Allow-Origin' header`
**Solution:**
- Check `CORS_ORIGIN` in `.env`
- Verify backend is running
- Restart backend: `make restart`

### `Cannot GET /api/v1/users`
**Solution:**
- Check backend is running: `make health`
- Verify route exists
- Check logs: `make logs-backend`

## Log Errors

### `Log file too large`
**Solution:**
- Log rotation is automatic
- Clean old logs: `docker system prune`
- Check disk space: `df -h`

## Still Seeing an Error?

1. Check logs: `make logs`
2. Run pre-flight: `make pre-flight`
3. See [Troubleshooting Guide](./TROUBLESHOOTING.md)
4. Check [Debugging Guide](./DEBUGGING.md)

