#!/bin/bash

# Validate environment profile configuration
# Usage: ./scripts/validate-profile.sh [dev|staging|prod]

set -e

PROFILE=${1:-dev}
PROFILE_FILE=".env.${PROFILE}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ ! -f "$PROFILE_FILE" ]; then
  echo -e "${RED}❌ Profile file $PROFILE_FILE not found${NC}"
  exit 1
fi

echo -e "${YELLOW}Validating $PROFILE profile...${NC}"

# Required variables
REQUIRED_VARS=(
  "POSTGRES_USER"
  "POSTGRES_PASSWORD"
  "POSTGRES_DB"
  "REDIS_PASSWORD"
  "BACKEND_PORT"
  "FRONTEND_PORT"
)

MISSING_VARS=()

# Source the profile file and check for required variables
while IFS= read -r line || [ -n "$line" ]; do
  # Skip comments and empty lines
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  [[ -z "$line" ]] && continue
  
  # Extract variable name
  VAR_NAME=$(echo "$line" | cut -d'=' -f1)
  VAR_NAME=$(echo "$VAR_NAME" | xargs)
  
  # Check if it's required
  for req_var in "${REQUIRED_VARS[@]}"; do
    if [ "$VAR_NAME" = "$req_var" ]; then
      # Check if value is empty
      VAR_VALUE=$(echo "$line" | cut -d'=' -f2-)
      if [ -z "$VAR_VALUE" ] || [ "$VAR_VALUE" = "" ]; then
        MISSING_VARS+=("$VAR_NAME")
      fi
    fi
  done
done < "$PROFILE_FILE"

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
  echo -e "${RED}❌ Missing required variables:${NC}"
  for var in "${MISSING_VARS[@]}"; do
    echo -e "${RED}  - $var${NC}"
  done
  exit 1
fi

echo -e "${GREEN}✓ Profile $PROFILE is valid${NC}"
exit 0

