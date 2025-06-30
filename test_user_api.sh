#!/bin/bash

# 사용자 API 테스트 스크립트
BASE_URL="http://localhost:8080"

echo "🧪 사용자 API 테스트 시작"
echo "서버 URL: $BASE_URL"
echo

# 1. 서버 상태 확인
echo "1️⃣ 서버 상태 확인"
curl -s --max-time 5 "$BASE_URL" && echo "✅ 서버 응답 확인" || echo "❌ 서버 응답 없음"
echo

# 2. 회원가입 테스트
echo "2️⃣ 회원가입 API 테스트"
echo "URL: $BASE_URL/api/users/register"

curl -X POST "$BASE_URL/api/users/register" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "Test123!@#",
    "realName": "테스트사용자",
    "phoneNumber": "010-1234-5678",
    "department": "IT팀"
  }' \
  -w "\n응답 코드: %{http_code}\n" \
  -v

echo
echo "✅ 테스트 완료"
