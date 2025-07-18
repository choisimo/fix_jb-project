#!/bin/bash

# =============================================================================
# OpenRouter API 비전 모델 테스트 스크립트
# =============================================================================
# 사용법: ./shellscript/test-openrouter-vision.sh

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
echo -e "${BLUE}                OpenRouter API 비전 모델 테스트${NC}"
echo -e "${BLUE}==============================================================================${NC}"

# 환경변수 로드
if [ -f "$PROJECT_ROOT/.env" ]; then
    source "$PROJECT_ROOT/.env"
    echo -e "${GREEN}✓ 환경변수 파일 로드 완료${NC}"
else
    echo -e "${RED}✗ .env 파일을 찾을 수 없습니다.${NC}"
    exit 1
fi

# API 키 확인
if [[ -z "$OPENROUTER_API_KEY" || "$OPENROUTER_API_KEY" == "your_openrouter_api_key_here" ]]; then
    echo -e "${RED}✗ OpenRouter API 키가 설정되지 않았습니다.${NC}"
    echo -e "${YELLOW}  .env 파일에서 OPENROUTER_API_KEY를 설정해주세요.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ OpenRouter API 키 확인 완료${NC}"

# 1. 기본 텍스트 모델 테스트
test_text_model() {
    echo -e "${YELLOW}1. 텍스트 모델 테스트${NC}"
    
    local response=$(curl -s -w "%{http_code}" \
        -H "Authorization: Bearer $OPENROUTER_API_KEY" \
        -H "Content-Type: application/json" \
        -H "HTTP-Referer: https://jeonbuk-report-platform.com" \
        -H "X-Title: 전북 신고 플랫폼" \
        -d '{
            "model": "anthropic/claude-3.5-sonnet:beta",
            "messages": [
                {
                    "role": "user",
                    "content": "Hello! Please respond with a simple greeting."
                }
            ],
            "max_tokens": 100,
            "temperature": 0.7
        }' \
        "https://openrouter.ai/api/v1/chat/completions" 2>/dev/null || echo "connection_failed")
    
    local http_code="${response: -3}"
    local body="${response%???}"
    
    if [[ "$http_code" == "200" ]]; then
        echo -e "${GREEN}  ✓ 텍스트 모델 (Claude 3.5 Sonnet) 작동 확인${NC}"
        echo -e "${BLUE}  응답: $(echo "$body" | jq -r '.choices[0].message.content' 2>/dev/null || echo "파싱 오류")${NC}"
        return 0
    else
        echo -e "${RED}  ✗ 텍스트 모델 테스트 실패 (HTTP: $http_code)${NC}"
        echo -e "${RED}  응답: $body${NC}"
        return 1
    fi
}

# 2. 비전 모델 테스트 (샘플 이미지 URL 사용)
test_vision_model() {
    echo -e "${YELLOW}2. 비전 모델 테스트${NC}"
    
    # 공개 테스트 이미지 URL
    local test_image_url="https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/320px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg"
    
    echo -e "${BLUE}  → 테스트 이미지: $test_image_url${NC}"
    
    local response=$(curl -s -w "%{http_code}" \
        -H "Authorization: Bearer $OPENROUTER_API_KEY" \
        -H "Content-Type: application/json" \
        -H "HTTP-Referer: https://jeonbuk-report-platform.com" \
        -H "X-Title: 전북 신고 플랫폼" \
        -d "{
            \"model\": \"openai/gpt-4o\",
            \"messages\": [
                {
                    \"role\": \"user\",
                    \"content\": [
                        {
                            \"type\": \"text\",
                            \"text\": \"이 이미지를 분석해주세요. 무엇이 보이나요?\"
                        },
                        {
                            \"type\": \"image_url\",
                            \"image_url\": {
                                \"url\": \"$test_image_url\"
                            }
                        }
                    ]
                }
            ],
            \"max_tokens\": 300,
            \"temperature\": 0.7
        }" \
        "https://openrouter.ai/api/v1/chat/completions" 2>/dev/null || echo "connection_failed")
    
    local http_code="${response: -3}"
    local body="${response%???}"
    
    if [[ "$http_code" == "200" ]]; then
        echo -e "${GREEN}  ✓ 비전 모델 (GPT-4o) 작동 확인${NC}"
        echo -e "${BLUE}  이미지 분석 결과: $(echo "$body" | jq -r '.choices[0].message.content' 2>/dev/null || echo "파싱 오류")${NC}"
        return 0
    else
        echo -e "${RED}  ✗ 비전 모델 테스트 실패 (HTTP: $http_code)${NC}"
        echo -e "${RED}  응답: $body${NC}"
        
        # Claude 3.5 Sonnet으로 재시도
        echo -e "${YELLOW}  → Claude 3.5 Sonnet으로 재시도...${NC}"
        
        local claude_response=$(curl -s -w "%{http_code}" \
            -H "Authorization: Bearer $OPENROUTER_API_KEY" \
            -H "Content-Type: application/json" \
            -H "HTTP-Referer: https://jeonbuk-report-platform.com" \
            -H "X-Title: 전북 신고 플랫폼" \
            -d "{
                \"model\": \"anthropic/claude-3.5-sonnet:beta\",
                \"messages\": [
                    {
                        \"role\": \"user\",
                        \"content\": [
                            {
                                \"type\": \"text\",
                                \"text\": \"이 이미지를 분석해주세요. 무엇이 보이나요?\"
                            },
                            {
                                \"type\": \"image_url\",
                                \"image_url\": {
                                    \"url\": \"$test_image_url\"
                                }
                            }
                        ]
                    }
                ],
                \"max_tokens\": 300,
                \"temperature\": 0.7
            }" \
            "https://openrouter.ai/api/v1/chat/completions" 2>/dev/null || echo "connection_failed")
        
        local claude_http_code="${claude_response: -3}"
        local claude_body="${claude_response%???}"
        
        if [[ "$claude_http_code" == "200" ]]; then
            echo -e "${GREEN}  ✓ 비전 모델 (Claude 3.5 Sonnet) 작동 확인${NC}"
            echo -e "${BLUE}  이미지 분석 결과: $(echo "$claude_body" | jq -r '.choices[0].message.content' 2>/dev/null || echo "파싱 오류")${NC}"
            return 0
        else
            echo -e "${RED}  ✗ Claude 3.5 Sonnet도 실패 (HTTP: $claude_http_code)${NC}"
            return 1
        fi
    fi
}

# 3. 계정 크레딧 확인
check_credits() {
    echo -e "${YELLOW}3. 계정 크레딧 확인${NC}"
    
    # OpenRouter credits API는 공식적으로 제공되지 않으므로 간접적으로 확인
    echo -e "${BLUE}  → 작은 요청으로 크레딧 상태 확인 중...${NC}"
    
    local response=$(curl -s -w "%{http_code}" \
        -H "Authorization: Bearer $OPENROUTER_API_KEY" \
        -H "Content-Type: application/json" \
        -H "HTTP-Referer: https://jeonbuk-report-platform.com" \
        -H "X-Title: 전북 신고 플랫폼" \
        -d '{
            "model": "anthropic/claude-3.5-sonnet:beta",
            "messages": [{"role": "user", "content": "hi"}],
            "max_tokens": 5
        }' \
        "https://openrouter.ai/api/v1/chat/completions" 2>/dev/null || echo "connection_failed")
    
    local http_code="${response: -3}"
    local body="${response%???}"
    
    if [[ "$http_code" == "200" ]]; then
        echo -e "${GREEN}  ✓ 계정에 충분한 크레딧이 있습니다${NC}"
        # 사용량 정보 추출
        local usage=$(echo "$body" | jq -r '.usage.total_tokens' 2>/dev/null || echo "unknown")
        echo -e "${BLUE}  토큰 사용량: $usage${NC}"
        return 0
    elif [[ "$http_code" == "402" ]]; then
        echo -e "${RED}  ✗ 계정에 크레딧이 부족합니다${NC}"
        echo -e "${YELLOW}  OpenRouter 계정에 크레딧을 충전해주세요.${NC}"
        return 1
    elif [[ "$http_code" == "401" ]]; then
        echo -e "${RED}  ✗ API 키가 유효하지 않습니다${NC}"
        return 1
    else
        echo -e "${RED}  ✗ 알 수 없는 오류 (HTTP: $http_code)${NC}"
        echo -e "${RED}  응답: $body${NC}"
        return 1
    fi
}

# 4. 파일 서버 연동 테스트
test_file_server_integration() {
    echo -e "${YELLOW}4. 파일 서버 연동 테스트${NC}"
    
    # nginx 프록시 상태 확인
    echo -e "${BLUE}  → nginx 프록시 상태 확인...${NC}"
    
    if curl -s -f "http://localhost:8090/health" >/dev/null; then
        echo -e "${GREEN}  ✓ nginx 프록시 서버 작동 중${NC}"
    else
        echo -e "${RED}  ✗ nginx 프록시 서버에 연결할 수 없습니다${NC}"
        echo -e "${YELLOW}  nginx 서버를 시작해주세요: sudo systemctl start nginx${NC}"
        return 1
    fi
    
    # 파일 서버 상태 확인
    echo -e "${BLUE}  → 파일 서버 상태 확인...${NC}"
    
    if curl -s -f "http://localhost:8000/health" >/dev/null 2>&1; then
        echo -e "${GREEN}  ✓ 파일 서버 작동 중${NC}"
    else
        echo -e "${RED}  ✗ 파일 서버에 연결할 수 없습니다${NC}"
        echo -e "${YELLOW}  파일 서버를 시작해주세요${NC}"
        return 1
    fi
    
    return 0
}

# 메인 테스트 실행
main() {
    local total_tests=4
    local passed_tests=0
    
    if test_text_model; then passed_tests=$((passed_tests + 1)); fi
    echo
    if test_vision_model; then passed_tests=$((passed_tests + 1)); fi
    echo
    if check_credits; then passed_tests=$((passed_tests + 1)); fi
    echo
    if test_file_server_integration; then passed_tests=$((passed_tests + 1)); fi
    
    echo
    echo -e "${BLUE}==============================================================================${NC}"
    echo -e "${BLUE}                           테스트 결과 요약${NC}"
    echo -e "${BLUE}==============================================================================${NC}"
    echo -e "${BLUE}테스트 결과: $passed_tests/$total_tests 통과${NC}"
    
    if [ $passed_tests -eq $total_tests ]; then
        echo -e "${GREEN}✓ 모든 테스트가 성공했습니다!${NC}"
        echo -e "${GREEN}OpenRouter API와 비전 모델이 정상적으로 작동합니다.${NC}"
        return 0
    else
        echo -e "${RED}✗ 일부 테스트가 실패했습니다.${NC}"
        echo -e "${YELLOW}실패한 항목을 확인하고 설정을 수정해주세요.${NC}"
        return 1
    fi
}

# 스크립트 실행
main "$@"