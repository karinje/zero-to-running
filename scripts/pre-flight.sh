#!/bin/bash

# Pre-flight checks before starting services
# This script runs all validation checks

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo -e "${BLUE}Running pre-flight checks...${NC}"
echo ""

ERRORS=0

# 1. Check Docker
echo -e "${BLUE}[1/4] Checking Docker...${NC}"
if ! "$SCRIPT_DIR/check-docker.sh"; then
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 2. Check ports
echo -e "${BLUE}[2/4] Checking ports...${NC}"
if ! "$SCRIPT_DIR/check-ports.sh"; then
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 3. Validate environment
echo -e "${BLUE}[3/4] Validating environment variables...${NC}"
if ! "$SCRIPT_DIR/validate-env.sh"; then
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 4. Check disk space (optional but helpful)
echo -e "${BLUE}[4/4] Checking disk space...${NC}"
if command -v df &> /dev/null; then
    AVAILABLE=$(df -h . | tail -1 | awk '{print $4}')
    echo -e "${GREEN}✓ Available disk space: ${AVAILABLE}${NC}"
    # Warn if less than 1GB (rough check)
    AVAILABLE_BYTES=$(df . | tail -1 | awk '{print $4}')
    if [ "$AVAILABLE_BYTES" -lt 1048576 ]; then
        echo -e "${YELLOW}⚠ Warning: Low disk space (< 1GB)${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Could not check disk space${NC}"
fi
echo ""

# Summary
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All pre-flight checks passed!${NC}"
    echo -e "${GREEN}Ready to start services with 'make dev'${NC}"
    exit 0
else
    echo -e "${RED}❌ Pre-flight checks failed with ${ERRORS} error(s)${NC}"
    echo -e "${YELLOW}Please fix the errors above before starting services${NC}"
    exit 1
fi

