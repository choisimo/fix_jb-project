#!/bin/bash

# Google Vision OCR + Gemini 2.5 Pro 통합 테스트 스크립트
# 사용법: ./test-google-vision-gemini-integration.sh

set -e

echo "🧪 Google Vision OCR + Gemini 2.5 Pro 통합 테스트 시작"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 프로젝트 루트 디렉토리
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 기본 설정
BASE_URL="http://localhost:8080"
AI_SERVER_URL="http://localhost:8081"
FILE_SERVER_URL="http://localhost:8087"

echo -e "${BLUE}📋 테스트 환경 설정:${NC}"
echo "   Main API Server: $BASE_URL"
echo "   AI Analysis Server: $AI_SERVER_URL"
echo "   File Server: $FILE_SERVER_URL"
echo ""

# 서버 상태 확인
check_server_health() {
    local url=$1
    local name=$2
    
    echo -n "🔍 $name 상태 확인... "
    
    if curl -s --max-time 5 "$url/actuator/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 정상${NC}"
        return 0
    else
        echo -e "${RED}❌ 비정상${NC}"
        return 1
    fi
}

# 1. 서버 상태 확인
echo -e "${YELLOW}1️⃣ 서버 상태 확인${NC}"
check_server_health "$BASE_URL" "Main API Server" || echo -e "${YELLOW}⚠️ Main Server가 실행되지 않았습니다${NC}"
check_server_health "$AI_SERVER_URL" "AI Analysis Server" || echo -e "${YELLOW}⚠️ AI Server가 실행되지 않았습니다${NC}"
check_server_health "$FILE_SERVER_URL" "File Server" || echo -e "${YELLOW}⚠️ File Server가 실행되지 않았습니다${NC}"
echo ""

# 2. 환경변수 확인
echo -e "${YELLOW}2️⃣ 환경변수 확인${NC}"
check_env_var() {
    local var_name=$1
    local var_value=${!var_name}
    
    if [ -n "$var_value" ]; then
        echo -e "✅ $var_name: ${GREEN}설정됨${NC}"
    else
        echo -e "❌ $var_name: ${RED}설정되지 않음${NC}"
    fi
}

check_env_var "OPENROUTER_API_KEY"
check_env_var "GOOGLE_VISION_API_KEY"
check_env_var "GOOGLE_APPLICATION_CREDENTIALS"
check_env_var "GOOGLE_CLOUD_PROJECT"
echo ""

# 3. 테스트 이미지 준비
echo -e "${YELLOW}3️⃣ 테스트 이미지 준비${NC}"
TEST_IMAGE_URL=""

# 샘플 이미지 URL 목록 (테스트용)
SAMPLE_IMAGES=(
    "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=800&h=600&fit=crop&crop=entropy&auto=format&fm=jpg&q=60"
    "https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800&h=600&fit=crop&crop=entropy&auto=format&fm=jpg&q=60"
    "https://images.unsplash.com/photo-1520637836862-4d197d17c886?w=800&h=600&fit=crop&crop=entropy&auto=format&fm=jpg&q=60"
)

# 첫 번째 사용 가능한 이미지 선택
for img_url in "${SAMPLE_IMAGES[@]}"; do
    if curl -s --head --max-time 5 "$img_url" > /dev/null 2>&1; then
        TEST_IMAGE_URL="$img_url"
        echo -e "✅ 테스트 이미지 URL: ${GREEN}$TEST_IMAGE_URL${NC}"
        break
    fi
done

if [ -z "$TEST_IMAGE_URL" ]; then
    echo -e "${RED}❌ 사용 가능한 테스트 이미지를 찾을 수 없습니다${NC}"
    echo "직접 이미지 URL을 입력하세요:"
    read -p "이미지 URL: " TEST_IMAGE_URL
fi
echo ""

# 4. Google Vision OCR 테스트
echo -e "${YELLOW}4️⃣ Google Vision OCR 테스트${NC}"
echo "🔍 Google Vision API로 OCR 텍스트 추출 테스트 중..."

OCR_RESULT=$(curl -s -X POST "$AI_SERVER_URL/api/v1/enhanced-ai/extract-text" \
    -H "Content-Type: application/json" \
    -d "{\"imageUrl\": \"$TEST_IMAGE_URL\"}" \
    --max-time 30 || echo "OCR_ERROR")

if [[ "$OCR_RESULT" == *"OCR_ERROR"* ]] || [[ "$OCR_RESULT" == *"error"* ]]; then
    echo -e "${RED}❌ Google Vision OCR 테스트 실패${NC}"
    echo "응답: $OCR_RESULT"
else
    echo -e "${GREEN}✅ Google Vision OCR 테스트 성공${NC}"
    echo "추출된 텍스트 길이: $(echo "$OCR_RESULT" | wc -c) 문자"
fi
echo ""

# 5. Gemini 2.5 Pro 비전 분석 테스트
echo -e "${YELLOW}5️⃣ Gemini 2.5 Pro 비전 분석 테스트${NC}"
echo "🤖 Gemini 2.5 Pro로 이미지 분석 테스트 중..."

VISION_ANALYSIS=$(curl -s -X POST "$AI_SERVER_URL/api/v1/enhanced-ai/analyze-image" \
    -H "Content-Type: application/json" \
    -d "{
        \"imageUrl\": \"$TEST_IMAGE_URL\",
        \"prompt\": \"이 이미지를 분석하여 다음 정보를 JSON 형태로 제공해주세요: 주요 객체, 장면 유형, 잠재적 문제점, 권장 조치사항\"
    }" \
    --max-time 45 || echo "VISION_ERROR")

if [[ "$VISION_ANALYSIS" == *"VISION_ERROR"* ]] || [[ "$VISION_ANALYSIS" == *"error"* ]]; then
    echo -e "${RED}❌ Gemini 2.5 Pro 비전 분석 테스트 실패${NC}"
    echo "응답: $VISION_ANALYSIS"
else
    echo -e "${GREEN}✅ Gemini 2.5 Pro 비전 분석 테스트 성공${NC}"
    echo "분석 결과 길이: $(echo "$VISION_ANALYSIS" | wc -c) 문자"
fi
echo ""

# 6. 통합 분석 테스트 (OCR + Gemini)
echo -e "${YELLOW}6️⃣ 통합 분석 테스트 (OCR + Gemini 2.5 Pro)${NC}"
echo "🔍🤖 Google Vision OCR + Gemini 2.5 Pro 통합 분석 테스트 중..."

INTEGRATED_ANALYSIS=$(curl -s -X POST "$AI_SERVER_URL/api/v1/enhanced-ai/analyze-with-ocr" \
    -H "Content-Type: application/json" \
    -d "{
        \"imageUrl\": \"$TEST_IMAGE_URL\",
        \"analysisPrompt\": \"이 이미지의 도로 상황을 분석하여 다음 정보를 제공해주세요: 도로 상태, 교통 표지판 유무, 잠재적 위험 요소, 개선 사항\"
    }" \
    --max-time 60 || echo "INTEGRATED_ERROR")

if [[ "$INTEGRATED_ANALYSIS" == *"INTEGRATED_ERROR"* ]] || [[ "$INTEGRATED_ANALYSIS" == *"error"* ]]; then
    echo -e "${RED}❌ 통합 분석 테스트 실패${NC}"
    echo "응답: $INTEGRATED_ANALYSIS"
else
    echo -e "${GREEN}✅ 통합 분석 테스트 성공${NC}"
    echo "통합 분석 결과 길이: $(echo "$INTEGRATED_ANALYSIS" | wc -c) 문자"
fi
echo ""

# 7. 성능 테스트
echo -e "${YELLOW}7️⃣ 성능 테스트${NC}"
echo "⚡ 분석 속도 및 처리 성능 테스트 중..."

START_TIME=$(date +%s%N)

PERF_TEST=$(curl -s -X POST "$AI_SERVER_URL/api/v1/enhanced-ai/analyze-text" \
    -H "Content-Type: application/json" \
    -d "{
        \"text\": \"전주시 덕진구에서 포트홀이 발견되었습니다. 도로 상태가 심각하여 긴급 수리가 필요합니다.\",
        \"analysisType\": \"risk_assessment\"
    }" \
    --max-time 30 || echo "PERF_ERROR")

END_TIME=$(date +%s%N)
DURATION=$((($END_TIME - $START_TIME) / 1000000)) # milliseconds

if [[ "$PERF_TEST" == *"PERF_ERROR"* ]]; then
    echo -e "${RED}❌ 성능 테스트 실패${NC}"
else
    echo -e "${GREEN}✅ 성능 테스트 성공${NC}"
    echo "처리 시간: ${DURATION}ms"
    
    if [ "$DURATION" -lt 5000 ]; then
        echo -e "${GREEN}🚀 우수한 성능 (5초 미만)${NC}"
    elif [ "$DURATION" -lt 10000 ]; then
        echo -e "${YELLOW}⚡ 양호한 성능 (5-10초)${NC}"
    else
        echo -e "${RED}🐌 성능 개선 필요 (10초 초과)${NC}"
    fi
fi
echo ""

# 8. 결과 요약
echo -e "${BLUE}📊 테스트 결과 요약${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 성공/실패 카운트
SUCCESS_COUNT=0
TOTAL_TESTS=5

[[ "$OCR_RESULT" != *"OCR_ERROR"* ]] && [[ "$OCR_RESULT" != *"error"* ]] && ((SUCCESS_COUNT++))
[[ "$VISION_ANALYSIS" != *"VISION_ERROR"* ]] && [[ "$VISION_ANALYSIS" != *"error"* ]] && ((SUCCESS_COUNT++))
[[ "$INTEGRATED_ANALYSIS" != *"INTEGRATED_ERROR"* ]] && [[ "$INTEGRATED_ANALYSIS" != *"error"* ]] && ((SUCCESS_COUNT++))
[[ "$PERF_TEST" != *"PERF_ERROR"* ]] && ((SUCCESS_COUNT++))

echo "성공한 테스트: $SUCCESS_COUNT / $TOTAL_TESTS"

if [ "$SUCCESS_COUNT" -eq "$TOTAL_TESTS" ]; then
    echo -e "${GREEN}🎉 모든 테스트가 성공적으로 완료되었습니다!${NC}"
    echo ""
    echo -e "${BLUE}🚀 시스템 준비 완료:${NC}"
    echo "   ✅ Google Vision OCR 정상 작동"
    echo "   ✅ Gemini 2.5 Pro 모델 정상 작동"
    echo "   ✅ 통합 분석 파이프라인 정상 작동"
    echo "   ✅ 성능 최적화 완료"
elif [ "$SUCCESS_COUNT" -gt 3 ]; then
    echo -e "${YELLOW}⚠️ 대부분의 테스트가 성공했습니다 ($SUCCESS_COUNT/$TOTAL_TESTS)${NC}"
    echo -e "${BLUE}💡 실패한 테스트가 있지만 기본 기능은 사용 가능합니다${NC}"
else
    echo -e "${RED}❌ 여러 테스트가 실패했습니다 ($SUCCESS_COUNT/$TOTAL_TESTS)${NC}"
    echo -e "${BLUE}🔧 문제 해결이 필요합니다${NC}"
fi

echo ""
echo -e "${BLUE}📋 다음 단계:${NC}"
echo "1. API 키 설정 확인: ./shellscript/setup-api-keys.sh"
echo "2. Google OCR 설정: ./shellscript/setup-google-ocr-keys.sh"
echo "3. 서버 재시작 후 재테스트"
echo "4. 로그 확인: docker-compose logs -f"
echo ""
echo -e "${GREEN}✨ Google Vision OCR + Gemini 2.5 Pro 통합 테스트 완료!${NC}"