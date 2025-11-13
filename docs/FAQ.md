# Frequently Asked Questions (FAQ)

## General Questions

### Q: What is this project?
A: Zero-to-Running Developer Environment is a Docker Compose setup that provides a complete local development environment with PostgreSQL, Redis, Node.js backend, and React frontend - all with a single command.

### Q: How long does setup take?
A: First-time setup takes about 5-10 minutes, depending on your internet connection (for downloading Docker images). Subsequent starts take 30-60 seconds.

### Q: Do I need to install PostgreSQL/Redis/Node.js on my machine?
A: No! Everything runs in Docker containers. You only need Docker Desktop installed.

### Q: Can I use this in production?
A: This is designed for local development. For production, you'll need to configure proper security, scaling, and monitoring.

## Setup Questions

### Q: What are the prerequisites?
A: 
- Docker Desktop (or Docker Engine + Docker Compose)
- Git
- 4GB+ RAM (8GB recommended)
- 10GB+ free disk space

### Q: How do I get started?
A:
```bash
# 1. Clone the repository
git clone <repo-url>
cd zero-to-running

# 2. Copy environment file
cp .env.example .env

# 3. Start services
make dev
```

### Q: What ports are used?
A:
- 3000: Frontend (React)
- 4000: Backend API
- 5432: PostgreSQL
- 6379: Redis

### Q: Can I change the ports?
A: Yes, edit `.env` file:
```bash
FRONTEND_PORT=3001
BACKEND_PORT=4001
# etc.
```

## Usage Questions

### Q: How do I stop all services?
A:
```bash
make down
```

### Q: How do I restart services?
A:
```bash
make restart
# or
make down && make dev
```

### Q: How do I view logs?
A:
```bash
make logs              # All services
make logs-backend      # Backend only
make logs-frontend     # Frontend only
```

### Q: How do I access the database?
A:
```bash
make shell-db
# Then you're in psql
```

### Q: How do I seed the database?
A:
```bash
make db-seed
```

### Q: How do I reset the database?
A:
```bash
make db-reset
```

## Configuration Questions

### Q: Where are environment variables?
A: In the `.env` file (copy from `.env.example`)

### Q: Can I use my own database?
A: Yes, but this setup uses a local Dockerized PostgreSQL for isolation. To use an external database, modify `docker-compose.yml` and connection settings.

### Q: How do I change the database password?
A: Edit `POSTGRES_PASSWORD` in `.env`, then:
```bash
make down
make db-reset  # Recreates database with new password
make dev
```

### Q: How do I enable file logging?
A: Set in `.env`:
```bash
LOG_TO_FILE=true
```

## Troubleshooting Questions

### Q: Services won't start. What do I do?
A:
1. Run `make pre-flight` to check for issues
2. Check `make logs` for error messages
3. Verify Docker is running: `docker info`
4. Check ports: `make check-ports`

### Q: Port already in use. How do I fix it?
A:
```bash
# macOS/Linux
lsof -ti:3000 | xargs kill

# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### Q: Database connection failed. Why?
A:
1. Check `.env` has correct `POSTGRES_*` variables
2. Verify database container is running: `make ps`
3. Check database logs: `make logs-db`

### Q: Hot reload not working. Why?
A:
1. Check volume mounts in `docker-compose.yml`
2. Verify file changes are detected: `make logs-backend`
3. Restart: `make restart`

### Q: How do I completely reset everything?
A:
```bash
make down
make clean  # Removes all data
make dev
```

## Development Questions

### Q: How do I add a new service?
A:
1. Add service to `docker-compose.yml`
2. Add environment variables to `.env.example`
3. Update health checks if needed
4. Document in README

### Q: How do I debug the backend?
A:
1. View logs: `make logs-backend`
2. Access shell: `make shell-backend`
3. Check health: `make health`
4. Filter error logs: `make logs-filter LEVEL=error`

### Q: How do I debug the frontend?
A:
1. View logs: `make logs-frontend`
2. Access shell: `make shell-frontend`
3. Check browser console
4. Verify API connection: `curl http://localhost:4000/health`

### Q: How do I test API endpoints?
A:
```bash
# Health check
curl http://localhost:4000/health

# With correlation ID
curl -H "X-Correlation-ID: test-123" http://localhost:4000/health
```

## Data Questions

### Q: Where is database data stored?
A: In a Docker volume named `wander_postgres-data`. Data persists even after `make down`.

### Q: How do I backup the database?
A:
```bash
make db-backup
# Backup saved to backups/backup_YYYYMMDD_HHMMSS.sql
```

### Q: How do I restore from backup?
A:
```bash
make db-restore FILE=backups/backup_20251113_120000.sql
```

### Q: How do I clear all data?
A:
```bash
make clean  # Removes all volumes and data
```

## Performance Questions

### Q: Services are slow. Why?
A:
1. Check system resources: `docker stats`
2. Check disk space: `df -h`
3. Restart Docker Desktop
4. Clean up: `docker system prune`

### Q: How much memory does this use?
A: Approximately 1-2GB total:
- PostgreSQL: ~200-500MB
- Redis: ~50-100MB
- Backend: ~100-200MB
- Frontend: ~100-200MB
- Docker overhead: ~500MB

### Q: Can I limit resource usage?
A: Yes, resource limits are configured in `docker-compose.yml` under `deploy.resources.limits`.

## Security Questions

### Q: Are the default passwords secure?
A: No, they're for local development only. Change them in production:
- `POSTGRES_PASSWORD`
- `REDIS_PASSWORD`

### Q: Should I commit `.env`?
A: No! `.env` is in `.gitignore`. Only commit `.env.example`.

### Q: How do I handle secrets?
A: For local dev, use `.env`. For production, use a secrets management system (AWS Secrets Manager, HashiCorp Vault, etc.).

## Platform Questions

### Q: Does this work on Mac?
A: Yes, macOS 10.15+ with Docker Desktop.

### Q: Does this work on Windows?
A: Yes, Windows 10/11 with Docker Desktop (WSL2 recommended).

### Q: Does this work on Linux?
A: Yes, any Linux distribution with Docker Engine and Docker Compose.

### Q: Does this work on M1/M2 Macs?
A: Yes, Docker Desktop supports ARM architecture.

## Still Have Questions?

1. Check [Troubleshooting Guide](./TROUBLESHOOTING.md)
2. Review [Common Errors](./COMMON_ERRORS.md)
3. See [Debugging Guide](./DEBUGGING.md)
4. Open an issue on GitHub

