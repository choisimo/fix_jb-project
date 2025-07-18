#!/bin/bash
# 모든 주요 엔드포인트 정상/비정상 요청 curl 테스트 스크립트
# 실제 서비스 환경에 맞게 BASE_URL을 수정하세요.

BASE_URL_MAIN="http://localhost:8080"
BASE_URL_AI="http://localhost:8083"

function test_endpoint() {
  local method=$1
  local url=$2
  local data=$3
  local desc=$4
  local extra_args=$5
  echo "\n==== $desc ($method $url) ===="
  if [ "$method" = "GET" ]; then
    curl -s -w "\n[HTTP %{http_code}]\n" -X GET "$url" $extra_args
  elif [ "$method" = "POST" ]; then
    curl -s -w "\n[HTTP %{http_code}]\n" -X POST "$url" -H "Content-Type: application/json" -d "$data" $extra_args
  elif [ "$method" = "PUT" ]; then
    curl -s -w "\n[HTTP %{http_code}]\n" -X PUT "$url" -H "Content-Type: application/json" -d "$data" $extra_args
  elif [ "$method" = "DELETE" ]; then
    curl -s -w "\n[HTTP %{http_code}]\n" -X DELETE "$url" $extra_args
  fi
}

# main-api-server 엔드포인트 테스트 예시
# 정상 요청

test_endpoint "GET" "$BASE_URL_MAIN/api/v1/statistics/overview" "" "[정상] 통계 오버뷰 조회"
test_endpoint "GET" "$BASE_URL_MAIN/api/v1/statistics/category/test" "" "[정상] 카테고리 통계 조회"
test_endpoint "GET" "$BASE_URL_MAIN/api/v1/statistics/range?startDate=2024-01-01&endDate=2024-12-31" "" "[정상] 기간별 통계 조회"
test_endpoint "GET" "$BASE_URL_MAIN/api/v1/statistics/dashboard" "" "[정상] 대시보드 통계 조회"

test_endpoint "GET" "$BASE_URL_MAIN/api/verification/sms/status?phoneNumber=01012345678" "" "[정상] SMS 인증 상태 조회"
test_endpoint "GET" "$BASE_URL_MAIN/api/verification/email/status?email=test@example.com" "" "[정상] 이메일 인증 상태 조회"

test_endpoint "GET" "$BASE_URL_MAIN/api/v1/files/download/testfile.txt" "" "[정상] 파일 다운로드 (존재하지 않을 수도 있음)"

test_endpoint "GET" "$BASE_URL_MAIN/api/v1/files/thumbnail/testfile.jpg" "" "[정상] 썸네일 조회 (존재하지 않을 수도 있음)"

test_endpoint "GET" "$BASE_URL_MAIN/api/notifications/websocket/status" "" "[정상] 웹소켓 상태 조회"

test_endpoint "GET" "$BASE_URL_MAIN/api/v1/alerts/health" "" "[정상] 알림 서비스 헬스체크"

test_endpoint "GET" "$BASE_URL_MAIN/api/v1/alerts/stats" "" "[정상] 알림 통계 조회"

test_endpoint "GET" "$BASE_URL_MAIN/api/users?size=1" "" "[정상] 사용자 목록 조회 (권한 필요할 수 있음)"

test_endpoint "GET" "$BASE_URL_MAIN/api/reports" "" "[정상] 리포트 목록 조회 (권한 필요할 수 있음)"

# ai-analysis-server 엔드포인트 테스트 예시

test_endpoint "GET" "$BASE_URL_AI/api/v1/ai/health" "" "[정상] AI 라우팅 헬스체크"
test_endpoint "GET" "$BASE_URL_AI/api/v1/ai/routing/stats" "" "[정상] AI 라우팅 통계 조회"
test_endpoint "GET" "$BASE_URL_AI/api/v1/ai/classes" "" "[정상] 지원 클래스 목록 조회"
test_endpoint "GET" "$BASE_URL_AI/api/v1/ai/metrics" "" "[정상] AI 성능 메트릭 조회"

test_endpoint "GET" "$BASE_URL_AI/api/v1/alerts/health" "" "[정상] AI 알림 헬스체크"
test_endpoint "GET" "$BASE_URL_AI/api/v1/alerts/stats" "" "[정상] AI 알림 통계 조회"

test_endpoint "GET" "$BASE_URL_AI/api/v1/users?size=1" "" "[정상] AI 사용자 목록 조회 (권한 필요할 수 있음)"

# 비정상 요청 (경계/에러)
test_endpoint "GET" "$BASE_URL_MAIN/api/v1/statistics/category/" "" "[비정상] 카테고리명 누락"
test_endpoint "GET" "$BASE_URL_MAIN/api/v1/files/download/" "" "[비정상] 파일명 누락"
test_endpoint "POST" "$BASE_URL_MAIN/api/v1/alerts/analyze" "{}" "[비정상] 알림 분석 요청 (필수값 누락)"
test_endpoint "POST" "$BASE_URL_AI/api/v1/ai/routing/analyze" "{}" "[비정상] AI 라우팅 분석 요청 (필수값 누락)"

echo "\n==== 반복/부하 테스트 예시 (10회 반복) ===="
for i in {1..10}; do
  test_endpoint "GET" "$BASE_URL_MAIN/api/v1/statistics/overview" "" "[반복] 통계 오버뷰 조회 $i회차"
done

echo "\n==== 테스트 완료 ===="
