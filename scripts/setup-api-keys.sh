#!/bin/bash

# =============================================================================
# API 키 설정 관리 스크립트
# =============================================================================
# 사용법: ./scripts/setup-api-keys.sh

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 프로젝트 루트 디렉토리
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$PROJECT_ROOT/config"
API_KEYS_FILE="$CONFIG_DIR/api-keys.env"

echo -e "${BLUE}==============================================================================${NC}"
echo -e "${BLUE}                        API 키 설정 관리 스크립트${NC}"
echo -e "${BLUE}==============================================================================${NC}"

# config 디렉토리 생성
mkdir -p "$CONFIG_DIR"

# 1. 중앙화된 API 키 파일 복사
copy_api_keys_file() {
    echo -e "${YELLOW}1. API 키 설정 파일 준비 중...${NC}"
    
    if [ ! -f "$API_KEYS_FILE" ]; then
        echo -e "${RED}오류: $API_KEYS_FILE 파일이 없습니다.${NC}"
        echo -e "${YELLOW}config/api-keys.env 파일을 먼저 생성해주세요.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ API 키 설정 파일이 준비되었습니다: $API_KEYS_FILE${NC}"
}

# 2. 각 서비스의 .env 파일 업데이트
update_service_env_files() {
    echo -e "${YELLOW}2. 서비스별 환경변수 파일 업데이트 중...${NC}"
    
    # 프로젝트 루트 .env 파일 업데이트
    echo -e "${BLUE}  → 프로젝트 루트 .env 파일 업데이트${NC}"
    cp "$API_KEYS_FILE" "$PROJECT_ROOT/.env"
    
    # main-api-server .env 파일 생성/업데이트
    echo -e "${BLUE}  → main-api-server .env 파일 업데이트${NC}"
    cp "$API_KEYS_FILE" "$PROJECT_ROOT/main-api-server/.env"
    
    # ai-analysis-server .env 파일 생성/업데이트
    echo -e "${BLUE}  → ai-analysis-server .env 파일 업데이트${NC}"
    cp "$API_KEYS_FILE" "$PROJECT_ROOT/ai-analysis-server/.env"
    
    echo -e "${GREEN}✓ 모든 서비스의 환경변수 파일이 업데이트되었습니다.${NC}"
}

# 3. Docker Compose 환경변수 파일 업데이트
update_docker_env() {
    echo -e "${YELLOW}3. Docker Compose 환경변수 파일 업데이트 중...${NC}"
    
    # Docker용 .env 파일 생성
    cp "$API_KEYS_FILE" "$PROJECT_ROOT/.env.docker"
    
    echo -e "${GREEN}✓ Docker Compose 환경변수 파일이 업데이트되었습니다.${NC}"
}

# 4. API 키 설정 검증
validate_api_keys() {
    echo -e "${YELLOW}4. API 키 설정 검증 중...${NC}"
    
    source "$API_KEYS_FILE"
    
    # 필수 API 키 검증
    local errors=0
    
    # Roboflow API 키 검증
    if [[ "$ROBOFLOW_API_KEY" == "your_roboflow_api_key_here" || -z "$ROBOFLOW_API_KEY" ]]; then
        echo -e "${RED}  ✗ ROBOFLOW_API_KEY가 설정되지 않았습니다.${NC}"
        errors=$((errors + 1))
    else
        echo -e "${GREEN}  ✓ ROBOFLOW_API_KEY가 설정되었습니다.${NC}"
    fi
    
    # OpenRouter API 키 검증
    if [[ "$OPENROUTER_API_KEY" == "your_openrouter_api_key_here" || -z "$OPENROUTER_API_KEY" ]]; then
        echo -e "${RED}  ✗ OPENROUTER_API_KEY가 설정되지 않았습니다.${NC}"
        errors=$((errors + 1))
    else
        echo -e "${GREEN}  ✓ OPENROUTER_API_KEY가 설정되었습니다.${NC}"
    fi
    
    # JWT Secret 검증
    if [[ "$JWT_SECRET" == "your_jwt_secret_key_here_minimum_256_bits_required" || -z "$JWT_SECRET" ]]; then
        echo -e "${RED}  ✗ JWT_SECRET이 설정되지 않았습니다.${NC}"
        errors=$((errors + 1))
    else
        echo -e "${GREEN}  ✓ JWT_SECRET이 설정되었습니다.${NC}"
    fi
    
    if [ $errors -gt 0 ]; then
        echo -e "${RED}${errors}개의 설정 오류가 발견되었습니다. config/api-keys.env 파일을 확인해주세요.${NC}"
        return 1
    else
        echo -e "${GREEN}✓ 모든 API 키가 올바르게 설정되었습니다.${NC}"
        return 0
    fi
}

# 5. 설정 적용 확인
show_configuration_summary() {
    echo -e "${YELLOW}5. 설정 요약${NC}"
    
    source "$API_KEYS_FILE"
    
    echo -e "${BLUE}Roboflow 설정:${NC}"
    echo -e "  - Workspace: $ROBOFLOW_WORKSPACE"
    echo -e "  - Project: $ROBOFLOW_PROJECT"
    echo -e "  - Model: $ROBOFLOW_MODEL_ID"
    
    echo -e "${BLUE}OpenRouter 설정:${NC}"
    echo -e "  - Model: $OPENROUTER_MODEL"
    echo -e "  - Base URL: $OPENROUTER_BASE_URL"
    
    echo -e "${BLUE}서버 포트:${NC}"
    echo -e "  - Main API Server: $SERVER_PORT"
    echo -e "  - AI Analysis Server: $AI_ANALYSIS_PORT"
}

# 메인 실행
main() {
    copy_api_keys_file
    update_service_env_files
    update_docker_env
    
    if validate_api_keys; then
        show_configuration_summary
        echo -e "${GREEN}==============================================================================${NC}"
        echo -e "${GREEN}                    API 키 설정이 성공적으로 완료되었습니다!${NC}"
        echo -e "${GREEN}==============================================================================${NC}"
        echo -e "${YELLOW}다음 단계:${NC}"
        echo -e "1. config/api-keys.env 파일에서 실제 API 키로 교체"
        echo -e "2. ./scripts/setup-api-keys.sh 다시 실행"
        echo -e "3. 서비스 재시작: docker-compose up -d"
    else
        echo -e "${RED}==============================================================================${NC}"
        echo -e "${RED}                      API 키 설정에 오류가 있습니다.${NC}"
        echo -e "${RED}==============================================================================${NC}"
        exit 1
    fi
}

# 스크립트 실행
main "$@"