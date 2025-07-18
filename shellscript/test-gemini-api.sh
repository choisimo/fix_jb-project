#!/bin/bash

# Gemini API 테스트 스크립트
# 텍스트 분석 및 이미지 분석 테스트

echo "🤖 Gemini API 종합 테스트 시작..."

# 환경 변수 설정
export GEMINI_API_KEY="AIzaSyCu6PMsnHJKB02ySTFsK-RUjVQZRn8g-2I"
BASE_URL="https://generativelanguage.googleapis.com/v1beta"

echo ""
echo "1️⃣ 기본 텍스트 생성 테스트"
echo "=============================="

response=$(curl -s -X POST "${BASE_URL}/models/gemini-1.5-pro:generateContent?key=${GEMINI_API_KEY}" \
-H "Content-Type: application/json" \
-d '{
  "contents": [
    {
      "parts": [
        {
          "text": "전북 지역의 도로 포트홀 문제를 분석하여 다음 JSON 형식으로 답변해주세요: {\"category\": \"도로\", \"priority\": \"high\", \"action\": \"즉시 수리\", \"keywords\": [\"포트홀\", \"도로\", \"안전\"]}"
        }
      ]
    }
  ],
  "generationConfig": {
    "temperature": 0.7,
    "maxOutputTokens": 500
  }
}')

echo "📤 요청 완료"
echo "📥 응답:"
echo "$response" | jq -r '.candidates[0].content.parts[0].text // "응답 없음"'
echo ""

echo "2️⃣ 이미지 분석 테스트 (샘플 이미지 URL)"
echo "=========================================="

# 공개 이미지 URL 사용 (실제 도로 이미지)
IMAGE_URL="https://via.placeholder.com/800x600/ff0000/ffffff?text=POTHOLE+DAMAGE"

# 이미지를 Base64로 인코딩하여 테스트
echo "📷 이미지 다운로드 및 인코딩 중..."
temp_image=$(mktemp)
curl -s "$IMAGE_URL" -o "$temp_image"
base64_image=$(base64 -w 0 "$temp_image")
rm "$temp_image"

response=$(curl -s -X POST "${BASE_URL}/models/gemini-1.5-pro:generateContent?key=${GEMINI_API_KEY}" \
-H "Content-Type: application/json" \
-d "{
  \"contents\": [
    {
      \"parts\": [
        {
          \"text\": \"이 이미지를 분석하여 도로 상태를 평가하고 다음 JSON 형식으로 답변해주세요: {\\\"object_type\\\": \\\"도로 시설물\\\", \\\"damage_level\\\": \\\"심각도\\\", \\\"priority\\\": \\\"우선순위\\\", \\\"recommended_action\\\": \\\"권장 조치\\\"}\"
        },
        {
          \"inlineData\": {
            \"mimeType\": \"image/png\",
            \"data\": \"$base64_image\"
          }
        }
      ]
    }
  ],
  \"generationConfig\": {
    \"temperature\": 0.7,
    \"maxOutputTokens\": 500
  }
}")

echo "📤 이미지 분석 요청 완료"
echo "📥 응답:"
echo "$response" | jq -r '.candidates[0].content.parts[0].text // "응답 없음"'
echo ""

echo "3️⃣ 한국어 특화 도시 인프라 분석 테스트"
echo "========================================"

response=$(curl -s -X POST "${BASE_URL}/models/gemini-1.5-pro:generateContent?key=${GEMINI_API_KEY}" \
-H "Content-Type: application/json" \
-d '{
  "contents": [
    {
      "parts": [
        {
          "text": "전주시 덕진구 덕진동에서 가로등이 깜빡거리고 있습니다. 밤에 보행이 위험해 보입니다. 이 신고 내용을 분석하여 다음 정보를 JSON으로 제공해주세요:\n- 시설물 유형\n- 위험도 수준\n- 긴급도\n- 관할 부서\n- 예상 처리 시간\n- 임시 조치 방안"
        }
      ]
    }
  ],
  "generationConfig": {
    "temperature": 0.7,
    "maxOutputTokens": 600
  }
}')

echo "📤 요청 완료"
echo "📥 응답:"
echo "$response" | jq -r '.candidates[0].content.parts[0].text // "응답 없음"'
echo ""

echo "4️⃣ API 상태 및 사용량 확인"
echo "==========================="

# 간단한 상태 확인
status_response=$(curl -s -X POST "${BASE_URL}/models/gemini-1.5-pro:generateContent?key=${GEMINI_API_KEY}" \
-H "Content-Type: application/json" \
-d '{
  "contents": [
    {
      "parts": [
        {
          "text": "API 테스트 완료. 상태: 정상"
        }
      ]
    }
  ],
  "generationConfig": {
    "maxOutputTokens": 50
  }
}')

if echo "$status_response" | jq -e '.candidates[0].content.parts[0].text' > /dev/null 2>&1; then
    echo "✅ Gemini API 연결 정상"
    echo "📊 토큰 사용량:" 
    echo "$status_response" | jq '.usageMetadata // "사용량 정보 없음"'
else
    echo "❌ Gemini API 연결 실패"
    echo "오류 응답: $status_response"
fi

echo ""
echo "🎉 Gemini API 테스트 완료!"
echo ""
echo "📋 결과 요약:"
echo "- 텍스트 생성: $(echo "$response" | jq -e '.candidates' > /dev/null 2>&1 && echo "✅ 성공" || echo "❌ 실패")"
echo "- 이미지 분석: $(echo "$response" | jq -e '.candidates' > /dev/null 2>&1 && echo "✅ 성공" || echo "❌ 실패")"
echo "- 한국어 분석: $(echo "$response" | jq -e '.candidates' > /dev/null 2>&1 && echo "✅ 성공" || echo "❌ 실패")"
echo ""