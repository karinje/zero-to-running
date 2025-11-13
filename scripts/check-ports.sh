#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERRORS=0

# Ports to check
PORTS=(3000 4000 5432 6379)
PORT_NAMES=("Frontend" "Backend" "PostgreSQL" "Redis")

echo -e "${BLUE}Checking port availability...${NC}"

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    CHECK_CMD="lsof -ti"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    CHECK_CMD="lsof -ti"
else
    # Windows/WSL
    CHECK_CMD="netstat -ano | findstr"
fi

for i in "${!PORTS[@]}"; do
    PORT=${PORTS[$i]}
    NAME=${PORT_NAMES[$i]}
    
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        # Windows
        if netstat -ano | findstr ":$PORT " > /dev/null 2>&1; then
            PID=$(netstat -ano | findstr ":$PORT " | awk '{print $5}' | head -1)
            echo -e "${RED}❌ Port ${PORT} (${NAME}) is in use by PID ${PID}${NC}"
            echo -e "${YELLOW}Solution: Stop the process using this port${NC}"
            echo -e "${BLUE}  Windows: taskkill /PID ${PID} /F${NC}"
            ERRORS=$((ERRORS + 1))
        else
            echo -e "${GREEN}✓ Port ${PORT} (${NAME}) is available${NC}"
        fi
    else
        # macOS/Linux
        PID=$(lsof -ti:$PORT 2>/dev/null)
        if [ ! -z "$PID" ]; then
            PROCESS=$(ps -p $PID -o comm= 2>/dev/null || echo "unknown")
            echo -e "${RED}❌ Port ${PORT} (${NAME}) is in use by PID ${PID} (${PROCESS})${NC}"
            echo -e "${YELLOW}Solution: Stop the process using this port${NC}"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                echo -e "${BLUE}  macOS: lsof -ti:${PORT} | xargs kill${NC}"
            else
                echo -e "${BLUE}  Linux: kill ${PID} or lsof -ti:${PORT} | xargs kill${NC}"
            fi
            ERRORS=$((ERRORS + 1))
        else
            echo -e "${GREEN}✓ Port ${PORT} (${NAME}) is available${NC}"
        fi
    fi
done

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All required ports are available${NC}"
    exit 0
else
    echo -e "${RED}❌ Found ${ERRORS} port conflict(s)${NC}"
    echo -e "${YELLOW}Please free the ports above and try again${NC}"
    exit 1
fi

