# Database Documentation

## Overview

The development environment uses **PostgreSQL 15.2** running in a Docker container. Each developer has their own isolated database instance with no external dependencies.

## Connection Details

### From Host Machine

```bash
# Using psql command line
psql -h localhost -p 5432 -U wander_user -d wander_dev

# Password: dev_password_change_in_prod (or whatever you set in .env)
```

### From Backend Application

```javascript
// Connection string format
postgresql://wander_user:dev_password_change_in_prod@postgres:5432/wander_dev

// Using environment variables
const connectionString = `postgresql://${process.env.POSTGRES_USER}:${process.env.POSTGRES_PASSWORD}@${process.env.POSTGRES_HOST}:${process.env.POSTGRES_PORT}/${process.env.POSTGRES_DB}`;
```

### From Docker Containers

Services connect using the service name `postgres` (not `localhost`):

```javascript
// Correct (from within Docker network)
host: 'postgres'
port: 5432

// Wrong (won't work from containers)
host: 'localhost'
```

## Environment Variables

All database configuration is managed via `.env` file:

```bash
POSTGRES_HOST=postgres          # Docker service name
POSTGRES_PORT=5432              # Port exposed to host
POSTGRES_DB=wander_dev          # Database name
POSTGRES_USER=wander_user        # Database user
POSTGRES_PASSWORD=dev_password_change_in_prod  # Database password
```

## Data Persistence

Database data is stored in a Docker volume named `postgres_data`. This means:

- ✅ Data persists when containers are stopped (`make down`)
- ✅ Data persists when containers are restarted
- ❌ Data is removed when volumes are deleted (`make clean`)

## Initialization

When the database container is first created, it automatically runs:

1. `docker/postgres/init/01-init-db.sql` - Sets up initial schema and extensions

The initialization script:
- Creates required extensions (uuid-ossp, pg_trgm)
- Creates an `app` schema for application tables
- Sets up a sample `users` table (for demonstration)

## Health Checks

The database includes a health check that verifies:

- PostgreSQL is ready to accept connections
- Database is accessible with configured credentials
- Health check runs every 5 seconds

## Common Operations

### Connect via Docker

```bash
# Access PostgreSQL shell
docker exec -it wander-postgres psql -U wander_user -d wander_dev

# Or using docker-compose
docker-compose exec postgres psql -U wander_user -d wander_dev
```

### View Database Logs

```bash
docker-compose logs postgres
# or
make logs-db
```

### Backup Database

```bash
# Create backup
docker exec wander-postgres pg_dump -U wander_user wander_dev > backup.sql

# Restore backup
docker exec -i wander-postgres psql -U wander_user wander_dev < backup.sql
```

### Reset Database

```bash
# Stop and remove volumes (WARNING: deletes all data)
make clean
make dev
```

## Schema Management

### Current Schema

- **Schema**: `app` (default search path)
- **Extensions**: uuid-ossp, pg_trgm
- **Sample Table**: `app.users` (for demonstration)

### Adding Tables

Add your table creation scripts to:
- `docker/postgres/init/02-your-schema.sql` (for initialization)
- Or use migrations in your backend application

## Troubleshooting

### Connection Refused

**Problem**: Can't connect to database

**Solutions**:
1. Check if container is running: `docker ps | grep postgres`
2. Check health status: `make health`
3. Check logs: `make logs-db`
4. Verify environment variables in `.env`

### Port Already in Use

**Problem**: Port 5432 is already in use

**Solutions**:
1. Change `POSTGRES_PORT` in `.env` to a different port (e.g., 5433)
2. Stop other PostgreSQL instances: `brew services stop postgresql` (Mac)

### Data Not Persisting

**Problem**: Data disappears after restart

**Solutions**:
1. Verify volume exists: `docker volume ls | grep postgres_data`
2. Check volume mount in `docker-compose.yml`
3. Ensure you're using `make down` (not `make clean`) to preserve data

### Permission Denied

**Problem**: Can't access database

**Solutions**:
1. Verify credentials in `.env` match what you're using
2. Check user has proper permissions
3. Ensure database exists: `docker-compose exec postgres psql -U wander_user -l`

## Production Notes

⚠️ **This is a development database only!**

- Uses simple password authentication (not production-ready)
- No SSL/TLS encryption
- No connection pooling limits
- No backup automation
- Data stored locally (not replicated)

For production, use:
- Managed PostgreSQL service (AWS RDS, Google Cloud SQL, etc.)
- Proper secret management
- SSL/TLS encryption
- Automated backups
- Connection pooling
- High availability setup

