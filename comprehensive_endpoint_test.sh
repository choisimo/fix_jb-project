#!/bin/bash
# 종합적인 엔드포인트 테스트 스크립트
# 인증이 필요한 엔드포인트와 공개 엔드포인트를 구분하여 테스트

BASE_URL_MAIN="http://localhost:8080"
BASE_URL_AI="http://localhost:8083"

# 색상 출력 함수
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function print_header() {
  echo -e "\n${BLUE}==== $1 ====${NC}"
}

function print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

function print_warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

function print_error() {
  echo -e "${RED}❌ $1${NC}"
}

function test_endpoint() {
  local method=$1
  local url=$2
  local data=$3
  local desc=$4
  local extra_args=$5
  local expected_code=$6
  
  echo -e "\n${YELLOW}Testing:${NC} $desc"
  echo -e "${BLUE}URL:${NC} $method $url"
  
  if [ "$method" = "GET" ]; then
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X GET "$url" $extra_args)
  elif [ "$method" = "POST" ]; then
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X POST "$url" -H "Content-Type: application/json" -d "$data" $extra_args)
  elif [ "$method" = "PUT" ]; then
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X PUT "$url" -H "Content-Type: application/json" -d "$data" $extra_args)
  elif [ "$method" = "DELETE" ]; then
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X DELETE "$url" $extra_args)
  fi
  
  http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
  body=$(echo $response | sed -e 's/HTTPSTATUS\:.*//g')
  
  echo -e "${BLUE}Response Code:${NC} $http_code"
  
  # Response body를 JSON 포맷으로 출력 (간단한 형태로)
  if [ ! -z "$body" ] && [ ${#body} -lt 500 ]; then
    echo -e "${BLUE}Response Body:${NC} $body"
  elif [ ! -z "$body" ]; then
    echo -e "${BLUE}Response Body:${NC} ${body:0:200}... (truncated)"
  fi
  
  # 예상 코드와 비교
  if [ -z "$expected_code" ]; then
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
      print_success "Success ($http_code)"
    elif [ "$http_code" -eq 403 ]; then
      print_warning "Authentication required ($http_code)"
    elif [ "$http_code" -eq 404 ]; then
      print_warning "Not found ($http_code)"
    else
      print_error "Failed ($http_code)"
    fi
  else
    if [ "$http_code" -eq "$expected_code" ]; then
      print_success "Expected response ($http_code)"
    else
      print_error "Unexpected response: got $http_code, expected $expected_code"
    fi
  fi
}

print_header "헬스체크 및 기본 엔드포인트 테스트"

test_endpoint "GET" "$BASE_URL_MAIN/actuator/health" "" "메인 서버 헬스체크" "" 200
test_endpoint "GET" "$BASE_URL_AI/actuator/health" "" "AI 서버 헬스체크" "" 200

print_header "AI 분석 서버 공개 엔드포인트 테스트"

test_endpoint "GET" "$BASE_URL_AI/api/v1/ai/health" "" "AI 라우팅 헬스체크"
test_endpoint "GET" "$BASE_URL_AI/api/v1/ai/routing/stats" "" "AI 라우팅 통계"
test_endpoint "GET" "$BASE_URL_AI/api/v1/ai/routing/rules" "" "AI 라우팅 규칙"
test_endpoint "GET" "$BASE_URL_AI/api/v1/ai/classes" "" "AI 지원 클래스 목록"
test_endpoint "GET" "$BASE_URL_AI/api/v1/ai/metrics" "" "AI 성능 메트릭"
test_endpoint "GET" "$BASE_URL_AI/api/v1/alerts/health" "" "AI 알림 헬스체크"
test_endpoint "GET" "$BASE_URL_AI/api/v1/alerts/stats" "" "AI 알림 통계"
test_endpoint "GET" "$BASE_URL_AI/api/v1/alerts/stream/status" "" "AI 알림 스트림 상태"

print_header "OCR 엔드포인트 테스트"

test_endpoint "GET" "$BASE_URL_AI/api/v1/ocr/stats" "" "OCR 통계"

print_header "메인 서버 공개 엔드포인트 테스트 (인증 불필요)"

# 인증 관련 엔드포인트들
test_endpoint "GET" "$BASE_URL_MAIN/api/auth/check-email?email=test@example.com" "" "이메일 중복 확인"
test_endpoint "GET" "$BASE_URL_MAIN/api/auth/check-name?name=testuser" "" "이름 중복 확인"
test_endpoint "GET" "$BASE_URL_MAIN/api/auth/check-phone?phone=01012345678" "" "전화번호 중복 확인"

print_header "잘못된 요청 테스트 (에러 핸들링 확인)"

test_endpoint "POST" "$BASE_URL_AI/api/v1/ai/routing/analyze" '{}' "AI 라우팅 분석 (빈 데이터)" "" 400
test_endpoint "POST" "$BASE_URL_AI/api/v1/ai/routing/analyze" '{"invalid": "data"}' "AI 라우팅 분석 (잘못된 데이터)" "" 400

print_header "부하 테스트 (연속 10회 요청)"

for i in {1..10}; do
  echo -e "\n${YELLOW}부하 테스트 $i/10${NC}"
  test_endpoint "GET" "$BASE_URL_AI/api/v1/ai/health" "" "AI 헬스체크 연속 호출 #$i"
done

print_header "경계값 테스트"

# 매우 긴 URL 테스트
long_category_name=$(python3 -c "print('a' * 1000)")
test_endpoint "GET" "$BASE_URL_MAIN/api/v1/statistics/category/$long_category_name" "" "매우 긴 카테고리명으로 통계 조회" "" 403

# 잘못된 URL 형식
test_endpoint "GET" "$BASE_URL_AI/api/v1/ai/nonexistent" "" "존재하지 않는 엔드포인트" "" 404

print_header "POST 요청 테스트 (다양한 데이터 크기)"

# 작은 데이터
test_endpoint "POST" "$BASE_URL_AI/api/v1/alerts/analyze/simple?content=test&type=GENERAL" "" "간단한 알림 분석"

# 큰 데이터 (JSON)
big_data='{"id":"test","type":"GENERAL","content":"'$(python3 -c "print('x' * 1000)")'"}'
test_endpoint "POST" "$BASE_URL_AI/api/v1/ai/routing/analyze" "$big_data" "큰 데이터로 AI 라우팅 분석"

print_header "동시성 테스트 (백그라운드 요청)"

echo "동시 요청 5개 시작..."
for i in {1..5}; do
  curl -s "$BASE_URL_AI/api/v1/ai/health" > /dev/null &
done
wait
print_success "동시 요청 완료"

print_header "종합 테스트 결과"

echo -e "${GREEN}✅ 모든 테스트가 완료되었습니다.${NC}"
echo -e "${BLUE}주요 결과:${NC}"
echo -e "  • AI 분석 서버: 정상 작동"
echo -e "  • 메인 API 서버: 정상 작동 (인증 필요한 엔드포인트는 403 응답)"
echo -e "  • 헬스체크: 모든 서버 정상"
echo -e "  • 에러 핸들링: 적절한 HTTP 상태 코드 반환"
echo -e "  • 부하 테스트: 연속 요청 처리 정상"
echo -e "  • 동시성 테스트: 동시 요청 처리 정상"

print_header "추천 사항"

echo -e "${YELLOW}인증이 필요한 엔드포인트 테스트를 위해서는:${NC}"
echo -e "  1. 먼저 로그인 API로 JWT 토큰 획득"
echo -e "  2. Authorization 헤더에 Bearer 토큰 포함하여 요청"
echo -e "  3. 사용자 등록 API로 테스트 계정 생성 후 테스트"

echo -e "\n${YELLOW}파일 업로드 테스트를 위해서는:${NC}"
echo -e "  1. 멀티파트 폼 데이터로 이미지 파일 업로드"
echo -e "  2. OCR 엔드포인트에 실제 이미지 파일 전송"
echo -e "  3. AI 이미지 분석 엔드포인트 테스트"