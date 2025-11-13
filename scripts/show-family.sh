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
  COMPONENTS=$(yq eval ".job_families.$JOB_FAMILY.components[]" "$FAMILIES_FILE" 2>/dev/null | sort -u | tr '\n' '\n')
else
  # Basic parsing - extract section between this family and next
  FAMILY_START=$(grep -n "^  $JOB_FAMILY:" "$FAMILIES_FILE" | cut -d: -f1)
  NEXT_FAMILY_LINE=$(awk -v start="$FAMILY_START" 'NR > start && /^  [a-z-]*:/ {print NR; exit}' "$FAMILIES_FILE")
  if [ -z "$NEXT_FAMILY_LINE" ]; then
    # Last family, get to end of file
    FAMILY_SECTION=$(sed -n "${FAMILY_START},\$p" "$FAMILIES_FILE")
  else
    # Get section up to next family
    FAMILY_SECTION=$(sed -n "${FAMILY_START},$((NEXT_FAMILY_LINE-1))p" "$FAMILIES_FILE")
  fi
  DESCRIPTION=$(echo "$FAMILY_SECTION" | grep "description:" | sed 's/.*description: "\(.*\)"/\1/')
  COMPONENTS=$(echo "$FAMILY_SECTION" | grep "    -" | sed 's/    - //' | sort -u)
fi

if [ -z "$DESCRIPTION" ]; then
  echo -e "${RED}❌ Job family '$JOB_FAMILY' not found${NC}"
  exit 1
fi

echo -e "${BLUE}Job Family: $JOB_FAMILY${NC}"
echo -e "${GREEN}Description: $DESCRIPTION${NC}"
echo -e "${YELLOW}Components:${NC}"
echo "$COMPONENTS" | sed 's/^/  - /'

