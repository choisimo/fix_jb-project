#!/bin/bash

set -e

echo "🚀 Starting JB Report Platform Production Deployment..."

# Load environment utilities
source "$(dirname "$0")/env-utils.sh"

# Load production environment variables
load_env_by_environment "production"

# Check for required environment variables
required_vars=(
    "DATABASE_PASSWORD"
    "REDIS_PASSWORD"
    "JWT_SECRET"
    "GOOGLE_CLIENT_ID"
    "GOOGLE_CLIENT_SECRET"
    "KAKAO_CLIENT_ID"
    "KAKAO_CLIENT_SECRET"
    "ROBOFLOW_API_KEY"
    "ROBOFLOW_MODEL_ID"
    "OPENROUTER_API_KEY"
)

validate_required_vars "${required_vars[@]}"

# Print environment info
print_env_info

# Build services
echo "📦 Building services..."
cd main-api-server && ./gradlew clean build -x test && cd ..
cd ai-analysis-server && ./gradlew clean build -x test && cd ..

# Run database migrations
echo "🗄️ Running database migrations..."
docker-compose -f docker-compose.prod.yml run --rm main-api \
    java -jar /app/app.jar --spring.profiles.active=prod --spring.jpa.hibernate.ddl-auto=update

# Start services
echo "🎯 Starting production services..."
docker-compose -f docker-compose.prod.yml up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be healthy..."
sleep 30

# Check service health
services=("postgres" "redis" "kafka" "main-api" "ai-analysis")
all_healthy=true

for service in "${services[@]}"; do
    if docker-compose -f docker-compose.prod.yml ps | grep "$service" | grep -q "healthy"; then
        echo "✅ $service is healthy"
    else
        echo "❌ $service is not healthy"
        all_healthy=false
    fi
done

if [ "$all_healthy" = true ]; then
    echo "✅ All services are running and healthy!"
    echo "📊 Access the API at: https://api.jbreport.com"
    echo "📝 Access Swagger UI at: https://api.jbreport.com/swagger-ui.html"
else
    echo "❌ Some services failed to start properly"
    exit 1
fi
