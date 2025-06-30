#!/bin/bash

# 전북 신고 앱 시연용 계정 생성 스크립트
# 사용법: ./create_demo_users.sh

BASE_URL="http://localhost:8080"
REGISTER_URL="$BASE_URL/api/users/register"

echo "🚀 전북 신고 앱 시연용 계정 생성을 시작합니다..."
echo "서버 URL: $BASE_URL"
echo

# 서버 상태 확인
echo "🔍 서버 상태 확인 중..."
if curl -s --max-time 5 "$BASE_URL" > /dev/null; then
    echo "✅ 서버가 실행 중입니다."
else
    echo "❌ 서버에 연결할 수 없습니다. 서버가 실행되고 있는지 확인해주세요."
    echo "💡 서버 실행: cd flutter-backend && ./gradlew bootRun"
    exit 1
fi
echo

# 함수: 사용자 생성
create_user() {
    local username=$1
    local email=$2
    local password=$3
    local realName=$4
    local phone=$5
    local department=$6
    
    echo "👤 $realName ($username) 계정 생성 중..."
    
    response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST $REGISTER_URL \
        -H "Content-Type: application/json" \
        -d "{
            \"username\": \"$username\",
            \"email\": \"$email\",
            \"password\": \"$password\",
            \"realName\": \"$realName\",
            \"phoneNumber\": \"$phone\",
            \"department\": \"$department\"
        }")
    
    # HTTP 상태 코드 추출
    http_code=$(echo "$response" | grep "HTTP_CODE:" | cut -d: -f2)
    response_body=$(echo "$response" | sed '/HTTP_CODE:/d')
    
    if [[ "$http_code" == "200" || "$http_code" == "201" ]]; then
        echo "✅ $realName 계정 생성 성공 (HTTP $http_code)"
    else
        echo "❌ $realName 계정 생성 실패 (HTTP $http_code)"
        echo "   응답: $response_body"
    fi
    echo
}

# 시연용 계정들 생성
create_user "admin_demo" "admin@jeonbuk.go.kr" "Admin123!@#" "관리자" "010-9999-0000" "관리부"
create_user "reporter1" "reporter1@example.com" "Report123!" "김신고" "010-1111-2222" "민원처리과"
create_user "reporter2" "reporter2@example.com" "Report123!" "이민원" "010-3333-4444" "환경관리과"
create_user "citizen1" "citizen1@example.com" "Citizen123!" "박시민" "010-5555-6666" "일반시민"
create_user "demo_user" "demo@test.com" "Demo123!@#" "데모사용자" "010-7777-8888" "IT팀"

echo "🎉 시연용 계정 생성이 완료되었습니다!"
echo
echo "📋 생성된 계정 목록:"
echo "1. 관리자: admin_demo / Admin123!@#"
echo "2. 신고자1: reporter1 / Report123!"
echo "3. 신고자2: reporter2 / Report123!"
echo "4. 시민1: citizen1 / Citizen123!"
echo "5. 데모용: demo_user / Demo123!@#"
echo
echo "🔗 로그인 테스트: curl -X POST $BASE_URL/api/auth/login -H 'Content-Type: application/json' -d '{\"email\":\"demo@test.com\",\"password\":\"Demo123!@#\"}'"
