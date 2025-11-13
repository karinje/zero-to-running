#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

COMPOSE_FILE="docker-compose.yml"

echo -e "${BLUE}Service Health Check${NC}"
echo -e "${BLUE}====================${NC}"
echo ""

# Check if services are running
if ! docker-compose -f $COMPOSE_FILE ps | grep -q "Up"; then
    echo -e "${RED}❌ No services are running${NC}"
    echo -e "${YELLOW}Run 'make dev' to start services${NC}"
    exit 1
fi

# Check PostgreSQL
if docker-compose -f $COMPOSE_FILE ps postgres | grep -q "healthy"; then
    echo -e "${GREEN}✓ PostgreSQL: Healthy${NC}"
elif docker-compose -f $COMPOSE_FILE ps postgres | grep -q "Up"; then
    echo -e "${YELLOW}⚠ PostgreSQL: Running (health check pending)${NC}"
else
    echo -e "${RED}❌ PostgreSQL: Not running${NC}"
fi

# Check Redis
if docker-compose -f $COMPOSE_FILE ps redis | grep -q "healthy"; then
    echo -e "${GREEN}✓ Redis: Healthy${NC}"
elif docker-compose -f $COMPOSE_FILE ps redis | grep -q "Up"; then
    echo -e "${YELLOW}⚠ Redis: Running (health check pending)${NC}"
else
    echo -e "${RED}❌ Redis: Not running${NC}"
fi

# Check Backend
if docker-compose -f $COMPOSE_FILE ps backend | grep -q "Up"; then
    # Try to hit the health endpoint
    if curl -s http://localhost:4000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Backend: Healthy${NC}"
    else
        echo -e "${YELLOW}⚠ Backend: Running (API not responding)${NC}"
    fi
else
    echo -e "${RED}❌ Backend: Not running${NC}"
fi

# Check Frontend
if docker-compose -f $COMPOSE_FILE ps frontend | grep -q "Up"; then
    # Try to hit the frontend
    if curl -s http://localhost:3000 > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Frontend: Healthy${NC}"
    else
        echo -e "${YELLOW}⚠ Frontend: Running (not responding)${NC}"
    fi
else
    echo -e "${RED}❌ Frontend: Not running${NC}"
fi

echo ""
echo -e "${BLUE}Service URLs:${NC}"
echo -e "  Frontend: ${BLUE}http://localhost:3000${NC}"
echo -e "  Backend:  ${BLUE}http://localhost:4000${NC}"
echo -e "  Postgres: ${BLUE}localhost:5432${NC}"
echo -e "  Redis:    ${BLUE}localhost:6379${NC}"

exit 0

