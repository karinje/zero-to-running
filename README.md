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

- **Frontend**: React app at http://localhost:3000
- **Backend**: Node.js API at http://localhost:4000
- **Database**: PostgreSQL 15.2 at localhost:5432
- **Cache**: Redis 7.0.5 at localhost:6379

All services are containerized, isolated, and communicate via Docker networks.

## 🛠️ Common Commands

```bash
make dev          # Start all services
make down         # Stop all services
make clean        # Remove all data and volumes
make logs         # View all service logs
make health       # Check service health status
make help         # Show all available commands
```

## 📚 Documentation

- [Quick Start Guide](docs/QUICK_START.md) - Detailed setup instructions
- [Architecture Overview](docs/ARCHITECTURE.md) - System design and components
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

