#!/bin/bash

# =============================================================================
# 서비스 재시작 스크립트
# =============================================================================

set -e

echo "🔄 서비스 재시작 시작..."

# 환경변수 로딩
source "$(dirname "$0")/env-utils.sh"

# 환경 설정
ENVIRONMENT="${ENVIRONMENT:-development}"
ENV_FILE="${ENV_FILE:-.env}"

echo "📝 환경: $ENVIRONMENT"
echo "📝 환경변수 파일: $ENV_FILE"

# 환경변수 로드
if ! load_env "$ENV_FILE"; then
    echo "❌ 환경변수 로딩 실패"
    exit 1
fi

# 필수 환경변수 확인
required_vars=("DATABASE_PASSWORD" "REDIS_PASSWORD" "JWT_SECRET")
if ! validate_required_vars "${required_vars[@]}"; then
    exit 1
fi

# 서비스 중지
echo "🛑 기존 서비스 중지 중..."

# Java 프로세스 중지
if [ -f ".main-api.pid" ]; then
    MAIN_API_PID=$(cat .main-api.pid)
    if kill -0 "$MAIN_API_PID" 2>/dev/null; then
        echo "🛑 Main API Server 중지 (PID: $MAIN_API_PID)"
        kill "$MAIN_API_PID"
        sleep 5
        # 강제 종료가 필요한 경우
        if kill -0 "$MAIN_API_PID" 2>/dev/null; then
            kill -9 "$MAIN_API_PID"
        fi
    fi
    rm -f .main-api.pid
fi

if [ -f ".ai-analysis.pid" ]; then
    AI_API_PID=$(cat .ai-analysis.pid)
    if kill -0 "$AI_API_PID" 2>/dev/null; then
        echo "🛑 AI Analysis Server 중지 (PID: $AI_API_PID)"
        kill "$AI_API_PID"
        sleep 5
        if kill -0 "$AI_API_PID" 2>/dev/null; then
            kill -9 "$AI_API_PID"
        fi
    fi
    rm -f .ai-analysis.pid
fi

# Docker 서비스가 실행 중인 경우 재시작
if docker-compose ps | grep -q "Up"; then
    echo "🔄 Docker 서비스 재시작 중..."
    docker-compose restart postgres redis kafka zookeeper
    
    # 서비스 준비 대기
    echo "⏳ 인프라 서비스 준비 대기..."
    sleep 30
    
    # PostgreSQL 헬스체크
    for i in {1..30}; do
        if docker exec jbreport-postgres pg_isready -U "${DATABASE_USERNAME:-jbreport}" > /dev/null 2>&1; then
            echo "✅ PostgreSQL 준비 완료"
            break
        fi
        if [ $i -eq 30 ]; then
            echo "❌ PostgreSQL 준비 실패"
            exit 1
        fi
        sleep 2
    done
    
    # Redis 헬스체크
    for i in {1..15}; do
        if docker exec jbreport-redis redis-cli ping > /dev/null 2>&1; then
            echo "✅ Redis 준비 완료"
            break
        fi
        if [ $i -eq 15 ]; then
            echo "❌ Redis 준비 실패"
            exit 1
        fi
        sleep 2
    done
fi

# 로그 디렉토리 생성
mkdir -p logs

# Main API Server 빌드 및 시작
echo "🔨 Main API Server 빌드 중..."
cd main-api-server
if ! ./gradlew clean build -x test; then
    echo "❌ Main API Server 빌드 실패"
    exit 1
fi

echo "🚀 Main API Server 시작 중..."
nohup java -jar build/libs/report-platform-*.jar \
    --spring.profiles.active="${SPRING_PROFILES_ACTIVE:-dev}" \
    --server.port="${SERVER_PORT:-8080}" \
    > ../logs/main-api.log 2>&1 &
MAIN_API_PID=$!
echo $MAIN_API_PID > ../.main-api.pid
echo "✅ Main API Server 시작됨 (PID: $MAIN_API_PID)"
cd ..

# AI Analysis Server 빌드 및 시작
echo "🔨 AI Analysis Server 빌드 중..."
cd ai-analysis-server
if ! ./gradlew clean build -x test; then
    echo "❌ AI Analysis Server 빌드 실패"
    exit 1
fi

echo "🚀 AI Analysis Server 시작 중..."
nohup java -jar build/libs/ai-analysis-*.jar \
    --spring.profiles.active="${SPRING_PROFILES_ACTIVE:-dev}" \
    --server.port="${AI_ANALYSIS_PORT:-8081}" \
    > ../logs/ai-analysis.log 2>&1 &
AI_API_PID=$!
echo $AI_API_PID > ../.ai-analysis.pid
echo "✅ AI Analysis Server 시작됨 (PID: $AI_API_PID)"
cd ..

# 서비스 시작 대기
echo "⏳ 서비스 시작 대기..."
sleep 30

# 헬스체크
echo "🏥 헬스체크 수행 중..."

# Main API 헬스체크
for i in {1..30}; do
    if curl -f -s "http://localhost:${SERVER_PORT:-8080}/actuator/health" > /dev/null; then
        echo "✅ Main API Server 헬스체크 통과"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ Main API Server 헬스체크 실패"
        cat logs/main-api.log | tail -20
        exit 1
    fi
    sleep 3
done

# AI Analysis 헬스체크
for i in {1..30}; do
    if curl -f -s "http://localhost:${AI_ANALYSIS_PORT:-8081}/actuator/health" > /dev/null; then
        echo "✅ AI Analysis Server 헬스체크 통과"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ AI Analysis Server 헬스체크 실패"
        cat logs/ai-analysis.log | tail -20
        exit 1
    fi
    sleep 3
done

echo ""
echo "🎉 모든 서비스가 성공적으로 재시작되었습니다!"
echo ""
echo "📊 서비스 상태:"
echo "   Main API: http://localhost:${SERVER_PORT:-8080} (PID: $MAIN_API_PID)"
echo "   AI Analysis: http://localhost:${AI_ANALYSIS_PORT:-8081} (PID: $AI_API_PID)"
echo "   Swagger UI: http://localhost:${SERVER_PORT:-8080}/swagger-ui.html"
echo ""
echo "📝 로그 파일:"
echo "   Main API: logs/main-api.log"
echo "   AI Analysis: logs/ai-analysis.log"
echo ""
echo "재시작 완료 시간: $(date)"