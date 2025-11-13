#!/bin/bash

# Generate SSL certificates for local HTTPS development
# Creates self-signed certificates valid for localhost

set -e

CERT_DIR="./certs"
CERT_FILE="$CERT_DIR/localhost-cert.pem"
KEY_FILE="$CERT_DIR/localhost-key.pem"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Generating SSL certificates for localhost...${NC}"

# Create certs directory if it doesn't exist
mkdir -p "$CERT_DIR"

# Generate certificate
openssl req -x509 -newkey rsa:4096 -nodes \
  -keyout "$KEY_FILE" \
  -out "$CERT_FILE" \
  -days 365 \
  -subj "/C=US/ST=State/L=City/O=Development/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,DNS:*.localhost,IP:127.0.0.1,IP:::1"

# Set permissions
chmod 600 "$KEY_FILE"
chmod 644 "$CERT_FILE"

echo -e "${GREEN}✓ Certificates generated successfully${NC}"
echo -e "${BLUE}Certificate: $CERT_FILE${NC}"
echo -e "${BLUE}Private Key: $KEY_FILE${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Trust the certificate: ${GREEN}make trust-cert${NC}"
echo -e "2. Enable SSL in .env: ${GREEN}ENABLE_SSL=true${NC}"
echo -e "3. Restart services: ${GREEN}make dev${NC}"

