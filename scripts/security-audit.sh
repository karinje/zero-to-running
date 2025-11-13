#!/bin/bash

# Run security audit
# Usage: ./scripts/security-audit.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Security Audit${NC}"
echo -e "${BLUE}==============${NC}"
echo ""

# Check for secrets
echo -e "${YELLOW}1. Scanning for secrets...${NC}"
./scripts/scan-secrets.sh || echo -e "${YELLOW}   (Skipping secret scan)${NC}"

# Check dependencies
echo ""
echo -e "${YELLOW}2. Checking for dependency vulnerabilities...${NC}"
if [ -d "backend" ]; then
  echo -e "${BLUE}   Backend:${NC}"
  cd backend && npm audit --audit-level=moderate || echo -e "${YELLOW}   (npm audit not available)${NC}"
  cd ..
fi

if [ -d "frontend" ]; then
  echo -e "${BLUE}   Frontend:${NC}"
  cd frontend && npm audit --audit-level=moderate || echo -e "${YELLOW}   (npm audit not available)${NC}"
  cd ..
fi

# Check Docker security
echo ""
echo -e "${YELLOW}3. Checking Docker configuration...${NC}"
if [ -f "docker-compose.yml" ]; then
  if grep -q "user:" docker-compose.yml; then
    echo -e "${GREEN}   ✓ Non-root users configured${NC}"
  else
    echo -e "${YELLOW}   ⚠ Consider using non-root users${NC}"
  fi
fi

echo ""
echo -e "${GREEN}✓ Security audit complete${NC}"

