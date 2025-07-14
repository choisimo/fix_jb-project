#!/bin/bash

# 전북 리포트 플랫폼 - 간단한 문서 분류 스크립트
# 작성자: opencode
# 날짜: 2025-07-13

set -e

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}     전북 리포트 플랫폼 - 문서 분류 시스템     ${NC}"
echo -e "${BLUE}================================================${NC}"
echo

# 분류 디렉토리 생성
echo "🏗️  분류 디렉토리 구조 생성 중..."
mkdir -p documents-classified/{planning,service,infrastructure,analysis,testing,meeting,general}
mkdir -p documents-classified/planning/{prd,requirements,features}
mkdir -p documents-classified/service/{api,implementation}
mkdir -p documents-classified/infrastructure/{setup,database,deployment}
mkdir -p documents-classified/analysis/{error-reports,completion-status}
mkdir -p documents-classified/testing/{validation}
mkdir -p documents-classified/meeting/{general}
mkdir -p documents-classified/general/{guides,documentation}

echo -e "${GREEN}✅ 분류 디렉토리 구조 생성 완료${NC}"

# 문서 분류 함수
classify_file() {
    local file="$1"
    local filename=$(basename "$file")
    local content=$(head -20 "$file" 2>/dev/null | tr '[:upper:]' '[:lower:]' || echo "")
    
    # 간단한 키워드 기반 분류
    if [[ $filename =~ QUICK_START|API_KEYS|OAUTH2.*SETUP ]] || [[ $content =~ "가이드|guide|setup" ]]; then
        echo "infrastructure/setup"
    elif [[ $filename =~ IMPLEMENTATION|PROGRESS ]] || [[ $content =~ "implementation|구현|progress" ]]; then
        echo "analysis/completion-status"
    elif [[ $filename =~ TEST.*REPORT|VERIFICATION ]] || [[ $content =~ "test|테스트|verification" ]]; then
        echo "testing/validation"
    elif [[ $filename =~ PRD ]] || [[ $content =~ "prd|requirements" ]]; then
        echo "planning/prd"
    elif [[ $content =~ "api|endpoint" ]]; then
        echo "service/api"
    elif [[ $content =~ "error|오류|fix" ]]; then
        echo "analysis/error-reports"
    elif [[ $content =~ "feature|기능" ]]; then
        echo "planning/features"
    elif [[ $content =~ "database|schema" ]]; then
        echo "infrastructure/database"
    elif [[ $content =~ "deploy|배포" ]]; then
        echo "infrastructure/deployment"
    else
        echo "general/documentation"
    fi
}

echo "📋 문서 분류 시작..."

total_files=0
classified_files=0

# 루트 디렉토리 markdown 파일 분류
echo -e "${CYAN}📁 루트 디렉토리 문서 분류 중...${NC}"
for file in ./*.md; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        category=$(classify_file "$file")
        target_dir="documents-classified/$category"
        
        cp "$file" "$target_dir/$filename"
        echo "  $filename → $category"
        
        ((total_files++))
        ((classified_files++))
    fi
done

# documents 디렉토리 문서 분류
echo -e "${CYAN}📁 documents 디렉토리 문서 분류 중...${NC}"
find documents -name "*.md" -type f | while read file; do
    relative_path=${file#./documents/}
    safe_filename=$(echo "$relative_path" | tr '/' '_')
    category=$(classify_file "$file")
    target_dir="documents-classified/$category"
    
    cp "$file" "$target_dir/$safe_filename"
    echo "  $relative_path → $category/$safe_filename"
    
    ((total_files++))
    ((classified_files++))
done

# 간단한 통계 생성
cat > documents-classified/README.md << EOF
# 전북 리포트 플랫폼 - 분류된 문서

분류 완료 시간: $(date "+%Y-%m-%d %H:%M:%S")

## 📁 디렉토리 구조

- **planning/** - 기획 문서
  - prd/ - PRD 문서
  - requirements/ - 요구사항
  - features/ - 기능 명세
- **service/** - 서비스 관련
  - api/ - API 문서
  - implementation/ - 구현 문서
- **infrastructure/** - 인프라
  - setup/ - 설정 가이드
  - database/ - DB 관련
  - deployment/ - 배포 관련
- **analysis/** - 분석 문서
  - error-reports/ - 오류 분석
  - completion-status/ - 완성도 분석
- **testing/** - 테스트
  - validation/ - 검증 문서
- **general/** - 일반 문서
  - guides/ - 가이드
  - documentation/ - 기타 문서

## 📊 통계

EOF

# 카테고리별 파일 수 계산
for category in planning service infrastructure analysis testing general; do
    count=$(find "documents-classified/$category" -name "*.md" 2>/dev/null | wc -l)
    echo "- $category: $count 개 문서" >> documents-classified/README.md
done

echo >> documents-classified/README.md
echo "**총 분류된 문서 수:** $(find documents-classified -name "*.md" | wc -l)" >> documents-classified/README.md

echo
echo -e "${GREEN}✅ 문서 분류 작업 완료!${NC}"
echo
echo -e "${BLUE}결과:${NC}"
echo "  📁 documents-classified/ 디렉토리에 분류된 문서들이 저장되었습니다"
echo "  📄 documents-classified/README.md 에서 분류 결과를 확인하세요"
echo

# 분류 결과 요약
echo -e "${CYAN}분류 결과 요약:${NC}"
for category in planning service infrastructure analysis testing general; do
    count=$(find "documents-classified/$category" -name "*.md" 2>/dev/null | wc -l)
    echo "  $category: $count 개"
done