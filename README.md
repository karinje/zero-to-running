# Zero-to-Running Developer Environment

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

**One command to rule them all: `make dev`**

A Docker-based development environment that gets you from zero to a fully running multi-service application stack in under 10 minutes. No manual configuration, no version conflicts, no "works on my machine" problems.

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone <repository-url>
cd zero-to-running

# 2. Copy environment configuration
cp .env.example .env

# 3. Start everything
make dev
```

That's it! Your environment is now running:
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:4000
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379

## 📋 Prerequisites

- **Docker Desktop** 24.0+ installed and running
- **Git** installed
- **8GB RAM** minimum (16GB recommended)
- **20GB free disk space**
- **Internet connection** (for first-time image downloads)

## ✨ Features

### Core Services
- ✅ **PostgreSQL 15.2** - Production-ready database with health checks
- ✅ **Redis 7.0.5** - High-performance caching and session storage
- ✅ **Node.js/Express Backend** - RESTful API with structured logging
- ✅ **React/Vite Frontend** - Modern UI with hot module replacement

### Developer Experience
- ✅ **One-Command Setup** - `make dev` starts everything
- ✅ **Hot Reload** - Instant code changes without restart
- ✅ **Health Checks** - Automatic service health monitoring
- ✅ **Pre-flight Checks** - Validates Docker, ports, and environment before starting
- ✅ **Comprehensive Logging** - Winston-based structured logs with correlation IDs
- ✅ **55+ Makefile Commands** - Everything you need at your fingertips

### Advanced Features
- ✅ **Environment Profiles** - Dev, staging, and production-local configurations
- ✅ **Job Family Configuration** - Role-based service selection (ML engineer, frontend, backend, etc.)
- ✅ **SSL/HTTPS Support** - Local HTTPS for OAuth, secure cookies, mobile testing
- ✅ **Testing Suite** - Jest (backend), Vitest (frontend), Playwright (E2E)
- ✅ **Pre-commit Hooks** - Automatic code quality checks (Husky, lint-staged, Prettier)
- ✅ **Security Scanning** - Secret detection and dependency vulnerability checks
- ✅ **Performance Optimization** - Redis caching service and middleware
- ✅ **Metrics & Feedback** - Anonymous metrics collection and feedback system

## 📚 Documentation

Comprehensive documentation is available in the `docs/` directory:

### Getting Started
- **[README.md](README.md)** - This file (quick start guide)
- **[INSTALL_DOCKER.md](docs/INSTALL_DOCKER.md)** - Docker installation guide

### Core Features
- **[BACKEND_API.md](docs/BACKEND_API.md)** - Backend API documentation
- **[FRONTEND.md](docs/FRONTEND.md)** - Frontend development guide
- **[DATABASE.md](docs/DATABASE.md)** - Database setup and usage
- **[REDIS.md](docs/REDIS.md)** - Redis configuration and usage
- **[LOGGING.md](docs/LOGGING.md)** - Logging system documentation

### Advanced Features
- **[PROFILES.md](docs/PROFILES.md)** - Environment profiles (dev/staging/prod)
- **[JOB_FAMILIES.md](docs/JOB_FAMILIES.md)** - Job family-based configuration
- **[SSL_SETUP.md](docs/SSL_SETUP.md)** - SSL/HTTPS setup guide
- **[TESTING.md](docs/TESTING.md)** - Testing framework documentation
- **[PERFORMANCE.md](docs/PERFORMANCE.md)** - Performance optimization guide
- **[ADVANCED_USAGE.md](docs/ADVANCED_USAGE.md)** - Advanced Makefile commands

### Code Quality & Security
- **[CODE_QUALITY.md](docs/CODE_QUALITY.md)** - Pre-commit hooks and code standards
- **[SECURITY.md](docs/SECURITY.md)** - Security best practices

### Troubleshooting
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Comprehensive troubleshooting guide
- **[FAQ.md](docs/FAQ.md)** - Frequently asked questions
- **[COMMON_ERRORS.md](docs/COMMON_ERRORS.md)** - Common errors and solutions
- **[DEBUGGING.md](docs/DEBUGGING.md)** - Debugging techniques

### Additional
- **[METRICS.md](docs/METRICS.md)** - Metrics and feedback system
- **[VIDEO_TUTORIAL.md](docs/VIDEO_TUTORIAL.md)** - Video tutorial structure (coming soon)

## 🛠️ Common Commands

### Primary Commands

```bash
make dev              # Start all services (default: dev profile)
make dev-dev          # Start with dev profile
make dev-staging      # Start with staging profile
make dev-prod         # Start with prod profile
make down             # Stop all services
make restart          # Restart all services
make clean            # Remove all data and volumes (⚠️ destructive)
```

### Monitoring

```bash
make logs             # View all service logs
make logs-frontend    # View frontend logs only
make logs-backend     # View backend logs only
make logs-db          # View database logs only
make logs-redis       # View redis logs only
make logs-filter LEVEL=error    # Filter logs by level
make logs-filter SERVICE=backend # Filter logs by service
make health           # Check all service health
make ps               # Show running containers
```

### Development

```bash
make shell-frontend   # Access frontend container shell
make shell-backend    # Access backend container shell
make shell-db         # Access postgres shell
make shell-redis      # Access redis-cli
```

### Database

```bash
make db-seed          # Seed database with sample data
make db-reset         # Drop and recreate database
make db-backup        # Backup database
make db-restore FILE=backups/backup.sql  # Restore from backup
make db-migrate       # Run database migrations (placeholder)
make db-rollback      # Rollback last migration (placeholder)
```

### Testing

```bash
make test             # Run all tests
make test-backend     # Run backend tests only
make test-frontend    # Run frontend tests only
make test-e2e         # Run end-to-end tests
```

### Code Quality

```bash
make lint             # Lint all code
make lint-fix         # Auto-fix linting issues
make format           # Format all code with Prettier
```

### Environment Profiles

```bash
make profile-switch PROFILE=staging  # Switch environment profile
make profile-status                  # Show current profile
```

### Job Families

```bash
make list-families                           # List all job families
make show-family JOB_FAMILY=ml-engineer      # Show family components
make dev JOB_FAMILY=ml-engineer               # Start with job family
make dev JOB_FAMILY=full-stack NO_REDIS=true  # Start with exclusions
```

### SSL/HTTPS

```bash
make generate-certs  # Generate SSL certificates
make trust-cert      # Trust certificate (macOS/Linux)
# Then add ENABLE_SSL=true to .env and restart
```

### Metrics & Feedback

```bash
make feedback        # Submit anonymous feedback
make metrics-view    # View collected metrics
make metrics-clear   # Clear collected metrics
```

### Security

```bash
make security-audit  # Run security audit
```

### Docker Maintenance

```bash
make prune           # Clean up unused Docker resources
make rebuild         # Rebuild all Docker images
make rebuild-backend # Rebuild backend image only
make rebuild-frontend # Rebuild frontend image only
make update          # Update dependencies
```

### Utilities

```bash
make check-docker    # Check if Docker is installed and running
make validate-env     # Validate environment variables
make check-ports     # Check if required ports are available
make pre-flight      # Run all pre-flight checks
make troubleshoot    # Show troubleshooting information
make help            # Display all available commands
```

## 🎯 Job Families

Select your role and get the relevant services automatically:

```bash
# Available job families
make list-families

# Examples
make dev JOB_FAMILY=ml-engineer              # ML engineer setup
make dev JOB_FAMILY=backend-engineer          # Backend developer
make dev JOB_FAMILY=frontend-engineer         # Frontend developer
make dev JOB_FAMILY=full-stack                # Full-stack developer
make dev JOB_FAMILY=data-engineer             # Data engineer

# With exclusions
make dev JOB_FAMILY=ml-engineer NO_REDIS=true
make dev JOB_FAMILY=full-stack NO_REDIS=true NO_FRONTEND=true
```

See [JOB_FAMILIES.md](docs/JOB_FAMILIES.md) for complete documentation.

## 🔒 SSL/HTTPS Setup

Enable HTTPS for local development (useful for OAuth, secure cookies, mobile testing):

```bash
# 1. Generate certificates
make generate-certs

# 2. Trust the certificate
make trust-cert

# 3. Enable SSL in .env
echo "ENABLE_SSL=true" >> .env

# 4. Restart services
make dev

# Access via HTTPS:
# Frontend: https://localhost:3000
# Backend: https://localhost:4000
```

See [SSL_SETUP.md](docs/SSL_SETUP.md) for detailed instructions.

## 🧪 Testing

The project includes comprehensive testing setup:

### Backend Tests (Jest)
```bash
make test-backend
# Or directly: docker-compose exec backend npm test
```

### Frontend Tests (Vitest)
```bash
make test-frontend
# Or directly: docker-compose exec frontend npm test
```

### E2E Tests (Playwright)
```bash
make test-e2e
# Or: cd e2e && npm test
```

See [TESTING.md](docs/TESTING.md) for complete testing documentation.

## 🔧 Configuration

### Environment Variables

Copy `.env.example` to `.env` and customize:

```bash
cp .env.example .env
```

Key variables:
- `POSTGRES_*` - Database configuration
- `REDIS_*` - Redis configuration
- `BACKEND_PORT` - Backend API port (default: 4000)
- `FRONTEND_PORT` - Frontend port (default: 3000)
- `ENABLE_SSL` - Enable HTTPS (default: false)
- `LOG_LEVEL` - Logging level (debug/info/warn/error)
- `NODE_ENV` - Environment (development/staging/production)

### Environment Profiles

Switch between profiles:
- **dev** (default) - Hot reload, debug logging, sample data
- **staging** - Production-like, info logging, minimal data
- **prod** - Production config, error logging only, no sample data

```bash
make profile-switch PROFILE=staging
make dev-staging
```

See [PROFILES.md](docs/PROFILES.md) for details.

## 📊 Project Structure

```
zero-to-running/
├── backend/              # Node.js/Express API
│   ├── src/
│   │   ├── config/      # Configuration (env, logger, database, redis)
│   │   ├── middleware/  # Express middleware
│   │   ├── routes/      # API routes
│   │   └── utils/       # Utilities (cache, etc.)
│   ├── tests/           # Jest tests
│   └── scripts/         # Seed scripts
│
├── frontend/             # React/Vite application
│   ├── src/
│   │   ├── components/  # React components
│   │   ├── pages/      # Page components
│   │   ├── services/   # API services
│   │   └── config/     # Configuration
│   └── tests/          # Vitest tests
│
├── e2e/                 # End-to-end tests (Playwright)
│   └── tests/
│
├── docker/              # Docker configuration
│   ├── postgres/       # PostgreSQL init scripts
│   └── redis/          # Redis configuration
│
├── scripts/             # Utility scripts
│   ├── pre-flight.sh   # Pre-flight checks
│   ├── generate-certs.sh # SSL certificate generation
│   └── ...
│
├── config/              # Configuration files
│   └── job-families.yml # Job family definitions
│
├── docs/                # Documentation
├── certs/               # SSL certificates (gitignored)
├── .metrics/            # Metrics data (gitignored)
│
├── docker-compose.yml   # Main Docker Compose file
├── docker-compose.dev.yml    # Dev profile overrides
├── docker-compose.staging.yml # Staging profile overrides
├── docker-compose.prod.yml    # Prod profile overrides
├── Makefile            # Developer commands
└── README.md           # This file
```

## 🚨 Troubleshooting

### Quick Fixes

```bash
# Run pre-flight checks
make pre-flight

# Check Docker status
make check-docker

# Check port availability
make check-ports

# View service logs
make logs

# Check service health
make health

# Get troubleshooting help
make troubleshoot
```

### Common Issues

1. **Port conflicts**: Use `make check-ports` to identify and resolve
2. **Docker not running**: Ensure Docker Desktop is running
3. **Services won't start**: Run `make pre-flight` to diagnose
4. **Database connection failed**: Check `.env` file and run `make validate-env`

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for comprehensive troubleshooting guide.

## 🔐 Security

### Secret Management
- Never commit `.env` files
- Use `.env.example` for templates
- Secret scanning runs on pre-commit

### Security Features
- Docker security options (no-new-privileges)
- Secret scanning pre-commit hook
- Dependency vulnerability scanning
- Environment variable validation

```bash
# Run security audit
make security-audit
```

See [SECURITY.md](docs/SECURITY.md) for security best practices.

## 📈 Performance

### Caching
Redis caching is available for frequently accessed data:

```javascript
const cache = require('./utils/cache');

// Get from cache
const data = await cache.get('key');

// Set in cache (TTL: 1 hour default)
await cache.set('key', data);

// Use cache middleware
app.get('/api/data', cacheMiddleware(1800), getData);
```

See [PERFORMANCE.md](docs/PERFORMANCE.md) for optimization guide.

## 🎓 Code Quality

### Pre-commit Hooks
Automatic code quality checks on commit:
- ESLint for JavaScript/JSX
- Prettier for code formatting
- Commitlint for commit message format

### Commit Message Format
Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(backend): add user authentication endpoint
fix(frontend): resolve CORS error
docs: update README with new features
```

See [CODE_QUALITY.md](docs/CODE_QUALITY.md) for details.

## 📝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Commit using conventional commits (`git commit -m 'feat: add amazing feature'`)
5. Push to your branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with Docker and Docker Compose
- Backend powered by Node.js and Express
- Frontend built with React and Vite
- Database: PostgreSQL
- Cache: Redis

## 📞 Support

- **Documentation**: See `docs/` directory
- **Troubleshooting**: `make troubleshoot` or see [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- **FAQ**: See [FAQ.md](docs/FAQ.md)
- **Issues**: GitHub Issues

## 🎉 What's Included

### All 23 PRs Implemented

**Phase 1: Core MVP (PR-001 to PR-009)**
- Project structure and configuration
- PostgreSQL, Redis, Backend, Frontend services
- Docker Compose orchestration
- Makefile with developer commands
- Database seeding
- Basic documentation

**Phase 2: Polish & Documentation (PR-010 to PR-012)**
- Enhanced error messages and validation
- Comprehensive logging (Winston)
- Troubleshooting guides

**Phase 3: Advanced Features (PR-013 to PR-015)**
- Advanced Makefile commands
- Environment profiles
- Pre-commit hooks and code quality

**Phase 4: Testing & Optimization (PR-016 to PR-020)**
- Automated testing suite
- SSL/HTTPS support
- Performance optimization
- Job family configuration
- Security hardening

**Additional (PR-021 to PR-023)**
- Video tutorial structure
- Metrics and feedback system
- Release preparation

**Progress: 23/23 PRs Complete (100%)** 🎉

---

**Ready to code?** Run `make dev` and start building! 🚀
