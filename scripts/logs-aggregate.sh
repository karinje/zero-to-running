#!/bin/bash

# Aggregate logs from all services with timestamps

echo "Aggregating logs from all services..."
echo ""

docker-compose logs --tail=100 --timestamps | sort -k1,1

