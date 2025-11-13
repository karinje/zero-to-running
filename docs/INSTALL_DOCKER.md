# Installing Docker

This guide will help you install Docker on your operating system.

## Prerequisites

- Administrator/sudo access
- Internet connection
- At least 4GB of RAM (8GB recommended)

## macOS

### Option 1: Docker Desktop (Recommended)

1. Download Docker Desktop from: https://www.docker.com/products/docker-desktop
2. Open the downloaded `.dmg` file
3. Drag Docker to your Applications folder
4. Open Docker from Applications
5. Follow the setup wizard
6. Docker Desktop will start automatically

### Option 2: Homebrew

```bash
brew install --cask docker
```

Then open Docker Desktop from Applications.

### Verify Installation

```bash
docker --version
docker-compose --version
```

## Linux (Ubuntu/Debian)

### Install Docker Engine

```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group (optional, to run without sudo)
sudo usermod -aG docker $USER
# Log out and back in for this to take effect
```

### Verify Installation

```bash
docker --version
docker compose version
```

## Windows

### Docker Desktop (Recommended)

1. Download Docker Desktop from: https://www.docker.com/products/docker-desktop
2. Run the installer
3. Follow the setup wizard
4. Restart your computer if prompted
5. Open Docker Desktop from Start menu

### WSL2 (Recommended for Windows)

Docker Desktop for Windows uses WSL2. If you don't have WSL2:

1. Open PowerShell as Administrator
2. Run: `wsl --install`
3. Restart your computer
4. Install Docker Desktop (it will use WSL2)

### Verify Installation

Open PowerShell or Command Prompt:

```powershell
docker --version
docker-compose --version
```

## Troubleshooting

### Docker not starting

**macOS/Linux:**
```bash
# Check if Docker daemon is running
docker info

# Start Docker service (Linux)
sudo systemctl start docker
```

**Windows:**
- Open Docker Desktop from Start menu
- Check system tray for Docker icon
- Restart Docker Desktop if needed

### Permission Denied Errors

**Linux:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in
```

### Port Already in Use

If you see port conflicts:

**macOS/Linux:**
```bash
# Find process using port
lsof -ti:3000

# Kill process
lsof -ti:3000 | xargs kill
```

**Windows:**
```powershell
# Find process using port
netstat -ano | findstr :3000

# Kill process (replace PID)
taskkill /PID <PID> /F
```

## Next Steps

After installing Docker:

1. Verify Docker is running: `docker info`
2. Copy `.env.example` to `.env`
3. Run `make dev` to start the environment

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Desktop Documentation](https://docs.docker.com/desktop/)
- [Docker Community Forums](https://forums.docker.com/)

