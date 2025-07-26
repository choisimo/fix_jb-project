#!/bin/bash

# =============================================================================
# 선택된 서비스 재시작 스크립트
# =============================================================================

set -e

echo "🔄 선택된 서비스 재시작 시작..."

# 환경변수 로딩
source "$(dirname "$0")/env-utils.sh"

ENVIRONMENT="${ENVIRONMENT:-development}"
SERVICES="${SERVICES:-main-api,ai-analysis}"

echo "📝 환경: $ENVIRONMENT"
echo "📝 재시작할 서비스: $SERVICES"

# 서비스 목록을 배열로 변환
IFS=',' read -ra SERVICE_ARRAY <<< "$SERVICES"

# 환경변수 로드
load_env_by_environment "$ENVIRONMENT"

# 각 서비스별 재시작
for service in "${SERVICE_ARRAY[@]}"; do
    case "$service" in
        "main-api")
            echo "🔄 Main API Server 재시작 중..."
            
            # 기존 프로세스 중지
            if [ -f ".main-api.pid" ]; then
                MAIN_API_PID=$(cat .main-api.pid)
                if kill -0 "$MAIN_API_PID" 2>/dev/null; then
                    kill "$MAIN_API_PID"
                    sleep 5
                    if kill -0 "$MAIN_API_PID" 2>/dev/null; then
                        kill -9 "$MAIN_API_PID"
                    fi
                fi
                rm -f .main-api.pid
            fi
            
            # 빌드 및 시작
            cd main-api-server
            ./gradlew clean build -x test
            nohup java -jar build/libs/report-platform-*.jar \
                --spring.profiles.active="${SPRING_PROFILES_ACTIVE:-dev}" \
                --server.port="${SERVER_PORT:-8080}" \
                > ../logs/main-api.log 2>&1 &
            MAIN_API_PID=$!
            echo $MAIN_API_PID > ../.main-api.pid
            cd ..
            
            # 헬스체크
            for i in {1..20}; do
                if curl -f -s "http://localhost:${SERVER_PORT:-8080}/actuator/health" > /dev/null; then
                    echo "✅ Main API Server 재시작 완료"
                    break
                fi
                if [ $i -eq 20 ]; then
                    echo "❌ Main API Server 헬스체크 실패"
                    exit 1
                fi
                sleep 3
            done
            ;;
            
        "ai-analysis")
            echo "🔄 AI Analysis Server 재시작 중..."
            
            # 기존 프로세스 중지
            if [ -f ".ai-analysis.pid" ]; then
                AI_API_PID=$(cat .ai-analysis.pid)
                if kill -0 "$AI_API_PID" 2>/dev/null; then
                    kill "$AI_API_PID"
                    sleep 5
                    if kill -0 "$AI_API_PID" 2>/dev/null; then
                        kill -9 "$AI_API_PID"
                    fi
                fi
                rm -f .ai-analysis.pid
            fi
            
            # 빌드 및 시작
            cd ai-analysis-server
            ./gradlew clean build -x test
            nohup java -jar build/libs/ai-analysis-*.jar \
                --spring.profiles.active="${SPRING_PROFILES_ACTIVE:-dev}" \
                --server.port="${AI_ANALYSIS_PORT:-8081}" \
                > ../logs/ai-analysis.log 2>&1 &
            AI_API_PID=$!
            echo $AI_API_PID > ../.ai-analysis.pid
            cd ..
            
            # 헬스체크
            for i in {1..20}; do
                if curl -f -s "http://localhost:${AI_ANALYSIS_PORT:-8081}/actuator/health" > /dev/null; then
                    echo "✅ AI Analysis Server 재시작 완료"
                    break
                fi
                if [ $i -eq 20 ]; then
                    echo "❌ AI Analysis Server 헬스체크 실패"
                    exit 1
                fi
                sleep 3
            done
            ;;
            
        "postgres")
            echo "🔄 PostgreSQL 재시작 중..."
            docker-compose restart postgres
            sleep 10
            
            # 헬스체크
            for i in {1..15}; do
                if docker exec jbreport-postgres pg_isready -U "${DATABASE_USERNAME:-jbreport}" > /dev/null 2>&1; then
                    echo "✅ PostgreSQL 재시작 완료"
                    break
                fi
                if [ $i -eq 15 ]; then
                    echo "❌ PostgreSQL 헬스체크 실패"
                    exit 1
                fi
                sleep 2
            done
            ;;
            
        "redis")
            echo "🔄 Redis 재시작 중..."
            docker-compose restart redis
            sleep 5
            
            # 헬스체크
            for i in {1..10}; do
                if docker exec jbreport-redis redis-cli ping > /dev/null 2>&1; then
                    echo "✅ Redis 재시작 완료"
                    break
                fi
                if [ $i -eq 10 ]; then
                    echo "❌ Redis 헬스체크 실패"
                    exit 1
                fi
                sleep 2
            done
            ;;
            
        "kafka")
            echo "🔄 Kafka 재시작 중..."
            docker-compose restart kafka
            sleep 15
            echo "✅ Kafka 재시작 완료"
            ;;
            
        *)
            echo "⚠️ 알 수 없는 서비스: $service"
            ;;
    esac
done

echo ""
echo "🎉 선택된 서비스들이 성공적으로 재시작되었습니다!"
echo "재시작된 서비스: ${SERVICES}"
echo "재시작 완료 시간: $(date)"