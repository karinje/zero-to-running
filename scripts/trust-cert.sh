#!/bin/bash

# Trust SSL certificate on macOS
# Usage: ./scripts/trust-cert.sh

set -e

CERT_FILE="./certs/localhost-cert.pem"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ ! -f "$CERT_FILE" ]; then
  echo -e "${RED}❌ Certificate file not found: $CERT_FILE${NC}"
  echo -e "${YELLOW}Generate certificates first: make generate-certs${NC}"
  exit 1
fi

# Detect OS
OS="$(uname -s)"

case "$OS" in
  Darwin*)
    echo -e "${YELLOW}Trusting certificate on macOS...${NC}"
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$CERT_FILE"
    echo -e "${GREEN}✓ Certificate trusted${NC}"
    ;;
  Linux*)
    echo -e "${YELLOW}Trusting certificate on Linux...${NC}"
    sudo cp "$CERT_FILE" /usr/local/share/ca-certificates/localhost.crt
    sudo update-ca-certificates
    echo -e "${GREEN}✓ Certificate trusted${NC}"
    ;;
  *)
    echo -e "${YELLOW}OS not supported for automatic trust. Please trust manually:${NC}"
    echo -e "${BLUE}See certs/README.md for instructions${NC}"
    exit 1
    ;;
esac

