#!/bin/bash

# Google ML OCR API 키 설정 스크립트
# 사용법: ./setup-google-ocr-keys.sh

set -e

echo "🔧 Google ML OCR API 키 설정을 시작합니다..."

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 프로젝트 루트 디렉토리
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CREDENTIALS_DIR="${PROJECT_ROOT}/ai-analysis-server/src/main/resources/credentials"

echo -e "${BLUE}📋 Google ML OCR 설정 체크리스트:${NC}"
echo "1. ✅ Google ML Kit (클라이언트) - API 키 불필요"
echo "2. ⚠️  Google Cloud Vision API (서버) - API 키 필요"
echo ""

# Google Cloud 프로젝트 ID 입력
echo -e "${YELLOW}🔍 Google Cloud 프로젝트 설정${NC}"
read -p "Google Cloud 프로젝트 ID를 입력하세요 (예: jb-report-ocr-project): " PROJECT_ID

if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}❌ 프로젝트 ID가 필요합니다.${NC}"
    exit 1
fi

# 서비스 계정 키 파일 경로 입력
echo ""
echo -e "${YELLOW}🔑 서비스 계정 키 파일 설정${NC}"
echo "Google Cloud Console에서 다운로드한 서비스 계정 키 파일(.json)의 경로를 입력하세요."
read -p "키 파일 경로: " KEY_FILE_PATH

if [ ! -f "$KEY_FILE_PATH" ]; then
    echo -e "${RED}❌ 키 파일을 찾을 수 없습니다: $KEY_FILE_PATH${NC}"
    echo -e "${BLUE}💡 Google Cloud Console에서 서비스 계정 키를 다운로드하세요:${NC}"
    echo "   1. https://console.cloud.google.com 접속"
    echo "   2. IAM 및 관리자 > 서비스 계정"
    echo "   3. 새 서비스 계정 생성 또는 기존 계정 선택"
    echo "   4. 키 생성 > JSON 형식 다운로드"
    exit 1
fi

# credentials 디렉토리 생성
echo ""
echo -e "${BLUE}📁 자격증명 디렉토리 생성 중...${NC}"
mkdir -p "$CREDENTIALS_DIR"

# 키 파일 복사
KEY_FILENAME="google-vision-service-key.json"
DEST_KEY_PATH="${CREDENTIALS_DIR}/${KEY_FILENAME}"

echo -e "${BLUE}📋 키 파일 복사 중...${NC}"
cp "$KEY_FILE_PATH" "$DEST_KEY_PATH"

# 파일 권한 설정 (보안)
chmod 600 "$DEST_KEY_PATH"
echo -e "${GREEN}✅ 키 파일 권한 설정 완료 (600)${NC}"

# application.yml 설정 업데이트
YAML_FILE="${PROJECT_ROOT}/ai-analysis-server/src/main/resources/application.yml"
YAML_BACKUP="${YAML_FILE}.backup.$(date +%Y%m%d_%H%M%S)"

echo ""
echo -e "${BLUE}⚙️ application.yml 설정 업데이트 중...${NC}"

# 기존 파일 백업
if [ -f "$YAML_FILE" ]; then
    cp "$YAML_FILE" "$YAML_BACKUP"
    echo -e "${GREEN}✅ 기존 설정 백업: $(basename "$YAML_BACKUP")${NC}"
fi

# Google Vision 설정 추가
cat >> "$YAML_FILE" << EOF

# Google ML OCR 설정 (자동 추가됨)
google:
  cloud:
    vision:
      enabled: true
      project-id: ${PROJECT_ID}
      credentials-path: /credentials/${KEY_FILENAME}

# OCR 기본 설정
ocr:
  default:
    confidence-threshold: 0.5
    timeout-ms: 10000
    enable-fallback: true
    supported-languages:
      - ko
      - en
  engine-weights:
    google-vision: 0.6
    ai-model: 0.4
    ml-kit: 0.3
EOF

echo -e "${GREEN}✅ application.yml 설정 추가 완료${NC}"

# .gitignore 업데이트
GITIGNORE_FILE="${PROJECT_ROOT}/.gitignore"
echo ""
echo -e "${BLUE}🔒 .gitignore 업데이트 중...${NC}"

if ! grep -q "credentials/\*.json" "$GITIGNORE_FILE" 2>/dev/null; then
    echo "" >> "$GITIGNORE_FILE"
    echo "# Google Cloud 서비스 계정 키 (보안)" >> "$GITIGNORE_FILE"
    echo "src/main/resources/credentials/*.json" >> "$GITIGNORE_FILE"
    echo -e "${GREEN}✅ .gitignore에 키 파일 제외 규칙 추가${NC}"
else
    echo -e "${YELLOW}⚠️ .gitignore에 이미 키 파일 제외 규칙이 있습니다${NC}"
fi

# 환경변수 설정 스크립트 생성
ENV_SCRIPT="${PROJECT_ROOT}/set-google-ocr-env.sh"
cat > "$ENV_SCRIPT" << EOF
#!/bin/bash
# Google ML OCR 환경변수 설정 스크립트
# 사용법: source ./set-google-ocr-env.sh

export GOOGLE_CLOUD_PROJECT="${PROJECT_ID}"
export GOOGLE_APPLICATION_CREDENTIALS="${DEST_KEY_PATH}"

echo "✅ Google ML OCR 환경변수 설정 완료"
echo "   GOOGLE_CLOUD_PROJECT=\$GOOGLE_CLOUD_PROJECT"
echo "   GOOGLE_APPLICATION_CREDENTIALS=\$GOOGLE_APPLICATION_CREDENTIALS"
EOF

chmod +x "$ENV_SCRIPT"
echo -e "${GREEN}✅ 환경변수 설정 스크립트 생성: $(basename "$ENV_SCRIPT")${NC}"

# 설정 검증 스크립트 생성
VERIFY_SCRIPT="${PROJECT_ROOT}/verify-google-ocr.sh"
cat > "$VERIFY_SCRIPT" << EOF
#!/bin/bash
# Google ML OCR 설정 검증 스크립트

echo "🔍 Google ML OCR 설정 검증 중..."

# 키 파일 존재 확인
if [ -f "${DEST_KEY_PATH}" ]; then
    echo "✅ 서비스 계정 키 파일 존재"
else
    echo "❌ 서비스 계정 키 파일 없음"
    exit 1
fi

# 환경변수 확인
if [ -n "\$GOOGLE_CLOUD_PROJECT" ]; then
    echo "✅ GOOGLE_CLOUD_PROJECT 설정됨: \$GOOGLE_CLOUD_PROJECT"
else
    echo "⚠️ GOOGLE_CLOUD_PROJECT 환경변수 미설정"
fi

if [ -n "\$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    echo "✅ GOOGLE_APPLICATION_CREDENTIALS 설정됨"
else
    echo "⚠️ GOOGLE_APPLICATION_CREDENTIALS 환경변수 미설정"
fi

echo ""
echo "🚀 서버 시작 후 다음 로그 메시지를 확인하세요:"
echo "   ✅ Google Cloud Vision API 클라이언트 초기화 완료"
echo ""
echo "📋 API 테스트 명령어:"
echo "   curl -X POST \"http://localhost:8080/api/v1/ocr/extract\" \\"
echo "     -F \"image=@test_image.jpg\" \\"
echo "     -F \"enableGoogleVision=true\""
EOF

chmod +x "$VERIFY_SCRIPT"
echo -e "${GREEN}✅ 설정 검증 스크립트 생성: $(basename "$VERIFY_SCRIPT")${NC}"

# 완료 메시지
echo ""
echo -e "${GREEN}🎉 Google ML OCR API 키 설정이 완료되었습니다!${NC}"
echo ""
echo -e "${BLUE}📋 다음 단계:${NC}"
echo "1. 환경변수 설정: source ./set-google-ocr-env.sh"
echo "2. 서버 시작: cd ai-analysis-server && ./gradlew bootRun"
echo "3. 설정 검증: ./verify-google-ocr.sh"
echo ""
echo -e "${YELLOW}💰 비용 안내:${NC}"
echo "• Google ML Kit: 완전 무료 (온디바이스)"
echo "• Google Vision API: 월 1,000회 무료, 초과 시 1,000회당 $1.50"
echo ""
echo -e "${RED}🔒 보안 주의사항:${NC}"
echo "• 서비스 계정 키 파일을 Git에 커밋하지 마세요"
echo "• 프로덕션에서는 환경변수 사용을 권장합니다"
echo "• 키 파일 권한이 600으로 설정되었습니다"