#!/bin/bash

# =============================================================================
# AI 분석 파이프라인 종합 테스트 스크립트
# =============================================================================
# 사용법: ./shellscript/test-ai-analysis-pipeline.sh

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 프로젝트 루트 디렉토리
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}===============================================================================${NC}"
echo -e "${BLUE}                     AI 분석 파이프라인 종합 테스트${NC}"
echo -e "${BLUE}===============================================================================${NC}"

# 환경변수 로드
if [ -f "$PROJECT_ROOT/.env" ]; then
    source "$PROJECT_ROOT/.env"
    echo -e "${GREEN}✓ 환경변수 파일 로드 완료${NC}"
else
    echo -e "${RED}✗ .env 파일을 찾을 수 없습니다.${NC}"
    exit 1
fi

# 1. 기본 환경 확인
test_environment() {
    echo -e "${YELLOW}1. 기본 환경 확인${NC}"
    
    local passed=0
    local total=4
    
    # OpenRouter API 키 확인
    if [[ -n "$OPENROUTER_API_KEY" && "$OPENROUTER_API_KEY" != "your_openrouter_api_key_here" ]]; then
        echo -e "${GREEN}  ✓ OpenRouter API 키 설정됨${NC}"
        ((passed++))
    else
        echo -e "${RED}  ✗ OpenRouter API 키 누락${NC}"
    fi
    
    # 파일 서버 상태 확인
    if curl -s -f "http://localhost:8000/health" >/dev/null 2>&1; then
        echo -e "${GREEN}  ✓ 파일 서버 작동 중${NC}"
        ((passed++))
    else
        echo -e "${RED}  ✗ 파일 서버 미작동${NC}"
    fi
    
    # nginx 프록시 확인
    if curl -s -f "http://localhost:8090/health" >/dev/null 2>&1; then
        echo -e "${GREEN}  ✓ nginx 프록시 작동 중${NC}"
        ((passed++))
    else
        echo -e "${RED}  ✗ nginx 프록시 미작동${NC}"
    fi
    
    # 메인 API 서버 확인
    if curl -s -f "http://localhost:8080/actuator/health" >/dev/null 2>&1; then
        echo -e "${GREEN}  ✓ 메인 API 서버 작동 중${NC}"
        ((passed++))
    else
        echo -e "${RED}  ✗ 메인 API 서버 미작동${NC}"
    fi
    
    echo -e "${BLUE}  환경 확인 결과: $passed/$total${NC}"
    return $((total - passed))
}

# 2. OpenRouter AI 분석 테스트
test_openrouter_analysis() {
    echo -e "${YELLOW}2. OpenRouter AI 분석 테스트${NC}"
    
    local test_image_url="https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/320px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg"
    
    echo -e "${BLUE}  → 테스트 이미지 분석 중...${NC}"
    
    local response=$(curl -s -w "%{http_code}" \
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
                            \"text\": \"이 이미지를 분석하여 JSON 형태로 결과를 제공해주세요: {\\\"scene_type\\\": \\\"실외/실내\\\", \\\"objects\\\": [\\\"감지된 객체들\\\"], \\\"analysis\\\": \\\"상세 분석\\\"}\"
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
            \"max_tokens\": 500,
            \"temperature\": 0.7
        }" \
        "https://openrouter.ai/api/v1/chat/completions" 2>/dev/null || echo "connection_failed")
    
    local http_code="${response: -3}"
    local body="${response%???}"
    
    if [[ "$http_code" == "200" ]]; then
        echo -e "${GREEN}  ✓ OpenRouter 비전 모델 분석 성공${NC}"
        local analysis_result=$(echo "$body" | jq -r '.choices[0].message.content' 2>/dev/null || echo "파싱 오류")
        echo -e "${CYAN}  분석 결과: $analysis_result${NC}"
        return 0
    else
        echo -e "${RED}  ✗ OpenRouter 분석 실패 (HTTP: $http_code)${NC}"
        echo -e "${RED}  응답: $body${NC}"
        return 1
    fi
}

# 3. 파일 업로드 및 분석 테스트
test_file_upload_analysis() {
    echo -e "${YELLOW}3. 파일 업로드 및 분석 테스트${NC}"
    
    # 테스트용 더미 이미지 생성 (1x1 PNG)
    local test_image_data="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg=="
    local test_file="/tmp/test_pothole.png"
    
    echo "$test_image_data" | base64 -d > "$test_file"
    
    echo -e "${BLUE}  → 테스트 이미지 업로드 중...${NC}"
    
    local upload_response=$(curl -s -w "%{http_code}" \
        -F "file=@$test_file" \
        -F "analyze=true" \
        -F "create_thumb=true" \
        "http://localhost:8000/upload/" 2>/dev/null || echo "connection_failed")
    
    local upload_http_code="${upload_response: -3}"
    local upload_body="${upload_response%???}"
    
    if [[ "$upload_http_code" == "200" ]]; then
        echo -e "${GREEN}  ✓ 파일 업로드 성공${NC}"
        
        # 응답에서 파일 URL 추출
        local file_url=$(echo "$upload_body" | jq -r '.file_url' 2>/dev/null)
        
        if [[ "$file_url" != "null" && -n "$file_url" ]]; then
            echo -e "${CYAN}  파일 URL: $file_url${NC}"
            
            # 이미지 접근 테스트
            if curl -s -f "$file_url" >/dev/null 2>&1; then
                echo -e "${GREEN}  ✓ 업로드된 이미지 접근 가능${NC}"
            else
                echo -e "${RED}  ✗ 업로드된 이미지 접근 불가${NC}"
            fi
        else
            echo -e "${RED}  ✗ 파일 URL 추출 실패${NC}"
        fi
        
        return 0
    else
        echo -e "${RED}  ✗ 파일 업로드 실패 (HTTP: $upload_http_code)${NC}"
        echo -e "${RED}  응답: $upload_body${NC}"
        return 1
    fi
    
    # 임시 파일 정리
    rm -f "$test_file"
}

# 4. 신고 생성 및 AI 분석 테스트
test_report_creation_analysis() {
    echo -e "${YELLOW}4. 신고 생성 및 AI 분석 테스트${NC}"
    
    echo -e "${BLUE}  → 포트홀 신고 생성 중...${NC}"
    
    local report_data='{
        "title": "도로 포트홀 신고",
        "description": "큰 도로에 위험한 포트홀이 발견되었습니다. 차량 손상 위험이 있어 긴급 수리가 필요합니다.",
        "location": "전주시 덕진구 백제대로 123",
        "category": "POTHOLE",
        "priority": "HIGH",
        "reporterName": "테스트 사용자",
        "reporterPhone": "010-1234-5678",
        "reporterEmail": "test@example.com"
    }'
    
    local report_response=$(curl -s -w "%{http_code}" \
        -H "Content-Type: application/json" \
        -d "$report_data" \
        "http://localhost:8080/api/reports" 2>/dev/null || echo "connection_failed")
    
    local report_http_code="${report_response: -3}"
    local report_body="${report_response%???}"
    
    if [[ "$report_http_code" == "200" || "$report_http_code" == "201" ]]; then
        echo -e "${GREEN}  ✓ 신고 생성 성공${NC}"
        
        local report_id=$(echo "$report_body" | jq -r '.id' 2>/dev/null)
        if [[ "$report_id" != "null" && -n "$report_id" ]]; then
            echo -e "${CYAN}  신고 ID: $report_id${NC}"
            
            # AI 분석 결과 확인
            sleep 2  # 분석 처리 시간 대기
            
            local analysis_response=$(curl -s \
                "http://localhost:8080/api/reports/$report_id/analysis" 2>/dev/null || echo "connection_failed")
            
            if [[ "$analysis_response" != "connection_failed" ]]; then
                local analysis_status=$(echo "$analysis_response" | jq -r '.status' 2>/dev/null)
                echo -e "${CYAN}  AI 분석 상태: $analysis_status${NC}"
                
                if [[ "$analysis_status" == "COMPLETED" ]]; then
                    echo -e "${GREEN}  ✓ AI 분석 완료${NC}"
                    local analysis_result=$(echo "$analysis_response" | jq -r '.result.summary' 2>/dev/null)
                    echo -e "${CYAN}  분석 결과: $analysis_result${NC}"
                else
                    echo -e "${YELLOW}  ⚠ AI 분석 진행 중 또는 대기 중${NC}"
                fi
            fi
        fi
        
        return 0
    else
        echo -e "${RED}  ✗ 신고 생성 실패 (HTTP: $report_http_code)${NC}"
        echo -e "${RED}  응답: $report_body${NC}"
        return 1
    fi
}

# 5. 성능 및 품질 검증
test_performance_quality() {
    echo -e "${YELLOW}5. 성능 및 품질 검증${NC}"
    
    echo -e "${BLUE}  → AI 분석 응답 시간 측정...${NC}"
    
    local start_time=$(date +%s%N)
    
    local perf_response=$(curl -s -w "%{time_total}" \
        -H "Authorization: Bearer $OPENROUTER_API_KEY" \
        -H "Content-Type: application/json" \
        -H "HTTP-Referer: https://jeonbuk-report-platform.com" \
        -H "X-Title: 전북 신고 플랫폼" \
        -d '{
            "model": "anthropic/claude-3.5-sonnet:beta",
            "messages": [{"role": "user", "content": "간단한 테스트입니다. JSON 형태로 응답해주세요: {\"status\": \"ok\", \"message\": \"정상 작동\"}"}],
            "max_tokens": 100
        }' \
        "https://openrouter.ai/api/v1/chat/completions" 2>/dev/null || echo "0")
    
    local response_time="${perf_response: -4}"
    
    if [[ "$response_time" =~ ^[0-9]+\.?[0-9]*$ ]]; then
        echo -e "${CYAN}  API 응답 시간: ${response_time}초${NC}"
        
        if (( $(echo "$response_time < 10" | bc -l) )); then
            echo -e "${GREEN}  ✓ 응답 시간 양호 (< 10초)${NC}"
        else
            echo -e "${YELLOW}  ⚠ 응답 시간 다소 느림 (>= 10초)${NC}"
        fi
    else
        echo -e "${RED}  ✗ 응답 시간 측정 실패${NC}"
    fi
    
    # 메모리 사용량 확인 (대략적)
    if command -v free >/dev/null 2>&1; then
        local memory_usage=$(free -m | awk 'NR==2{printf "%.1f%%", $3*100/$2 }')
        echo -e "${CYAN}  시스템 메모리 사용률: $memory_usage${NC}"
    fi
    
    return 0
}

# 메인 테스트 실행
main() {
    local total_tests=5
    local passed_tests=0
    
    echo -e "${PURPLE}테스트 시작 시간: $(date)${NC}"
    echo
    
    if test_environment; then ((passed_tests++)); fi
    echo
    if test_openrouter_analysis; then ((passed_tests++)); fi
    echo
    if test_file_upload_analysis; then ((passed_tests++)); fi
    echo
    if test_report_creation_analysis; then ((passed_tests++)); fi
    echo
    if test_performance_quality; then ((passed_tests++)); fi
    
    echo
    echo -e "${BLUE}===============================================================================${NC}"
    echo -e "${BLUE}                           종합 테스트 결과${NC}"
    echo -e "${BLUE}===============================================================================${NC}"
    echo -e "${PURPLE}테스트 완료 시간: $(date)${NC}"
    echo -e "${BLUE}테스트 결과: $passed_tests/$total_tests 통과${NC}"
    
    if [ $passed_tests -eq $total_tests ]; then
        echo -e "${GREEN}🎉 모든 테스트가 성공했습니다!${NC}"
        echo -e "${GREEN}AI 분석 파이프라인이 정상적으로 작동합니다.${NC}"
        echo
        echo -e "${CYAN}다음 단계:${NC}"
        echo -e "${CYAN}1. 실제 이미지로 추가 테스트${NC}"
        echo -e "${CYAN}2. 다양한 신고 유형으로 테스트${NC}"
        echo -e "${CYAN}3. 부하 테스트 수행${NC}"
        return 0
    else
        echo -e "${RED}⚠️ 일부 테스트가 실패했습니다.${NC}"
        echo -e "${YELLOW}실패한 항목을 확인하고 문제를 해결해주세요.${NC}"
        echo
        echo -e "${CYAN}문제 해결 가이드:${NC}"
        echo -e "${CYAN}1. 서비스 상태 확인: docker-compose ps${NC}"
        echo -e "${CYAN}2. 로그 확인: docker-compose logs [service-name]${NC}"
        echo -e "${CYAN}3. API 키 확인: .env 파일 점검${NC}"
        echo -e "${CYAN}4. 네트워크 연결 확인${NC}"
        return 1
    fi
}

# 스크립트 실행
main "$@"