#!/bin/bash

echo "🧪 AI 통합 테스트 시작..."

# 1. 서비스 상태 확인
echo "📋 서비스 상태 확인..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "🔍 헬스체크 수행 중..."

# 2. AI Analysis 서버 헬스체크
echo "🤖 AI Analysis 서버 확인..."
AI_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8083/api/v1/ai/health 2>/dev/null)
if [ "$AI_HEALTH" = "200" ]; then
    echo "✅ AI Analysis 서버: 정상"
else
    echo "❌ AI Analysis 서버: 응답 없음 (HTTP: $AI_HEALTH)"
fi

# 3. Main API 서버 헬스체크
echo "🔧 Main API 서버 확인..."
MAIN_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/actuator/health 2>/dev/null)
if [ "$MAIN_HEALTH" = "200" ]; then
    echo "✅ Main API 서버: 정상"
else
    echo "❌ Main API 서버: 응답 없음 (HTTP: $MAIN_HEALTH)"
fi

# 4. AI Analysis 기능 테스트
echo ""
echo "🔍 AI 분석 기능 테스트..."

# capabilities endpoint 테스트
echo "📊 AI 기능 목록 확인..."
AI_CAPS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8083/api/v1/ai/capabilities 2>/dev/null)
if [ "$AI_CAPS" = "200" ]; then
    echo "✅ AI 기능 목록: 정상"
    curl -s http://localhost:8083/api/v1/ai/capabilities | jq '.capabilities[]' 2>/dev/null || echo "응답 받음"
else
    echo "❌ AI 기능 목록: 응답 없음 (HTTP: $AI_CAPS)"
fi

# 5. 테스트 이미지로 분석 테스트
echo ""
echo "🖼️  테스트 이미지 분석..."
if [ -f "test_images/pothole_1.jpg" ]; then
    echo "테스트 이미지로 AI 분석 수행 중..."
    
    ANALYSIS_RESULT=$(curl -s -o /dev/null -w "%{http_code}" \
        -X POST \
        -F "image=@test_images/pothole_1.jpg" \
        http://localhost:8083/api/v1/ai/analyze/comprehensive 2>/dev/null)
    
    if [ "$ANALYSIS_RESULT" = "200" ]; then
        echo "✅ AI 분석: 성공"
    else
        echo "❌ AI 분석: 실패 (HTTP: $ANALYSIS_RESULT)"
    fi
else
    echo "⚠️  테스트 이미지 없음 - 실제 이미지로 테스트 필요"
fi

# 6. 환경변수 확인
echo ""
echo "🔑 환경변수 설정 확인..."
if [ -f ".env" ]; then
    echo "✅ .env 파일 존재"
    
    # 중요 환경변수들 확인
    ENV_VARS=("ROBOFLOW_API_KEY" "OPENROUTER_API_KEY" "GOOGLE_CLOUD_PROJECT_ID")
    for var in "${ENV_VARS[@]}"; do
        if grep -q "$var=" .env && ! grep -q "${var}=your_" .env; then
            echo "✅ $var: 설정됨"
        else
            echo "❌ $var: 설정 필요"
        fi
    done
else
    echo "❌ .env 파일 없음"
    echo "   .env.example을 복사하여 .env 파일을 생성하고 API 키를 설정하세요"
fi

# 7. 로그에서 Mock 데이터 사용 여부 확인
echo ""
echo "🎭 Mock 데이터 사용 확인..."
if [ $(docker ps -q -f name=ai-analysis-server) ]; then
    MOCK_COUNT=$(docker logs ai-analysis-server --tail 50 2>/dev/null | grep -c "모의\|mock\|Mock" || echo "0")
else
    MOCK_COUNT=0
fi
if [ "$MOCK_COUNT" -gt "0" ]; then
    echo "⚠️  Mock 데이터 사용 중 ($MOCK_COUNT개 발견)"
    echo "   실제 API 키 설정 후 서비스를 재시작하세요"
else
    echo "✅ 실제 AI 분석 사용 중"
fi

echo ""
echo "📝 종합 결과:"
echo "================================"
if [ "$AI_HEALTH" = "200" ] && [ "$MAIN_HEALTH" = "200" ]; then
    echo "✅ 모든 서비스가 정상 작동 중"
else
    echo "❌ 일부 서비스에 문제가 있습니다"
fi

if [ "$MOCK_COUNT" -gt "0" ]; then
    echo "⚠️  API 키 설정 후 재시작 필요"
fi

echo ""
echo "🔧 다음 단계:"
echo "1. .env 파일에서 API 키들을 실제 값으로 설정"
echo "2. docker-compose -f docker-compose.prod.yml restart"
echo "3. 이 스크립트를 다시 실행하여 확인"