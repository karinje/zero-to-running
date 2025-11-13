# Backend API Documentation

## Overview

The backend is a Node.js/Express API server that provides REST endpoints and connects to PostgreSQL and Redis services.

## Base URL

- **Development**: `http://localhost:4000`
- **API Version**: `v1` (configurable via `API_VERSION` env var)

## Endpoints

### Health Check

**GET** `/health`

Returns the health status of the backend and its dependencies.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2025-11-13T02:30:00.000Z",
  "services": {
    "database": "healthy",
    "redis": "healthy"
  }
}
```

**Status Codes:**
- `200` - All services healthy
- `503` - One or more services unhealthy

### API Root

**GET** `/api/v1`

Returns API information.

**Response:**
```json
{
  "message": "Wander Backend API",
  "version": "v1",
  "environment": "development",
  "timestamp": "2025-11-13T02:30:00.000Z"
}
```

### Root

**GET** `/`

Returns API overview with available endpoints.

**Response:**
```json
{
  "message": "Wander Backend API",
  "version": "v1",
  "endpoints": {
    "health": "/health",
    "api": "/api/v1"
  }
}
```

## Environment Variables

All configuration is managed via `.env` file:

```bash
# Database
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=wander_dev
POSTGRES_USER=wander_user
POSTGRES_PASSWORD=dev_password_change_in_prod

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=dev_redis_password

# Server
BACKEND_PORT=4000
NODE_ENV=development
LOG_LEVEL=debug
API_VERSION=v1
CORS_ORIGIN=http://localhost:3000
```

## Development

### Running Locally (without Docker)

```bash
cd backend
npm install
npm run dev
```

### Running in Docker

```bash
# Start all services
docker-compose up backend

# Or start in background
docker-compose up -d backend
```

### Hot Reload

The backend uses `nodemon` for automatic restart on file changes. Edit files in `backend/src/` and the server will automatically restart.

## Logging

Logs are output to console with timestamps and log levels:

- **ERROR**: Critical errors
- **WARN**: Warnings
- **INFO**: General information
- **DEBUG**: Detailed debugging (only in development)

Set log level via `LOG_LEVEL` environment variable.

## Error Handling

All errors are caught by the error handling middleware and returned as JSON:

```json
{
  "error": {
    "message": "Error message",
    "statusCode": 500,
    "stack": "..." // Only in development
  }
}
```

## CORS

CORS is configured to allow requests from the frontend origin (default: `http://localhost:3000`). Configure via `CORS_ORIGIN` environment variable.

## Database Connection

The backend uses a connection pool for PostgreSQL:

- Maximum 20 connections
- Idle timeout: 30 seconds
- Connection timeout: 2 seconds

## Redis Connection

Redis client is created on startup and reused for all requests. Connection is tested on health check endpoint.

## Troubleshooting

### Backend won't start

1. Check environment variables are set correctly
2. Verify PostgreSQL and Redis are running
3. Check logs: `docker-compose logs backend`

### Connection errors

1. Verify service names in `.env` match Docker service names
2. Check network: `docker network inspect wander_wander-network`
3. Test connections manually from backend container

### Hot reload not working

1. Verify volume mount in `docker-compose.yml`
2. Check `nodemon.json` configuration
3. Ensure files are being saved

