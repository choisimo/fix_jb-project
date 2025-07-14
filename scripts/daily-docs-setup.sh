#!/bin/bash

# 전북 리포트 플랫폼 - 일일 문서 관리 스크립트
# 작성자: opencode
# 날짜: 2025-07-13

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수 정의
print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}     전북 리포트 플랫폼 - 일일 문서 설정      ${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 메인 실행
main() {
    print_header
    
    # 날짜 설정
    if [ -z "$1" ]; then
        TODAY=$(date +%Y-%m-%d)
        echo -e "📅 날짜: ${GREEN}$TODAY${NC} (기본값 사용)"
    else
        TODAY="$1"
        echo -e "📅 날짜: ${GREEN}$TODAY${NC} (사용자 지정)"
    fi
    
    # 문서 루트 디렉토리
    DOCS_ROOT="documents"
    DOCS_DIR="$DOCS_ROOT/$TODAY"
    TEMPLATES_DIR="$DOCS_ROOT/templates"
    
    echo -e "📁 문서 디렉토리: ${BLUE}$DOCS_DIR${NC}"
    echo
    
    # 템플릿 디렉토리 확인
    if [ ! -d "$TEMPLATES_DIR" ]; then
        print_error "템플릿 디렉토리가 존재하지 않습니다: $TEMPLATES_DIR"
        echo "먼저 템플릿을 설정해주세요."
        exit 1
    fi
    
    # 날짜별 디렉토리 생성
    echo "🏗️  디렉토리 구조 생성 중..."
    mkdir -p "$DOCS_DIR"/{service,infrastructure,analysis,meeting,planning,testing}
    
    # 각 카테고리별 디렉토리 생성 확인
    categories=("service" "infrastructure" "analysis" "meeting" "planning" "testing")
    for category in "${categories[@]}"; do
        if [ -d "$DOCS_DIR/$category" ]; then
            print_success "$category 디렉토리 생성됨"
        else
            print_error "$category 디렉토리 생성 실패"
        fi
    done
    
    echo
    
    # README 파일 생성
    echo "📝 README 파일 생성 중..."
    cat > "$DOCS_DIR/README.md" << EOF
# $TODAY 문서 디렉토리

이 디렉토리는 $TODAY에 작성된 프로젝트 문서들을 포함합니다.

## 디렉토리 구조

- \`service/\` - API 명세, 서비스 설계, 구현 가이드
- \`infrastructure/\` - DB 스키마, 배포 가이드, 모니터링
- \`analysis/\` - 오류 분석, 성능 분석, 완성도 분석
- \`meeting/\` - 회의록, 기획 회의, 회고
- \`planning/\` - PRD, 기능 명세, 로드맵
- \`testing/\` - 테스트 케이스, 테스트 결과

## 작성 가이드

1. 각 문서는 메타데이터 헤더를 포함해야 합니다
2. 파일명은 \`{카테고리}-{주제}-{버전}.md\` 형식을 따릅니다
3. 템플릿을 활용하여 일관성 있는 문서를 작성하세요

## 템플릿 위치
\`../templates/\` 디렉토리에서 템플릿을 확인할 수 있습니다.

생성일: $TODAY
생성자: 일일 문서 설정 스크립트
EOF
    
    print_success "README.md 파일 생성됨"
    
    echo
    
    # 인덱스 업데이트
    echo "📚 문서 인덱스 업데이트 중..."
    update_index
    
    echo
    print_success "일일 문서 디렉토리 설정이 완료되었습니다!"
    echo
    echo -e "${BLUE}다음 단계:${NC}"
    echo "1. cd $DOCS_DIR"
    echo "2. 해당 카테고리 디렉토리에서 문서 작성 시작"
    echo "3. 템플릿 활용: cp ../templates/{템플릿명}.md {카테고리}/{새문서명}.md"
    echo
}

# 문서 인덱스 업데이트 함수
update_index() {
    INDEX_FILE="$DOCS_ROOT/INDEX.md"
    
    cat > "$INDEX_FILE" << EOF
# 전북 리포트 플랫폼 문서 인덱스

마지막 업데이트: $(date +"%Y-%m-%d %H:%M:%S")

## 최근 문서 디렉토리

EOF
    
    # 최근 10개 날짜 디렉토리 나열
    find "$DOCS_ROOT" -maxdepth 1 -type d -name "20*" | sort -r | head -10 | while read dir; do
        dirname=$(basename "$dir")
        echo "- [$dirname](./$dirname/) - $(date -d "$dirname" +"%Y년 %m월 %d일" 2>/dev/null || echo "$dirname")" >> "$INDEX_FILE"
    done
    
    cat >> "$INDEX_FILE" << EOF

## 카테고리별 분류

### 📊 분석 (Analysis)
최근 분석 문서들

### 🔧 서비스 (Service)  
API 명세 및 서비스 설계 문서들

### 🏗️ 인프라 (Infrastructure)
시스템 구성 및 배포 관련 문서들

### 📋 회의 (Meeting)
프로젝트 회의록 및 의사결정 기록

### 📈 기획 (Planning)
제품 기획 및 요구사항 문서들

### 🧪 테스트 (Testing)
테스트 계획 및 결과 문서들

## 문서 작성 가이드

### 파일명 규칙
\`{카테고리}-{주제}-{버전}.md\`

예시:
- \`service-user-auth-v1.md\`
- \`analysis-error-report-v2.md\`
- \`meeting-sprint-planning-v1.md\`

### 메타데이터 헤더
모든 문서는 다음 헤더를 포함해야 합니다:

\`\`\`markdown
---
title: 문서 제목
category: service|infrastructure|analysis|meeting|planning|testing
date: YYYY-MM-DD
version: 1.0
author: 작성자명
last_modified: YYYY-MM-DD
tags: [tag1, tag2, tag3]
status: draft|review|approved|archived
---
\`\`\`

## 템플릿 사용법

1. 템플릿 복사: \`cp templates/{템플릿}.md {날짜}/{카테고리}/{문서명}.md\`
2. 메타데이터 수정
3. 내용 작성
4. 검토 및 승인

EOF
    
    print_success "문서 인덱스가 업데이트되었습니다"
}

# 도움말 출력
show_help() {
    echo "사용법: $0 [날짜]"
    echo
    echo "옵션:"
    echo "  날짜    문서 디렉토리를 생성할 날짜 (YYYY-MM-DD 형식)"
    echo "          지정하지 않으면 오늘 날짜를 사용합니다"
    echo
    echo "예시:"
    echo "  $0                # 오늘 날짜로 생성"
    echo "  $0 2025-07-14    # 특정 날짜로 생성"
    echo
    echo "기능:"
    echo "  - 날짜별 문서 디렉토리 구조 생성"
    echo "  - 카테고리별 하위 디렉토리 생성"
    echo "  - README 파일 자동 생성"
    echo "  - 문서 인덱스 업데이트"
}

# 인자 확인
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# 스크립트 실행
main "$1"