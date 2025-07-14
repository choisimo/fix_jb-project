#!/bin/bash

# AI Integration Fix Script
echo "🔧 AI Integration 문제 해결 시작..."

# 1. Environment Variables 설정
echo "📝 환경 변수 설정..."

# .env 파일이 없으면 생성
if [ ! -f .env ]; then
    touch .env
fi

# AI Analysis 서버를 위한 환경 변수 추가/업데이트
echo "# AI Analysis Configuration" >> .env
echo "ROBOFLOW_API_KEY=your_roboflow_api_key_here" >> .env
echo "ROBOFLOW_WORKSPACE_URL=your_workspace_url_here" >> .env
echo "GOOGLE_CLOUD_PROJECT_ID=your_project_id" >> .env
echo "GOOGLE_CLOUD_VISION_ENABLED=true" >> .env
echo "GOOGLE_APPLICATION_CREDENTIALS=/app/google-credentials.json" >> .env
echo "AI_AGENT_ENABLED=true" >> .env
echo "AI_AGENT_API_URL=https://openrouter.ai/api/v1" >> .env
echo "AI_AGENT_API_KEY=your_openrouter_api_key_here" >> .env
echo "OPENROUTER_API_KEY=your_openrouter_api_key_here" >> .env
echo "OPENROUTER_MODEL=qwen/qwen2.5-vl-72b-instruct:free" >> .env

# 2. Docker Compose 업데이트
echo "🐳 Docker Compose 환경 변수 추가..."

# ai-analysis 서비스에 환경 변수 추가
sed -i '/ai-analysis:/,/^  [a-zA-Z]/ s/environment:/environment:\n      ROBOFLOW_API_KEY: ${ROBOFLOW_API_KEY}\n      ROBOFLOW_WORKSPACE_URL: ${ROBOFLOW_WORKSPACE_URL}\n      GOOGLE_CLOUD_PROJECT_ID: ${GOOGLE_CLOUD_PROJECT_ID}\n      GOOGLE_CLOUD_VISION_ENABLED: ${GOOGLE_CLOUD_VISION_ENABLED:-true}\n      GOOGLE_APPLICATION_CREDENTIALS: ${GOOGLE_APPLICATION_CREDENTIALS}\n      AI_AGENT_ENABLED: ${AI_AGENT_ENABLED:-true}\n      AI_AGENT_API_URL: ${AI_AGENT_API_URL}\n      AI_AGENT_API_KEY: ${AI_AGENT_API_KEY}\n      OPENROUTER_API_KEY: ${OPENROUTER_API_KEY}\n      OPENROUTER_MODEL: ${OPENROUTER_MODEL}/' docker-compose.prod.yml

# 3. Flutter 앱 API 엔드포인트 수정
echo "📱 Flutter 앱 API 엔드포인트 수정..."

# 올바른 엔드포인트로 수정
sed -i 's|/api/v1/ai/analyze|/api/v1/ai/analyze/comprehensive|g' flutter-app/lib/features/image_analysis/domain/services/image_analysis_service.dart

# 4. AI Analysis 서버 재시작
echo "🔄 AI Analysis 서버 재시작..."
docker-compose -f docker-compose.prod.yml restart ai-analysis

# 5. Main API 서버 상태 확인 및 재시작
echo "🔍 Main API 서버 상태 확인..."
docker-compose -f docker-compose.prod.yml restart main-api

# 6. 서비스 상태 확인
echo "✅ 서비스 상태 확인 중..."
sleep 10

# AI Analysis 서버 헬스체크
echo "🔍 AI Analysis 서버 헬스체크..."
curl -f http://localhost:8081/api/v1/ai/health || echo "❌ AI Analysis 서버 헬스체크 실패"

# Main API 서버 헬스체크  
echo "🔍 Main API 서버 헬스체크..."
curl -f http://localhost:8080/actuator/health || echo "❌ Main API 서버 헬스체크 실패"

echo "✨ AI Integration 수정 완료!"
echo ""
echo "🔑 다음 단계:"
echo "1. .env 파일에서 실제 API 키들을 설정하세요:"
echo "   - ROBOFLOW_API_KEY"
echo "   - ROBOFLOW_WORKSPACE_URL" 
echo "   - GOOGLE_CLOUD_PROJECT_ID"
echo "   - OPENROUTER_API_KEY"
echo ""
echo "2. Google Cloud 서비스 계정 키 파일을 docker 컨테이너에 마운트하세요"
echo ""
echo "3. 서비스들을 다시 시작하세요:"
echo "   docker-compose -f docker-compose.prod.yml restart"