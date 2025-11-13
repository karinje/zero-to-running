# Advanced Usage Guide

This guide covers advanced commands and features of the Zero-to-Running Developer Environment.

## Testing Commands

### Run All Tests
```bash
make test
```

### Run Backend Tests Only
```bash
make test-backend
```

### Run Frontend Tests Only
```bash
make test-frontend
```

**Note:** Testing framework will be fully implemented in PR-016. For now, you can run tests manually:
```bash
docker-compose exec backend npm test
docker-compose exec frontend npm test
```

## Code Quality Commands

### Lint All Code
```bash
make lint
```
Lints both backend and frontend code using ESLint.

### Auto-fix Linting Issues
```bash
make lint-fix
```
Automatically fixes linting issues where possible.

### Format Code
```bash
make format
```
**Note:** Code formatting with Prettier will be added in PR-015.

## Database Commands

### Backup Database
```bash
make db-backup
```
Creates a timestamped backup in `backups/` directory.

### Restore Database
```bash
make db-restore FILE=backups/backup_20251113_120000.sql
```
Restores database from a backup file.

### Run Migrations
```bash
make db-migrate
```
**Note:** Migration system will be implemented when needed.

### Rollback Migration
```bash
make db-rollback
```
**Note:** Rollback will be implemented with migration system.

## Docker Maintenance Commands

### Clean Up Unused Resources
```bash
make prune
```
Removes:
- Stopped containers
- Unused images
- Unused volumes
- Unused networks

**Warning:** This removes unused resources. Your running containers and volumes are safe.

### Rebuild All Images
```bash
make rebuild
```
Rebuilds all Docker images from scratch (no cache).

### Rebuild Specific Service
```bash
make rebuild-backend
make rebuild-frontend
```
Rebuilds only the specified service.

### Update Dependencies
```bash
make update
```
Updates npm dependencies in running containers. Rebuild images to use updated dependencies:
```bash
make update
make rebuild
```

## Shortcuts

### Quick Start/Stop
```bash
make up    # Alias for make dev
make stop  # Alias for make down
```

## Command Auto-completion

### Bash
Add to `~/.bashrc`:
```bash
source /path/to/zero-to-running/scripts/completions/make-completion.bash
```

### Zsh
Add to `~/.zshrc`:
```bash
source /path/to/zero-to-running/scripts/completions/make-completion.zsh
```

After adding, restart your shell or run:
```bash
source ~/.bashrc  # or ~/.zshrc
```

Now you can use tab completion:
```bash
make <TAB>  # Shows all available commands
```

## Advanced Logging

### Filter Logs by Level
```bash
make logs-filter LEVEL=error
make logs-filter LEVEL=warn
make logs-filter LEVEL=info
make logs-filter LEVEL=debug
```

### Filter Logs by Service
```bash
make logs-filter SERVICE=backend
make logs-filter SERVICE=frontend
make logs-filter SERVICE=postgres
make logs-filter SERVICE=redis
```

### Aggregate Logs
```bash
make logs-aggregate
```
Shows logs from all services sorted by timestamp.

## Performance Monitoring

### Check Resource Usage
```bash
docker stats
```

### Check Disk Usage
```bash
docker system df
```

### Monitor Specific Container
```bash
docker stats wander-backend
docker stats wander-frontend
```

## Development Workflow

### Typical Development Session

1. **Start services:**
   ```bash
   make dev
   ```

2. **Make code changes** (hot reload enabled)

3. **Check logs:**
   ```bash
   make logs-backend
   ```

4. **Run linting:**
   ```bash
   make lint
   ```

5. **Test changes:**
   ```bash
   curl http://localhost:4000/health
   ```

6. **Stop services:**
   ```bash
   make down
   ```

### Debugging Workflow

1. **Identify issue:**
   ```bash
   make health
   make logs
   ```

2. **Filter error logs:**
   ```bash
   make logs-filter LEVEL=error
   ```

3. **Access container:**
   ```bash
   make shell-backend
   ```

4. **Test fixes:**
   ```bash
   make restart
   make health
   ```

## Customization

### Change Ports
Edit `.env`:
```bash
FRONTEND_PORT=3001
BACKEND_PORT=4001
```

### Change Resource Limits
Edit `docker-compose.yml`:
```yaml
deploy:
  resources:
    limits:
      memory: 1g
      cpus: '1.0'
```

### Add New Service
1. Add service to `docker-compose.yml`
2. Add environment variables to `.env.example`
3. Update health checks
4. Document in README

## Tips and Tricks

### Quick Database Access
```bash
# One-liner query
docker-compose exec -T postgres psql -U wander_user -d wander_dev -c "SELECT COUNT(*) FROM app.users;"
```

### Quick API Test
```bash
# Health check with correlation ID
curl -H "X-Correlation-ID: test-123" http://localhost:4000/health
```

### View Recent Logs Only
```bash
docker-compose logs --tail=50 backend
```

### Follow Logs for Specific Time
```bash
docker-compose logs --since 10m backend
```

### Export Logs
```bash
make logs > logs.txt
make logs-backend > backend-logs.txt
```

## Troubleshooting Advanced Issues

### Container Won't Rebuild
```bash
make down
docker-compose build --no-cache backend
make dev
```

### Dependencies Out of Sync
```bash
make down
make rebuild
make dev
```

### Disk Space Issues
```bash
make prune
docker system prune -a
```

### Network Issues
```bash
docker network ls
docker network inspect wander-network
docker network prune
make dev
```

## Best Practices

1. **Always run pre-flight checks:**
   ```bash
   make pre-flight
   ```

2. **Keep dependencies updated:**
   ```bash
   make update
   make rebuild
   ```

3. **Clean up regularly:**
   ```bash
   make prune
   ```

4. **Backup before major changes:**
   ```bash
   make db-backup
   ```

5. **Use correlation IDs for debugging:**
   ```bash
   curl -H "X-Correlation-ID: debug-123" http://localhost:4000/api/v1/users
   make logs-filter SERVICE=backend | grep "debug-123"
   ```

## Next Steps

- See [Troubleshooting Guide](./TROUBLESHOOTING.md) for common issues
- See [Logging Guide](./LOGGING.md) for logging details
- See [FAQ](./FAQ.md) for frequently asked questions

