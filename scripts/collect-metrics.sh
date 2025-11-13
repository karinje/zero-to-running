#!/bin/bash

# Collect anonymous metrics about setup and usage
# Usage: ./scripts/collect-metrics.sh

set -e

METRICS_DIR=".metrics"
METRICS_FILE="$METRICS_DIR/metrics.json"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

mkdir -p "$METRICS_DIR"

# Collect metrics
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
DOCKER_VERSION=$(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',' || echo "unknown")

METRICS=$(cat <<EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "os": "$OS",
  "architecture": "$ARCH",
  "docker_version": "$DOCKER_VERSION",
  "setup_success": true
}
EOF
)

echo "$METRICS" > "$METRICS_FILE"
echo -e "${GREEN}✓ Metrics collected${NC}"

