#!/bin/bash

echo "🛑 Stopping JB Report Platform - All Services"

# Stop Java services
if [ -f .main-api.pid ]; then
    MAIN_PID=$(cat .main-api.pid)
    echo "Stopping Main API Server (PID: $MAIN_PID)..."
    kill $MAIN_PID 2>/dev/null || true
    rm .main-api.pid
fi

if [ -f .ai-analysis.pid ]; then
    AI_PID=$(cat .ai-analysis.pid)
    echo "Stopping AI Analysis Server (PID: $AI_PID)..."
    kill $AI_PID 2>/dev/null || true
    rm .ai-analysis.pid
fi

# Stop Docker services
echo "Stopping Docker services..."
docker-compose down

echo "✅ All services stopped"
