#!/bin/bash

# Clean up unused Docker resources

echo "Cleaning up unused Docker resources..."

# Remove stopped containers
echo "Removing stopped containers..."
docker container prune -f

# Remove unused images
echo "Removing unused images..."
docker image prune -f

# Remove unused volumes
echo "Removing unused volumes..."
docker volume prune -f

# Remove unused networks
echo "Removing unused networks..."
docker network prune -f

# System prune (everything)
echo "Running system prune..."
docker system prune -f

echo "Cleanup complete!"
echo ""
echo "Disk space freed:"
docker system df

