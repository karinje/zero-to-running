#!/bin/bash

# Scan for accidentally committed secrets
# Usage: ./scripts/scan-secrets.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Scanning for secrets...${NC}"

# Common secret patterns
PATTERNS=(
  "password\s*=\s*['\"][^'\"]+['\"]"
  "api[_-]?key\s*=\s*['\"][^'\"]+['\"]"
  "secret\s*=\s*['\"][^'\"]+['\"]"
  "token\s*=\s*['\"][^'\"]+['\"]"
  "aws[_-]?access[_-]?key"
  "aws[_-]?secret[_-]?key"
  "private[_-]?key"
  "BEGIN\s+(RSA\s+)?PRIVATE\s+KEY"
)

FOUND_SECRETS=false

for pattern in "${PATTERNS[@]}"; do
  if git grep -i -E "$pattern" -- ':!.git' ':!node_modules' ':!*.lock' ':!.secrets.baseline' 2>/dev/null | grep -v "^#" | grep -v "dev_password" | grep -v "dev_redis" | grep -v "localhost" > /tmp/secret-matches.txt; then
    if [ -s /tmp/secret-matches.txt ]; then
      FOUND_SECRETS=true
      echo -e "${RED}⚠ Potential secrets found:${NC}"
      cat /tmp/secret-matches.txt
    fi
  fi
done

if [ "$FOUND_SECRETS" = true ]; then
  echo -e "${RED}❌ Potential secrets detected. Please review and remove.${NC}"
  echo -e "${YELLOW}If these are false positives, add to .secrets.baseline${NC}"
  exit 1
else
  echo -e "${GREEN}✓ No secrets detected${NC}"
  exit 0
fi

