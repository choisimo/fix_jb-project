#!/bin/bash

# 전북 리포트 플랫폼 - 문서 분류 스크립트
# 작성자: opencode
# 날짜: 2025-07-13

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}     전북 리포트 플랫폼 - 문서 분류 시스템     ${NC}"
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

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# 문서 내용 분석 함수
analyze_document() {
    local file="$1"
    local content=$(head -50 "$file" | tr '[:upper:]' '[:lower:]')
    local filename=$(basename "$file")
    
    # 키워드 기반 분류
    if [[ $content =~ (prd|product requirements|기능 명세|요구사항) ]] || [[ $filename =~ prd ]]; then
        echo "planning"
    elif [[ $content =~ (api|endpoint|swagger|rest|컨트롤러|서비스) ]] || [[ $filename =~ api ]]; then
        echo "service"
    elif [[ $content =~ (error|오류|troubleshooting|해결|fix|bug) ]] || [[ $filename =~ (error|fix) ]]; then
        echo "analysis"
    elif [[ $content =~ (setup|guide|가이드|설치|배포|docker|deployment) ]] || [[ $filename =~ (guide|setup) ]]; then
        echo "infrastructure"
    elif [[ $content =~ (test|테스트|검증|validation|report) ]] || [[ $filename =~ (test|report) ]]; then
        echo "testing"
    elif [[ $content =~ (meeting|회의|standup|retrospective) ]] || [[ $filename =~ meeting ]]; then
        echo "meeting"
    elif [[ $content =~ (implementation|구현|summary|요약|progress) ]] || [[ $filename =~ (implementation|summary) ]]; then
        echo "analysis"
    elif [[ $content =~ (oauth|auth|authentication|인증|security) ]] || [[ $filename =~ (oauth|auth) ]]; then
        echo "service"
    elif [[ $content =~ (database|db|schema|스키마) ]] || [[ $filename =~ (db|database) ]]; then
        echo "infrastructure"
    elif [[ $content =~ (flutter|모바일|mobile|앱) ]] || [[ $filename =~ flutter ]]; then
        echo "planning"
    else
        echo "general"
    fi
}

# 분류된 디렉토리 생성
create_classified_structure() {
    local base_dir="documents-classified"
    
    echo -e "🏗️  분류된 문서 디렉토리 구조 생성 중..."
    
    # 메인 카테고리
    mkdir -p "$base_dir"/{planning,service,infrastructure,analysis,testing,meeting,general}
    
    # 하위 카테고리
    mkdir -p "$base_dir/planning"/{prd,requirements,roadmap,features}
    mkdir -p "$base_dir/service"/{api,architecture,implementation}
    mkdir -p "$base_dir/infrastructure"/{deployment,database,setup,configuration}
    mkdir -p "$base_dir/analysis"/{error-reports,performance,completion-status}
    mkdir -p "$base_dir/testing"/{test-plans,test-results,validation}
    mkdir -p "$base_dir/meeting"/{standup,planning,retrospective}
    mkdir -p "$base_dir/general"/{guides,documentation,misc}
    
    print_success "분류 디렉토리 구조 생성 완료"
}

# 특정 카테고리의 하위 분류 결정
get_subcategory() {
    local category="$1"
    local file="$2"
    local content=$(head -30 "$file" | tr '[:upper:]' '[:lower:]')
    local filename=$(basename "$file")
    
    case $category in
        "planning")
            if [[ $filename =~ prd ]] || [[ $content =~ "product requirements" ]]; then
                echo "prd"
            elif [[ $content =~ (feature|기능) ]]; then
                echo "features"
            elif [[ $content =~ (roadmap|로드맵) ]]; then
                echo "roadmap"
            else
                echo "requirements"
            fi
            ;;
        "service")
            if [[ $content =~ (api|endpoint|swagger) ]]; then
                echo "api"
            elif [[ $content =~ (architecture|아키텍처) ]]; then
                echo "architecture"
            else
                echo "implementation"
            fi
            ;;
        "infrastructure")
            if [[ $content =~ (deploy|배포) ]]; then
                echo "deployment"
            elif [[ $content =~ (database|schema|db) ]]; then
                echo "database"
            elif [[ $content =~ (setup|설치) ]]; then
                echo "setup"
            else
                echo "configuration"
            fi
            ;;
        "analysis")
            if [[ $content =~ (error|오류) ]]; then
                echo "error-reports"
            elif [[ $content =~ (performance|성능) ]]; then
                echo "performance"
            else
                echo "completion-status"
            fi
            ;;
        "testing")
            if [[ $content =~ (plan|계획) ]]; then
                echo "test-plans"
            elif [[ $content =~ (result|결과) ]]; then
                echo "test-results"
            else
                echo "validation"
            fi
            ;;
        "meeting")
            if [[ $content =~ (standup|daily) ]]; then
                echo "standup"
            elif [[ $content =~ (planning|계획) ]]; then
                echo "planning"
            else
                echo "retrospective"
            fi
            ;;
        "general")
            if [[ $content =~ (guide|가이드) ]]; then
                echo "guides"
            elif [[ $content =~ (doc|문서) ]]; then
                echo "documentation"
            else
                echo "misc"
            fi
            ;;
        *)
            echo "misc"
            ;;
    esac
}

# 문서 분류 및 복사
classify_documents() {
    local total_files=0
    local classified_files=0
    local classification_log="documents-classified/classification-log.txt"
    
    echo "📋 문서 분류 시작..."
    echo "분류 로그: $classification_log"
    
    # 로그 파일 초기화
    echo "전북 리포트 플랫폼 문서 분류 로그" > "$classification_log"
    echo "분류 시간: $(date)" >> "$classification_log"
    echo "======================================" >> "$classification_log"
    echo >> "$classification_log"
    
    # 루트 디렉토리의 markdown 파일들
    echo -e "${PURPLE}📁 루트 디렉토리 문서 분류 중...${NC}"
    for file in ./*.md; do
        if [ -f "$file" ]; then
            ((total_files++))
            
            filename=$(basename "$file")
            category=$(analyze_document "$file")
            subcategory=$(get_subcategory "$category" "$file")
            
            target_dir="documents-classified/$category/$subcategory"
            target_file="$target_dir/$filename"
            
            # 파일 복사
            cp "$file" "$target_file"
            ((classified_files++))
            
            echo -e "  ${GREEN}$filename${NC} → ${CYAN}$category/$subcategory${NC}"
            echo "$filename → $category/$subcategory" >> "$classification_log"
        fi
    done
    
    echo >> "$classification_log"
    echo "documents 디렉토리 분류:" >> "$classification_log"
    
    # documents 디렉토리의 모든 markdown 파일들
    echo -e "${PURPLE}📁 documents 디렉토리 문서 분류 중...${NC}"
    while IFS= read -r -d '' file; do
        ((total_files++))
        
        filename=$(basename "$file")
        relative_path=${file#./documents/}
        category=$(analyze_document "$file")
        subcategory=$(get_subcategory "$category" "$file")
        
        # 원본 경로 정보 보존을 위한 파일명 조정
        if [[ "$relative_path" =~ / ]]; then
            # 하위 디렉토리에 있는 파일의 경우 경로 정보를 파일명에 포함
            safe_path=$(echo "$relative_path" | tr '/' '_')
            target_filename="${safe_path}"
        else
            target_filename="$filename"
        fi
        
        target_dir="documents-classified/$category/$subcategory"
        target_file="$target_dir/$target_filename"
        
        # 중복 파일명 처리
        counter=1
        original_target="$target_file"
        while [ -f "$target_file" ]; do
            base_name="${original_target%.*}"
            extension="${original_target##*.}"
            target_file="${base_name}_${counter}.${extension}"
            ((counter++))
        done
        
        # 파일 복사
        cp "$file" "$target_file"
        ((classified_files++))
        
        echo -e "  ${GREEN}$relative_path${NC} → ${CYAN}$category/$subcategory/$(basename "$target_file")${NC}"
        echo "$relative_path → $category/$subcategory/$(basename "$target_file")" >> "$classification_log"
        
    done < <(find documents -name "*.md" -type f -print0)
    
    echo >> "$classification_log"
    echo "======================================" >> "$classification_log"
    echo "총 파일 수: $total_files" >> "$classification_log"
    echo "분류된 파일 수: $classified_files" >> "$classification_log"
    
    print_success "총 $total_files 개 문서 중 $classified_files 개 분류 완료"
}

# 분류 통계 생성
generate_statistics() {
    local stats_file="documents-classified/classification-statistics.md"
    
    echo "📊 분류 통계 생성 중..."
    
    cat > "$stats_file" << EOF
---
title: 문서 분류 통계
category: analysis
date: $(date +%Y-%m-%d)
version: 1.0
author: 문서분류시스템
last_modified: $(date +%Y-%m-%d)
tags: [문서분류, 통계, 자동화]
status: approved
---

# 전북 리포트 플랫폼 문서 분류 통계

분류 완료 시간: $(date "+%Y-%m-%d %H:%M:%S")

## 📊 전체 통계

EOF

    # 카테고리별 통계
    echo "### 카테고리별 문서 수" >> "$stats_file"
    echo "| 카테고리 | 문서 수 | 비율 |" >> "$stats_file"
    echo "|----------|---------|------|" >> "$stats_file"
    
    local total_files=$(find documents-classified -name "*.md" -type f | wc -l)
    
    for category in planning service infrastructure analysis testing meeting general; do
        local count=$(find "documents-classified/$category" -name "*.md" -type f | wc -l)
        local percentage=$(( count * 100 / total_files ))
        echo "| $category | $count | ${percentage}% |" >> "$stats_file"
    done
    
    echo >> "$stats_file"
    echo "**총 문서 수: $total_files**" >> "$stats_file"
    echo >> "$stats_file"
    
    # 하위 카테고리별 상세 통계
    echo "## 📋 하위 카테고리별 상세 통계" >> "$stats_file"
    echo >> "$stats_file"
    
    for category in planning service infrastructure analysis testing meeting general; do
        echo "### $category" >> "$stats_file"
        echo "| 하위 카테고리 | 문서 수 |" >> "$stats_file"
        echo "|---------------|---------|" >> "$stats_file"
        
        find "documents-classified/$category" -mindepth 1 -maxdepth 1 -type d | while read subdir; do
            subcategory=$(basename "$subdir")
            count=$(find "$subdir" -name "*.md" -type f | wc -l)
            echo "| $subcategory | $count |" >> "$stats_file"
        done
        echo >> "$stats_file"
    done
    
    # 디렉토리 구조
    echo "## 🗂️ 분류된 디렉토리 구조" >> "$stats_file"
    echo >> "$stats_file"
    echo '```' >> "$stats_file"
    tree documents-classified -d >> "$stats_file" 2>/dev/null || {
        echo "documents-classified/" >> "$stats_file"
        find documents-classified -type d | sort | sed 's/[^/]*\//  /g' >> "$stats_file"
    }
    echo '```' >> "$stats_file"
    
    print_success "분류 통계 생성 완료: $stats_file"
}

# 인덱스 파일 생성
create_classification_index() {
    local index_file="documents-classified/README.md"
    
    cat > "$index_file" << EOF
---
title: 분류된 문서 인덱스
category: general
date: $(date +%Y-%m-%d)
version: 1.0
author: 문서분류시스템
last_modified: $(date +%Y-%m-%d)
tags: [문서분류, 인덱스, 자동화]
status: approved
---

# 전북 리포트 플랫폼 - 분류된 문서 인덱스

이 디렉토리는 프로젝트의 모든 Markdown 문서를 내용과 목적에 따라 자동 분류한 결과입니다.

분류 완료 시간: $(date "+%Y-%m-%d %H:%M:%S")

## 📁 디렉토리 구조

### 📋 Planning (기획)
- \`prd/\` - Product Requirements Documents
- \`requirements/\` - 요구사항 문서
- \`roadmap/\` - 프로젝트 로드맵
- \`features/\` - 기능 명세서

### 🔧 Service (서비스)
- \`api/\` - API 명세서 및 문서
- \`architecture/\` - 시스템 아키텍처
- \`implementation/\` - 구현 관련 문서

### 🏗️ Infrastructure (인프라)
- \`deployment/\` - 배포 가이드
- \`database/\` - 데이터베이스 관련
- \`setup/\` - 설치 및 설정
- \`configuration/\` - 구성 관리

### 📊 Analysis (분석)
- \`error-reports/\` - 오류 분석 보고서
- \`performance/\` - 성능 분석
- \`completion-status/\` - 완성도 분석

### 🧪 Testing (테스트)
- \`test-plans/\` - 테스트 계획
- \`test-results/\` - 테스트 결과
- \`validation/\` - 검증 문서

### 📝 Meeting (회의)
- \`standup/\` - 일일 스탠드업
- \`planning/\` - 기획 회의
- \`retrospective/\` - 회고 회의

### 📚 General (일반)
- \`guides/\` - 사용자 가이드
- \`documentation/\` - 일반 문서
- \`misc/\` - 기타 문서

## 🔍 문서 검색

### 카테고리별 문서 찾기
\`\`\`bash
# 특정 카테고리의 모든 문서 나열
find documents-classified/planning -name "*.md"

# 키워드로 문서 검색
grep -r "API" documents-classified/service/
\`\`\`

### 최근 분류된 문서
\`\`\`bash
# 최근 수정된 문서 10개
find documents-classified -name "*.md" -type f -exec ls -lt {} + | head -10
\`\`\`

## 📊 통계 정보

분류 통계는 \`classification-statistics.md\` 파일에서 확인할 수 있습니다.

## 🔄 재분류

문서를 다시 분류하려면:
\`\`\`bash
./scripts/document-classifier.sh
\`\`\`

---

이 분류는 자동화된 키워드 분석을 기반으로 수행되었습니다. 
필요에 따라 수동으로 문서를 이동하여 분류를 조정할 수 있습니다.
EOF

    print_success "분류 인덱스 생성 완료: $index_file"
}

# 메인 함수
main() {
    print_header
    
    print_info "총 $(find . -name "*.md" -type f | wc -l)개의 Markdown 문서 발견"
    
    # 기존 분류 디렉토리 삭제 (있다면)
    if [ -d "documents-classified" ]; then
        print_warning "기존 분류 디렉토리 삭제 중..."
        rm -rf documents-classified
    fi
    
    # 분류 작업 수행
    create_classified_structure
    classify_documents
    generate_statistics
    create_classification_index
    
    echo
    print_success "문서 분류 작업이 완료되었습니다!"
    echo
    echo -e "${BLUE}다음 단계:${NC}"
    echo "1. cd documents-classified"
    echo "2. cat README.md  # 분류 결과 확인"
    echo "3. cat classification-statistics.md  # 통계 확인"
    echo
    echo -e "${CYAN}분류된 디렉토리:${NC}"
    echo "  📁 documents-classified/"
    for category in planning service infrastructure analysis testing meeting general; do
        count=$(find "documents-classified/$category" -name "*.md" -type f | wc -l)
        echo -e "    ├── ${category}/ (${count}개 문서)"
    done
    echo
}

# 도움말
show_help() {
    echo "사용법: $0"
    echo
    echo "기능:"
    echo "  - 루트 디렉토리와 documents 디렉토리의 모든 .md 파일 분석"
    echo "  - 내용 기반 자동 분류"
    echo "  - 구조화된 디렉토리에 문서 복사"
    echo "  - 분류 통계 및 인덱스 생성"
    echo
    echo "분류 카테고리:"
    echo "  planning      - PRD, 요구사항, 기능 명세"
    echo "  service       - API, 아키텍처, 구현"
    echo "  infrastructure - 배포, DB, 설정"
    echo "  analysis      - 오류 분석, 성능, 완성도"
    echo "  testing       - 테스트 계획, 결과, 검증"
    echo "  meeting       - 회의록, 스탠드업, 회고"
    echo "  general       - 가이드, 문서, 기타"
}

# 인자 확인
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# 스크립트 실행
main