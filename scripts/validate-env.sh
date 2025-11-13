#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERRORS=0

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}❌ Error: .env file not found${NC}"
    echo -e "${YELLOW}Solution: Copy .env.example to .env${NC}"
    echo -e "${BLUE}  cp .env.example .env${NC}"
    exit 1
fi

echo -e "${BLUE}Validating environment variables...${NC}"

# Required variables
REQUIRED_VARS=(
    "POSTGRES_USER"
    "POSTGRES_PASSWORD"
    "POSTGRES_DB"
    "REDIS_PASSWORD"
    "BACKEND_PORT"
    "FRONTEND_PORT"
)

# Check each required variable
for VAR in "${REQUIRED_VARS[@]}"; do
    if ! grep -q "^${VAR}=" .env 2>/dev/null; then
        echo -e "${RED}❌ Missing required variable: ${VAR}${NC}"
        ERRORS=$((ERRORS + 1))
    else
        VALUE=$(grep "^${VAR}=" .env | cut -d '=' -f2)
        if [ -z "$VALUE" ]; then
            echo -e "${RED}❌ Variable ${VAR} is empty${NC}"
            ERRORS=$((ERRORS + 1))
        else
            echo -e "${GREEN}✓ ${VAR} is set${NC}"
        fi
    fi
done

# Check for default passwords (warn only)
if grep -q "POSTGRES_PASSWORD=dev_password_change_in_prod" .env 2>/dev/null; then
    echo -e "${YELLOW}⚠ Warning: Using default POSTGRES_PASSWORD (change in production)${NC}"
fi

if grep -q "REDIS_PASSWORD=dev_redis_password" .env 2>/dev/null; then
    echo -e "${YELLOW}⚠ Warning: Using default REDIS_PASSWORD (change in production)${NC}"
fi

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All required environment variables are set${NC}"
    exit 0
else
    echo -e "${RED}❌ Found ${ERRORS} error(s)${NC}"
    echo -e "${YELLOW}Please fix the errors above and try again${NC}"
    exit 1
fi

