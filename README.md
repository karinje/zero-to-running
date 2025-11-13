# Zero-to-Running Developer Environment

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

That's it! Your environment is now running.

## 📋 Prerequisites

- **Docker Desktop** 24.0+ installed and running
- **Git** installed
- **8GB RAM** minimum (16GB recommended)
- **20GB free disk space**
- **Internet connection** (for first-time image downloads)

## 🏗️ What's Running

Once you run `make dev`, you'll have:

- **Frontend**: React app with Vite at http://localhost:3000
  - Hot reload enabled for instant code changes
  - Connects to backend API automatically
  - Modern React 18 with React Router
- **Backend**: Node.js API at http://localhost:4000
  - Express server with health endpoints
  - Connected to PostgreSQL and Redis
  - Hot reload enabled for development
- **Database**: PostgreSQL 15.2 at localhost:5432
  - User: `wander_user`
  - Database: `wander_dev`
  - Each developer gets their own isolated database (no shared connections)
- **Cache**: Redis 7.0.5 at localhost:6379
  - Password: `dev_redis_password` (configurable in `.env`)
  - Isolated cache instance per developer

All services are containerized, isolated, and communicate via Docker networks.

## 🛠️ Common Commands

### Primary Commands
```bash
make dev          # Start all services
make down         # Stop all services
make clean        # Remove all data and volumes (with confirmation)
make restart      # Restart all services
```

### Monitoring
```bash
make logs              # View all service logs (follow mode)
make logs-frontend     # View frontend logs only
make logs-backend      # View backend logs only
make logs-db           # View database logs only
make logs-redis        # View redis logs only
make health            # Check all service health status
make ps                # Show running containers
```

### Development
```bash
make shell-frontend    # Access frontend container shell
make shell-backend     # Access backend container shell
make shell-db          # Access postgres shell (psql)
make shell-redis       # Access redis-cli
```

### Database Management
```bash
make db-seed           # Seed database with sample data (PR-009)
make db-reset          # Drop and recreate database (with confirmation)
make db-backup         # Backup database to backups/ directory
make db-restore FILE=backups/backup.sql  # Restore from backup
```

### Utilities
```bash
make help              # Show all available commands with descriptions
make check-docker      # Verify Docker is installed and running
```

For a complete list of commands, run `make help`.

## 📚 Documentation

- [Database Guide](docs/DATABASE.md) - PostgreSQL connection and usage
- [Redis Guide](docs/REDIS.md) - Redis cache connection and usage
- [Backend API](docs/BACKEND_API.md) - Backend API documentation
- [Frontend Guide](docs/FRONTEND.md) - Frontend development guide
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions
- [API Documentation](docs/API.md) - Backend API reference

## 🎯 Key Features

- ✅ **Zero Configuration**: Works out of the box
- ✅ **Hot Reload**: Code changes reflect instantly
- ✅ **Production Parity**: Same containers as production
- ✅ **Isolated Environments**: No conflicts between projects
- ✅ **Clean Teardown**: Remove everything with one command
- ✅ **Cross-Platform**: Works on Mac, Linux, and Windows (WSL2)

## 🔧 Configuration

All configuration is done via the `.env` file. See `.env.example` for all available options:

- Database credentials and ports
- Service ports (avoid conflicts)
- Resource limits
- Development options (debug mode, hot reload)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](docs/CONTRIBUTING.md) for details.

## 📄 License

See [LICENSE](LICENSE) for details.

## 🆘 Need Help?

- Check [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
- Review [FAQ](docs/FAQ.md)
- Open an issue on GitHub

---

**Built with ❤️ by the Wander team**

