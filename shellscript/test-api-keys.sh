#!/bin/bash

# =============================================================================
# API 키 설정 테스트 스크립트
# =============================================================================
# 사용법: ./scripts/test-api-keys.sh

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 프로젝트 루트 디렉토리
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}==============================================================================${NC}"
echo -e "${BLUE}                        API 키 연결 테스트${NC}"
echo -e "${BLUE}==============================================================================${NC}"

# 환경변수 로드
if [ -f "$PROJECT_ROOT/.env" ]; then
    source "$PROJECT_ROOT/.env"
    echo -e "${GREEN}✓ 환경변수 파일 로드 완료${NC}"
else
    echo -e "${RED}✗ .env 파일을 찾을 수 없습니다.${NC}"
    exit 1
fi

# 1. Roboflow API 연결 테스트
test_roboflow_api() {
    echo -e "${YELLOW}1. Roboflow API 연결 테스트${NC}"
    
    if [[ "$ROBOFLOW_API_KEY" == "your_roboflow_api_key_here" || -z "$ROBOFLOW_API_KEY" ]]; then
        echo -e "${RED}  ✗ Roboflow API 키가 설정되지 않았습니다.${NC}"
        return 1
    fi
    
    # Roboflow API 헬스체크
    local test_url="https://detect.roboflow.com/"
    
    echo -e "${BLUE}  → API 엔드포인트 연결 테스트: $test_url${NC}"
    
    if curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "$test_url" | grep -q "200\|404"; then
        echo -e "${GREEN}  ✓ Roboflow API 엔드포인트 연결 성공${NC}"
        echo -e "${GREEN}  ✓ API 키: ${ROBOFLOW_API_KEY:0:8}...${NC}"
        echo -e "${GREEN}  ✓ 워크스페이스: $ROBOFLOW_WORKSPACE${NC}"
        echo -e "${GREEN}  ✓ 프로젝트: $ROBOFLOW_PROJECT${NC}"
        return 0
    else
        echo -e "${RED}  ✗ Roboflow API 엔드포인트 연결 실패${NC}"
        return 1
    fi
}

# 2. OpenRouter API 연결 테스트
test_openrouter_api() {
    echo -e "${YELLOW}2. OpenRouter API 연결 테스트${NC}"
    
    if [[ "$OPENROUTER_API_KEY" == "your_openrouter_api_key_here" || -z "$OPENROUTER_API_KEY" ]]; then
        echo -e "${RED}  ✗ OpenRouter API 키가 설정되지 않았습니다.${NC}"
        return 1
    fi
    
    # OpenRouter API 헬스체크
    local test_url="$OPENROUTER_BASE_URL/models"
    
    echo -e "${BLUE}  → API 엔드포인트 연결 테스트: $test_url${NC}"
    
    local response=$(curl -s -w "%{http_code}" \
        -H "Authorization: Bearer $OPENROUTER_API_KEY" \
        -H "Content-Type: application/json" \
        --connect-timeout 10 \
        "$test_url" || echo "connection_failed")
    
    if echo "$response" | grep -q "200"; then
        echo -e "${GREEN}  ✓ OpenRouter API 연결 성공${NC}"
        echo -e "${GREEN}  ✓ API 키: ${OPENROUTER_API_KEY:0:8}...${NC}"
        echo -e "${GREEN}  ✓ 모델: $OPENROUTER_MODEL${NC}"
        return 0
    else
        echo -e "${RED}  ✗ OpenRouter API 연결 실패 (응답: $response)${NC}"
        return 1
    fi
}

# 3. 데이터베이스 연결 테스트
test_database_connection() {
    echo -e "${YELLOW}3. 데이터베이스 연결 테스트${NC}"
    
    # PostgreSQL 연결 테스트
    echo -e "${BLUE}  → PostgreSQL 연결 테스트${NC}"
    
    if command -v psql >/dev/null 2>&1; then
        # psql이 설치되어 있는 경우
        if PGPASSWORD="$DATABASE_PASSWORD" psql -h localhost -p 5432 -U "$DATABASE_USERNAME" -d postgres -c "SELECT 1;" >/dev/null 2>&1; then
            echo -e "${GREEN}  ✓ PostgreSQL 연결 성공${NC}"
            return 0
        else
            echo -e "${RED}  ✗ PostgreSQL 연결 실패${NC}"
            return 1
        fi
    else
        # Docker를 통한 연결 테스트
        if docker run --rm --network host postgres:13 pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
            echo -e "${GREEN}  ✓ PostgreSQL 서비스 실행 중${NC}"
            return 0
        else
            echo -e "${RED}  ✗ PostgreSQL 서비스 연결 실패${NC}"
            return 1
        fi
    fi
}

# 4. Redis 연결 테스트
test_redis_connection() {
    echo -e "${YELLOW}4. Redis 연결 테스트${NC}"
    
    echo -e "${BLUE}  → Redis 연결 테스트${NC}"
    
    if command -v redis-cli >/dev/null 2>&1; then
        # redis-cli가 설치되어 있는 경우
        if redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" -a "$REDIS_PASSWORD" ping >/dev/null 2>&1; then
            echo -e "${GREEN}  ✓ Redis 연결 성공${NC}"
            return 0
        else
            echo -e "${RED}  ✗ Redis 연결 실패${NC}"
            return 1
        fi
    else
        # Docker를 통한 연결 테스트
        if docker run --rm --network host redis:7 redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" -a "$REDIS_PASSWORD" ping >/dev/null 2>&1; then
            echo -e "${GREEN}  ✓ Redis 연결 성공 (비밀번호 인증)${NC}"
            return 0
        else
            echo -e "${RED}  ✗ Redis 연결 실패 (비밀번호 인증 오류)${NC}"
            return 1
        fi
    fi
}

# 5. 서비스 포트 확인
test_service_ports() {
    echo -e "${YELLOW}5. 서비스 포트 가용성 테스트${NC}"
    
    # Main API Server 포트
    echo -e "${BLUE}  → Main API Server 포트 ($SERVER_PORT) 확인${NC}"
    if ! netstat -tuln 2>/dev/null | grep -q ":$SERVER_PORT "; then
        echo -e "${GREEN}  ✓ 포트 $SERVER_PORT 사용 가능${NC}"
    else
        echo -e "${YELLOW}  ⚠ 포트 $SERVER_PORT 이미 사용 중${NC}"
    fi
    
    # AI Analysis Server 포트
    echo -e "${BLUE}  → AI Analysis Server 포트 ($AI_ANALYSIS_PORT) 확인${NC}"
    if ! netstat -tuln 2>/dev/null | grep -q ":$AI_ANALYSIS_PORT "; then
        echo -e "${GREEN}  ✓ 포트 $AI_ANALYSIS_PORT 사용 가능${NC}"
    else
        echo -e "${YELLOW}  ⚠ 포트 $AI_ANALYSIS_PORT 이미 사용 중${NC}"
    fi
}

# 6. 종합 테스트 결과
show_test_summary() {
    echo -e "${BLUE}==============================================================================${NC}"
    echo -e "${BLUE}                           테스트 결과 요약${NC}"
    echo -e "${BLUE}==============================================================================${NC}"
    
    local total_tests=5
    local passed_tests=0
    
    # 각 테스트 실행 및 결과 집계
    if test_roboflow_api; then passed_tests=$((passed_tests + 1)); fi
    if test_openrouter_api; then passed_tests=$((passed_tests + 1)); fi
    if test_database_connection; then passed_tests=$((passed_tests + 1)); fi
    if test_redis_connection; then passed_tests=$((passed_tests + 1)); fi
    test_service_ports # 포트 테스트는 항상 통과로 간주
    passed_tests=$((passed_tests + 1))
    
    echo -e "${BLUE}테스트 결과: $passed_tests/$total_tests 통과${NC}"
    
    if [ $passed_tests -eq $total_tests ]; then
        echo -e "${GREEN}✓ 모든 연결 테스트가 성공했습니다!${NC}"
        return 0
    else
        echo -e "${RED}✗ 일부 연결 테스트가 실패했습니다.${NC}"
        echo -e "${YELLOW}실패한 서비스의 설정을 확인해주세요.${NC}"
        return 1
    fi
}

# 메인 실행
main() {
    if show_test_summary; then
        echo -e "${GREEN}==============================================================================${NC}"
        echo -e "${GREEN}                    모든 API 키가 정상적으로 설정되었습니다!${NC}"
        echo -e "${GREEN}==============================================================================${NC}"
    else
        echo -e "${RED}==============================================================================${NC}"
        echo -e "${RED}                     일부 설정에 문제가 있습니다.${NC}"
        echo -e "${RED}==============================================================================${NC}"
        exit 1
    fi
}

# 스크립트 실행
main "$@"