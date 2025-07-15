#!/bin/bash
set -e

# Create directories if they don't exist
mkdir -p /app/data/uploads
mkdir -p /app/data/thumbnails
mkdir -p /app/data/temp
mkdir -p /app/data/logs

# Check if we're running in development mode
if [ "$ENVIRONMENT" = "development" ]; then
    echo "Starting server in development mode with hot reload"
    exec python -m app.server
else
    echo "Starting server in production mode"
    exec uvicorn app.main:app --host 0.0.0.0 --port 12020 --workers ${WORKERS:-4}
fi
