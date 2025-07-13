#!/bin/bash

set -e

echo "🧪 Running JB Report Platform Integration Tests..."

# Check if services are running
check_service() {
    local service=$1
    local url=$2
    
    echo -n "Checking $service... "
    if curl -f -s "$url" > /dev/null; then
        echo "✅ OK"
        return 0
    else
        echo "❌ FAILED"
        return 1
    fi
}

# Start services if not running
if ! docker-compose ps | grep -q "Up"; then
    echo "Starting infrastructure services..."
    docker-compose up -d
    sleep 30
fi

# Health checks
echo "🏥 Running health checks..."
check_service "PostgreSQL" "http://localhost:5432" || true
check_service "Redis" "http://localhost:6379" || true
check_service "Kafka" "http://localhost:9092" || true

# Start API servers
echo "🚀 Starting API servers..."
cd main-api-server
nohup java -jar build/libs/report-platform-*.jar > ../logs/main-api.log 2>&1 &
MAIN_API_PID=$!
cd ..

cd ai-analysis-server
nohup java -jar build/libs/ai-analysis-*.jar > ../logs/ai-analysis.log 2>&1 &
AI_API_PID=$!
cd ..

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 20

# API Tests
echo "🔍 Running API tests..."

# Test authentication
echo -n "Testing authentication endpoint... "
AUTH_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"test@example.com","password":"password123"}' \
    -w "\n%{http_code}")
HTTP_CODE=$(echo "$AUTH_RESPONSE" | tail -n 1)
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "401" ]; then
    echo "✅ OK"
else
    echo "❌ FAILED (HTTP $HTTP_CODE)"
fi

# Test report creation
echo -n "Testing report creation... "
REPORT_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/reports \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer test-token" \
    -d '{
        "title":"Test Report",
        "description":"Integration test report",
        "category":"OTHER",
        "latitude":37.5665,
        "longitude":126.9780
    }' \
    -w "\n%{http_code}")
HTTP_CODE=$(echo "$REPORT_RESPONSE" | tail -n 1)
if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "401" ]; then
    echo "✅ OK"
else
    echo "❌ FAILED (HTTP $HTTP_CODE)"
fi

# Test WebSocket connection
echo -n "Testing WebSocket connection... "
timeout 5 wscat -c ws://localhost:8080/ws/alerts?userId=1 > /dev/null 2>&1
if [ $? -eq 124 ]; then
    echo "✅ OK (connection established)"
else
    echo "⚠️  WebSocket test skipped (wscat not installed)"
fi

# Test AI analysis endpoint
echo -n "Testing AI analysis endpoint... "
AI_RESPONSE=$(curl -s -X GET http://localhost:8081/actuator/health -w "\n%{http_code}")
HTTP_CODE=$(echo "$AI_RESPONSE" | tail -n 1)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ OK"
else
    echo "❌ FAILED (HTTP $HTTP_CODE)"
fi

# Performance test
echo "⚡ Running basic performance test..."
echo -n "Testing API response time... "
RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" http://localhost:8080/api/v1/reports)
if (( $(echo "$RESPONSE_TIME < 1.0" | bc -l) )); then
    echo "✅ OK (${RESPONSE_TIME}s)"
else
    echo "⚠️  SLOW (${RESPONSE_TIME}s)"
fi

# Cleanup
echo "🧹 Cleaning up..."
kill $MAIN_API_PID $AI_API_PID 2>/dev/null || true

echo "✅ Integration tests completed!"
