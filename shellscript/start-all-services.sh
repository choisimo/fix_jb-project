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

# Check required environment variables
required_vars=(
    "DATABASE_PASSWORD"
    "REDIS_PASSWORD"
    "JWT_SECRET"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Error: $var is not set in .env file"
        exit 1
    fi
done

# Start infrastructure services
echo "🐳 Starting infrastructure services..."
docker-compose up -d postgres redis kafka zookeeper

# Wait for services to be healthy
echo "⏳ Waiting for infrastructure services to be ready..."
sleep 30

# Check PostgreSQL
echo -n "Checking PostgreSQL... "
if docker exec jbreport-postgres pg_isready -U jbreport > /dev/null 2>&1; then
    echo "✅ Ready"
else
    echo "❌ Failed"
    exit 1
fi

# Check Redis
echo -n "Checking Redis... "
if docker exec jbreport-redis redis-cli ping > /dev/null 2>&1; then
    echo "✅ Ready"
else
    echo "❌ Failed"
    exit 1
fi

# Build services
echo "🔨 Building services..."
cd main-api-server
./gradlew clean build -x test
cd ..

cd ai-analysis-server
./gradlew clean build -x test
cd ..

# Start Main API Server
echo "🎯 Starting Main API Server..."
cd main-api-server
nohup java -jar build/libs/report-platform-*.jar \
    --spring.profiles.active=prod \
    --server.port=8080 \
    > ../logs/main-api.log 2>&1 &
MAIN_API_PID=$!
echo "Main API Server PID: $MAIN_API_PID"
cd ..

# Start AI Analysis Server
echo "🤖 Starting AI Analysis Server..."
cd ai-analysis-server
nohup java -jar build/libs/ai-analysis-*.jar \
    --spring.profiles.active=prod \
    --server.port=8081 \
    > ../logs/ai-analysis.log 2>&1 &
AI_API_PID=$!
echo "AI Analysis Server PID: $AI_API_PID"
cd ..

# Save PIDs
echo $MAIN_API_PID > .main-api.pid
echo $AI_API_PID > .ai-analysis.pid

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 20

# Health checks
echo "🏥 Running health checks..."

# Check Main API
echo -n "Main API Server: "
if curl -f -s http://localhost:8080/actuator/health > /dev/null; then
    echo "✅ Healthy"
else
    echo "❌ Not responding"
fi

# Check AI Analysis
echo -n "AI Analysis Server: "
if curl -f -s http://localhost:8081/actuator/health > /dev/null; then
    echo "✅ Healthy"
else
    echo "❌ Not responding"
fi

# Check WebSocket
echo -n "WebSocket endpoint: "
if curl -f -s http://localhost:8080/ws/alerts > /dev/null 2>&1; then
    echo "✅ Available"
else
    echo "⚠️  WebSocket test requires upgrade"
fi

echo ""
echo "✅ All services started successfully!"
echo ""
echo "📊 Service URLs:"
echo "   Main API: http://localhost:8080"
echo "   Swagger UI: http://localhost:8080/swagger-ui.html"
echo "   AI Analysis: http://localhost:8081"
echo "   WebSocket: ws://localhost:8080/ws/alerts"
echo ""
echo "📝 Logs:"
echo "   Main API: logs/main-api.log"
echo "   AI Analysis: logs/ai-analysis.log"
echo ""
echo "To stop all services, run: ./scripts/stop-all-services.sh"
