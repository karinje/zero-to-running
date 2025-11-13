#!/bin/bash

# Submit anonymous feedback
# Usage: ./scripts/submit-feedback.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Feedback Survey${NC}"
echo -e "${BLUE}===============${NC}"
echo ""
echo -e "${YELLOW}Help us improve! Please answer a few questions:${NC}"
echo ""

# Questions
read -p "1. How would you rate the setup process? (1-5): " RATING
read -p "2. Did you encounter any errors? (yes/no): " ERRORS
read -p "3. How long did setup take? (minutes): " DURATION
read -p "4. Was the documentation helpful? (1-5): " DOCS_RATING
read -p "5. Would you recommend this to a teammate? (yes/no): " RECOMMEND
read -p "6. Any additional comments (optional): " COMMENTS

FEEDBACK=$(cat <<EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "rating": $RATING,
  "errors": "$ERRORS",
  "duration_minutes": $DURATION,
  "docs_rating": $DOCS_RATING,
  "recommend": "$RECOMMEND",
  "comments": "$COMMENTS"
}
EOF
)

echo "$FEEDBACK" > .metrics/feedback.json
echo ""
echo -e "${GREEN}✓ Thank you for your feedback!${NC}"
echo -e "${YELLOW}Feedback saved to .metrics/feedback.json${NC}"

