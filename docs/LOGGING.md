# Logging Guide

This document describes the logging system used in the Zero-to-Running Developer Environment.

## Overview

The backend uses **Winston** for structured logging with:
- Multiple log levels (error, warn, info, debug)
- Correlation IDs for request tracing
- Service identification
- Log rotation (in production)
- JSON format for structured logs

## Log Levels

- **ERROR**: Errors that require attention (status 500+)
- **WARN**: Warnings (non-critical issues, status 400-499)
- **INFO**: General information (requests, connections)
- **DEBUG**: Development details (query execution, etc.)

## Log Format

### Development (Console)
```
2025-11-13 10:30:45 [INFO] [req-123-456] [backend]: Request completed
```

### Production (JSON)
```json
{
  "timestamp": "2025-11-13T10:30:45.123Z",
  "level": "INFO",
  "correlationId": "req-123-456",
  "service": "backend",
  "message": "Request completed",
  "method": "GET",
  "url": "/api/v1/users",
  "statusCode": 200,
  "duration": "45ms"
}
```

## Correlation IDs

Every request gets a unique correlation ID that:
- Is generated automatically if not provided
- Can be passed via `X-Correlation-ID` header
- Is included in all log entries for that request
- Is returned in response headers

### Using Correlation IDs

**Client Request:**
```bash
curl -H "X-Correlation-ID: my-custom-id" http://localhost:4000/api/v1/users
```

**Response includes:**
```
X-Correlation-ID: my-custom-id
```

## Service Identification

Logs include service names:
- `backend`: Main API server
- `database`: PostgreSQL operations
- `redis`: Redis cache operations

## Viewing Logs

### All Services
```bash
make logs
```

### Specific Service
```bash
make logs-backend
make logs-frontend
make logs-db
make logs-redis
```

### Filter by Level
```bash
make logs-filter LEVEL=error
make logs-filter LEVEL=warn
```

### Filter by Service
```bash
make logs-filter SERVICE=backend
```

### Aggregate Logs
```bash
make logs-aggregate
```

## Log Files (Production)

When `LOG_TO_FILE=true` or in production:
- Logs are written to `backend/logs/`
- Files are rotated daily
- Old files are compressed
- Retention: 14 days
- Max size: 20MB per file

### Log Files
- `error-YYYY-MM-DD.log`: Only error level logs
- `combined-YYYY-MM-DD.log`: All log levels

## Request Logging

Every HTTP request is automatically logged with:
- Method and URL
- Status code
- Duration
- IP address
- User agent
- Correlation ID

### Example Request Log
```
2025-11-13 10:30:45 [INFO] [req-123-456] [backend]: Incoming request
  method: GET
  url: /api/v1/users
  ip: 172.18.0.1
  userAgent: curl/7.68.0

2025-11-13 10:30:45 [INFO] [req-123-456] [backend]: Request completed
  method: GET
  url: /api/v1/users
  statusCode: 200
  duration: 45ms
```

## Error Logging

Errors are logged with full stack traces:
```json
{
  "timestamp": "2025-11-13T10:30:45.123Z",
  "level": "ERROR",
  "correlationId": "req-123-456",
  "service": "backend",
  "message": "Request error",
  "error": {
    "message": "Database connection failed",
    "stack": "Error: Database connection failed\n    at ..."
  }
}
```

## Database Query Logging

Database queries are logged at DEBUG level:
```json
{
  "level": "DEBUG",
  "service": "database",
  "message": "Query executed",
  "duration": "12ms",
  "query": "SELECT * FROM users WHERE id = $1"
}
```

## Configuration

Log level is controlled by `LOG_LEVEL` environment variable:
```bash
LOG_LEVEL=debug  # Show all logs
LOG_LEVEL=info   # Show info and above (default)
LOG_LEVEL=warn   # Show warnings and errors only
LOG_LEVEL=error  # Show errors only
```

## Best Practices

1. **Use appropriate log levels**
   - ERROR: Only for actual errors
   - WARN: For recoverable issues
   - INFO: For important events
   - DEBUG: For development details

2. **Include context**
   - Always include relevant data in log entries
   - Use structured logging (objects, not strings)

3. **Use correlation IDs**
   - Pass correlation IDs between services
   - Include in error reports

4. **Don't log sensitive data**
   - Never log passwords, tokens, or PII
   - Mask sensitive fields in logs

## Troubleshooting

### Logs not appearing
- Check `LOG_LEVEL` environment variable
- Verify service is running: `make ps`
- Check Docker logs: `docker-compose logs backend`

### Too many logs
- Increase log level: `LOG_LEVEL=warn`
- Filter logs: `make logs-filter LEVEL=error`

### Log files growing too large
- Log rotation is automatic
- Old files are compressed and deleted after 14 days
- Check disk space: `df -h`

