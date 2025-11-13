#!/bin/bash

# Lint all code (backend and frontend)

echo "Linting backend..."
cd backend
npm run lint || echo "Backend linting failed or not configured"

echo ""
echo "Linting frontend..."
cd ../frontend
npm run lint || echo "Frontend linting failed or not configured"

echo ""
echo "Linting complete"

