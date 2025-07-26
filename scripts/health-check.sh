#!/bin/bash

# =============================================================================
# 헬스체크 스크립트
# =============================================================================

set -e

ENVIRONMENT="${1:-development}"

echo "🏥 $ENVIRONMENT 환경 헬스체크 시작..."

# 환경변수 로딩
source "$(dirname "$0")/env-utils.sh"
load_env_by_environment "$ENVIRONMENT"

health_check_passed=true

# Main API Server 헬스체크
echo "🔍 Main API Server 헬스체크..."
if curl -f -s "http://localhost:${SERVER_PORT:-8080}/actuator/health" > /dev/null; then
    echo "✅ Main API Server: 정상"
    
    # 세부 헬스체크
    health_response=$(curl -s "http://localhost:${SERVER_PORT:-8080}/actuator/health" | jq -r '.status' 2>/dev/null || echo "DOWN")
    if [ "$health_response" = "UP" ]; then
        echo "  📊 상태: UP"
    else
        echo "  ❌ 상태: $health_response"
        health_check_passed=false
    fi
else
    echo "❌ Main API Server: 응답 없음"
    health_check_passed=false
fi

# AI Analysis Server 헬스체크
echo "🔍 AI Analysis Server 헬스체크..."
if curl -f -s "http://localhost:${AI_ANALYSIS_PORT:-8081}/actuator/health" > /dev/null; then
    echo "✅ AI Analysis Server: 정상"
    
    health_response=$(curl -s "http://localhost:${AI_ANALYSIS_PORT:-8081}/actuator/health" | jq -r '.status' 2>/dev/null || echo "DOWN")
    if [ "$health_response" = "UP" ]; then
        echo "  📊 상태: UP"
    else
        echo "  ❌ 상태: $health_response"
        health_check_passed=false
    fi
else
    echo "❌ AI Analysis Server: 응답 없음"
    health_check_passed=false
fi

# PostgreSQL 헬스체크
echo "🔍 PostgreSQL 헬스체크..."
if docker exec jbreport-postgres pg_isready -U "${DATABASE_USERNAME:-jbreport}" > /dev/null 2>&1; then
    echo "✅ PostgreSQL: 정상"
    
    # 연결 테스트
    if docker exec jbreport-postgres psql -U "${DATABASE_USERNAME:-jbreport}" -d "${DATABASE_USERNAME:-jbreport}" -c "SELECT 1;" > /dev/null 2>&1; then
        echo "  📊 연결: 성공"
    else
        echo "  ❌ 연결: 실패"
        health_check_passed=false
    fi
else
    echo "❌ PostgreSQL: 응답 없음"
    health_check_passed=false
fi

# Redis 헬스체크
echo "🔍 Redis 헬스체크..."
if docker exec jbreport-redis redis-cli ping > /dev/null 2>&1; then
    echo "✅ Redis: 정상"
    
    # 인증 테스트 (비밀번호가 있는 경우)
    if [ -n "$REDIS_PASSWORD" ]; then
        if docker exec jbreport-redis redis-cli -a "$REDIS_PASSWORD" ping > /dev/null 2>&1; then
            echo "  📊 인증: 성공"
        else
            echo "  ❌ 인증: 실패"
            health_check_passed=false
        fi
    fi
else
    echo "❌ Redis: 응답 없음"
    health_check_passed=false
fi

# Kafka 헬스체크
echo "🔍 Kafka 헬스체크..."
if docker exec jbreport-kafka kafka-topics --bootstrap-server localhost:9092 --list > /dev/null 2>&1; then
    echo "✅ Kafka: 정상"
    
    # 토픽 목록 확인
    topic_count=$(docker exec jbreport-kafka kafka-topics --bootstrap-server localhost:9092 --list 2>/dev/null | wc -l)
    echo "  📊 토픽 수: $topic_count"
else
    echo "❌ Kafka: 응답 없음"
    health_check_passed=false
fi

# API 엔드포인트 기능 테스트
echo "🔍 API 엔드포인트 기능 테스트..."

# 인증 없이 접근 가능한 엔드포인트 테스트
if curl -f -s "http://localhost:${SERVER_PORT:-8080}/api/v1/health" > /dev/null 2>&1; then
    echo "✅ Health 엔드포인트: 정상"
else
    echo "⚠️ Health 엔드포인트: 테스트 불가 (구현되지 않았을 수 있음)"
fi

# Swagger UI 접근 테스트
if curl -f -s "http://localhost:${SERVER_PORT:-8080}/swagger-ui.html" > /dev/null 2>&1; then
    echo "✅ Swagger UI: 접근 가능"
else
    echo "⚠️ Swagger UI: 접근 불가"
fi

# 디스크 공간 확인
echo "🔍 시스템 리소스 확인..."
disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$disk_usage" -lt 80 ]; then
    echo "✅ 디스크 사용량: ${disk_usage}% (정상)"
else
    echo "⚠️ 디스크 사용량: ${disk_usage}% (높음)"
    if [ "$disk_usage" -gt 90 ]; then
        health_check_passed=false
    fi
fi

# 메모리 사용량 확인
memory_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
if [ "$memory_usage" -lt 80 ]; then
    echo "✅ 메모리 사용량: ${memory_usage}% (정상)"
else
    echo "⚠️ 메모리 사용량: ${memory_usage}% (높음)"
    if [ "$memory_usage" -gt 90 ]; then
        health_check_passed=false
    fi
fi

# 로그 파일 크기 확인
echo "🔍 로그 파일 확인..."
if [ -f "logs/main-api.log" ]; then
    log_size=$(du -h logs/main-api.log | cut -f1)
    echo "📄 Main API 로그 크기: $log_size"
fi

if [ -f "logs/ai-analysis.log" ]; then
    log_size=$(du -h logs/ai-analysis.log | cut -f1)
    echo "📄 AI Analysis 로그 크기: $log_size"
fi

# 최근 에러 로그 확인
echo "🔍 최근 에러 로그 확인..."
if [ -f "logs/main-api.log" ]; then
    error_count=$(grep -i "error\|exception\|failed" logs/main-api.log | tail -100 | wc -l)
    if [ "$error_count" -gt 10 ]; then
        echo "⚠️ Main API: 최근 에러 로그 다수 ($error_count 건)"
    else
        echo "✅ Main API: 에러 로그 정상 ($error_count 건)"
    fi
fi

if [ -f "logs/ai-analysis.log" ]; then
    error_count=$(grep -i "error\|exception\|failed" logs/ai-analysis.log | tail -100 | wc -l)
    if [ "$error_count" -gt 10 ]; then
        echo "⚠️ AI Analysis: 최근 에러 로그 다수 ($error_count 건)"
    else
        echo "✅ AI Analysis: 에러 로그 정상 ($error_count 건)"
    fi
fi

# 결과 출력
echo ""
echo "📊 헬스체크 결과 요약:"
echo "환경: $ENVIRONMENT"
echo "체크 시간: $(date)"

if [ "$health_check_passed" = true ]; then
    echo "🎉 모든 헬스체크 통과!"
    echo ""
    echo "📊 서비스 URL:"
    echo "   Main API: http://localhost:${SERVER_PORT:-8080}"
    echo "   AI Analysis: http://localhost:${AI_ANALYSIS_PORT:-8081}"
    echo "   Swagger UI: http://localhost:${SERVER_PORT:-8080}/swagger-ui.html"
    exit 0
else
    echo "❌ 일부 헬스체크 실패"
    echo ""
    echo "💡 문제 해결 방법:"
    echo "   1. 로그 파일 확인: logs/main-api.log, logs/ai-analysis.log"
    echo "   2. 서비스 재시작: ./scripts/restart-services.sh"
    echo "   3. 환경변수 검증: ./scripts/validate-env.sh"
    exit 1
fi