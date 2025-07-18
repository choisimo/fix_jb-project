#!/bin/bash

set -e

echo "🚀 Starting JB Report Platform - All Services"

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "❌ .env file not found. Please copy .env.template to .env and configure it."
    exit 1
fi

echo "🐳 Stopping existing services..."
docker-compose down

echo "🔨 Building and starting all services..."
docker-compose up -d --build

echo "✅ All services started successfully!"
echo "You can view logs using 'docker-compose logs -f'"
