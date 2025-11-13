#!/bin/bash

# Switch between environment profiles
# Usage: ./scripts/switch-profile.sh [dev|staging|prod]

set -e

PROFILE=${1:-dev}
PROFILE_FILE=".env.${PROFILE}"
CURRENT_PROFILE_FILE=".env.current"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ ! -f "$PROFILE_FILE" ]; then
  echo -e "${RED}❌ Profile file $PROFILE_FILE not found${NC}"
  echo -e "${YELLOW}Available profiles: dev, staging, prod${NC}"
  exit 1
fi

# Copy profile to .env
cp "$PROFILE_FILE" .env
echo "$PROFILE" > "$CURRENT_PROFILE_FILE"

echo -e "${GREEN}✓ Switched to $PROFILE profile${NC}"
echo -e "${YELLOW}Current profile: $PROFILE${NC}"

