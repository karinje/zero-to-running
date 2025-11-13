#!/bin/bash

# Resolve which components to install based on job family and exclusions
# Usage: ./scripts/resolve-components.sh [JOB_FAMILY] [NO_* flags...]

set -e

JOB_FAMILY=${1:-}
FAMILIES_FILE="config/job-families.yml"
COMPONENTS_FILE="/tmp/resolved-components.txt"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if yq is available (for YAML parsing)
if ! command -v yq &> /dev/null; then
  echo -e "${YELLOW}Warning: yq not found. Using basic parsing.${NC}"
  USE_YQ=false
else
  USE_YQ=true
fi

# If no job family specified, return all components
if [ -z "$JOB_FAMILY" ]; then
  echo "postgres redis backend frontend" > "$COMPONENTS_FILE"
  cat "$COMPONENTS_FILE"
  exit 0
fi

# Extract components from job family
if [ "$USE_YQ" = true ]; then
  COMPONENTS=$(yq eval ".job_families.$JOB_FAMILY.components[]" "$FAMILIES_FILE" 2>/dev/null | sort -u | tr '\n' ' ')
else
  # Basic YAML parsing (fallback)
  COMPONENTS=$(grep -A 10 "^  $JOB_FAMILY:" "$FAMILIES_FILE" | grep "    -" | sed 's/    - //' | sort -u | tr '\n' ' ')
fi

if [ -z "$COMPONENTS" ]; then
  echo -e "${RED}❌ Job family '$JOB_FAMILY' not found${NC}" >&2
  echo -e "${YELLOW}Available families:${NC}" >&2
  if [ "$USE_YQ" = true ]; then
    yq eval '.job_families | keys | .[]' "$FAMILIES_FILE" | sed 's/^/  - /' >&2
  else
    grep "^  [a-z-]*:" "$FAMILIES_FILE" | sed 's/:$//' | sed 's/^  /  - /' >&2
  fi
  exit 1
fi

# Apply exclusions (NO_* flags)
FILTERED_COMPONENTS=""
for component in $COMPONENTS; do
  # Check if component is excluded
  EXCLUDE_VAR="NO_$(echo "$component" | tr '[:lower:]' '[:upper:]')"
  if [ "${!EXCLUDE_VAR}" != "true" ]; then
    FILTERED_COMPONENTS="$FILTERED_COMPONENTS $component"
  fi
done

# Trim and output
FILTERED_COMPONENTS=$(echo "$FILTERED_COMPONENTS" | xargs)
echo "$FILTERED_COMPONENTS" > "$COMPONENTS_FILE"
echo "$FILTERED_COMPONENTS"

