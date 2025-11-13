#!/bin/bash

# Show components for a job family
# Usage: ./scripts/show-family.sh [JOB_FAMILY]

set -e

JOB_FAMILY=${1:-}
FAMILIES_FILE="config/job-families.yml"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$JOB_FAMILY" ]; then
  echo -e "${RED}Error: JOB_FAMILY parameter required${NC}"
  echo -e "${YELLOW}Usage: ./scripts/show-family.sh [JOB_FAMILY]${NC}"
  exit 1
fi

if [ ! -f "$FAMILIES_FILE" ]; then
  echo -e "${RED}Error: $FAMILIES_FILE not found${NC}"
  exit 1
fi

# Check if yq is available
if command -v yq &> /dev/null; then
  DESCRIPTION=$(yq eval ".job_families.$JOB_FAMILY.description" "$FAMILIES_FILE" 2>/dev/null)
  COMPONENTS=$(yq eval ".job_families.$JOB_FAMILY.components[]" "$FAMILIES_FILE" 2>/dev/null | tr '\n' '\n')
else
  # Basic parsing
  DESCRIPTION=$(grep -A 10 "^  $JOB_FAMILY:" "$FAMILIES_FILE" | grep "description:" | sed 's/.*description: "\(.*\)"/\1/')
  COMPONENTS=$(grep -A 10 "^  $JOB_FAMILY:" "$FAMILIES_FILE" | grep "    -" | sed 's/    - //')
fi

if [ -z "$DESCRIPTION" ]; then
  echo -e "${RED}❌ Job family '$JOB_FAMILY' not found${NC}"
  exit 1
fi

echo -e "${BLUE}Job Family: $JOB_FAMILY${NC}"
echo -e "${GREEN}Description: $DESCRIPTION${NC}"
echo -e "${YELLOW}Components:${NC}"
echo "$COMPONENTS" | sed 's/^/  - /'

