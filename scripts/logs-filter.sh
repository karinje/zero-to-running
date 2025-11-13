#!/bin/bash

# Filter logs by level or service
# Usage: ./scripts/logs-filter.sh [level|service] [value]

LEVEL=${1:-}
VALUE=${2:-}

if [ -z "$LEVEL" ] || [ -z "$VALUE" ]; then
    echo "Usage: ./scripts/logs-filter.sh [level|service] [value]"
    echo "Examples:"
    echo "  ./scripts/logs-filter.sh level error"
    echo "  ./scripts/logs-filter.sh service backend"
    exit 1
fi

if [ "$LEVEL" = "level" ]; then
    docker-compose logs --tail=1000 | grep -i "\[$VALUE\]"
elif [ "$LEVEL" = "service" ]; then
    docker-compose logs --tail=1000 "$VALUE"
else
    echo "Invalid filter type. Use 'level' or 'service'"
    exit 1
fi

