#!/bin/bash

# 전북 리포트 플랫폼 - 문서 유효성 검증 스크립트
# 작성자: opencode
# 날짜: 2025-07-13

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}     전북 리포트 플랫폼 - 문서 유효성 검증     ${NC}"
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

# 메타데이터 검증 함수
validate_metadata() {
    local file="$1"
    local errors=0
    
    echo "📄 검증 중: $(basename "$file")"
    
    # 메타데이터 헤더 확인
    if ! head -1 "$file" | grep -q "^---$"; then
        print_error "  메타데이터 헤더가 없습니다 (---로 시작해야 함)"
        ((errors++))
    fi
    
    # 필수 필드 확인
    required_fields=("title" "category" "date" "version" "author" "status")
    for field in "${required_fields[@]}"; do
        if ! grep -q "^$field:" "$file"; then
            print_error "  필수 필드 누락: $field"
            ((errors++))
        fi
    done
    
    # 카테고리 유효성 확인
    valid_categories=("service" "infrastructure" "analysis" "meeting" "planning" "testing")
    category=$(grep "^category:" "$file" | cut -d':' -f2 | tr -d ' ')
    
    if [[ ! " ${valid_categories[@]} " =~ " ${category} " ]]; then
        print_error "  유효하지 않은 카테고리: $category"
        print_warning "  유효한 카테고리: ${valid_categories[*]}"
        ((errors++))
    fi
    
    # 날짜 형식 확인
    date_value=$(grep "^date:" "$file" | cut -d':' -f2 | tr -d ' ')
    if ! [[ $date_value =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        print_error "  날짜 형식이 올바르지 않습니다: $date_value (YYYY-MM-DD 형식 필요)"
        ((errors++))
    fi
    
    # 상태 유효성 확인
    valid_statuses=("draft" "review" "approved" "archived")
    status=$(grep "^status:" "$file" | cut -d':' -f2 | tr -d ' ')
    
    if [[ ! " ${valid_statuses[@]} " =~ " ${status} " ]]; then
        print_error "  유효하지 않은 상태: $status"
        print_warning "  유효한 상태: ${valid_statuses[*]}"
        ((errors++))
    fi
    
    if [ $errors -eq 0 ]; then
        print_success "  문서 유효성 검증 통과"
    else
        print_error "  $errors 개의 오류 발견"
    fi
    
    return $errors
}

# 파일명 규칙 검증 함수
validate_filename() {
    local file="$1"
    local filename=$(basename "$file" .md)
    local dirname=$(basename $(dirname "$file"))
    
    # 파일명 형식 확인: {카테고리}-{주제}-{버전}.md
    if [[ ! $filename =~ ^[a-z]+-[a-z0-9-]+-v[0-9]+$ ]]; then
        print_warning "파일명 권장 규칙 미준수: $filename"
        print_warning "권장 형식: {카테고리}-{주제}-{버전}.md (예: service-auth-api-v1.md)"
        return 1
    fi
    
    return 0
}

# 메인 함수
main() {
    print_header
    
    local target_dir="documents"
    if [ ! -z "$1" ]; then
        target_dir="documents/$1"
    fi
    
    if [ ! -d "$target_dir" ]; then
        print_error "디렉토리가 존재하지 않습니다: $target_dir"
        exit 1
    fi
    
    echo -e "📁 검증 대상: ${BLUE}$target_dir${NC}"
    echo
    
    local total_files=0
    local valid_files=0
    local total_errors=0
    
    # Markdown 파일 찾기
    while IFS= read -r -d '' file; do
        ((total_files++))
        
        # 파일명 검증
        validate_filename "$file"
        
        # 메타데이터 검증
        if validate_metadata "$file"; then
            ((valid_files++))
        else
            ((total_errors++))
        fi
        
        echo
    done < <(find "$target_dir" -name "*.md" -type f -print0)
    
    # 결과 요약
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}                  검증 결과 요약                ${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo -e "📊 총 문서 수: ${total_files}"
    echo -e "✅ 유효한 문서: ${valid_files}"
    echo -e "❌ 오류가 있는 문서: ${total_errors}"
    echo
    
    if [ $total_errors -eq 0 ]; then
        print_success "모든 문서가 유효성 검증을 통과했습니다!"
        exit 0
    else
        print_error "$total_errors 개의 문서에서 오류가 발견되었습니다."
        echo -e "${YELLOW}위의 오류를 수정한 후 다시 검증해주세요.${NC}"
        exit 1
    fi
}

# 도움말
show_help() {
    echo "사용법: $0 [날짜]"
    echo
    echo "옵션:"
    echo "  날짜    검증할 문서 디렉토리의 날짜 (YYYY-MM-DD 형식)"
    echo "          지정하지 않으면 전체 documents 디렉토리를 검증합니다"
    echo
    echo "예시:"
    echo "  $0                # 전체 문서 검증"
    echo "  $0 2025-07-13    # 특정 날짜 문서 검증"
    echo
    echo "검증 항목:"
    echo "  - 메타데이터 헤더 존재 여부"
    echo "  - 필수 필드 완성도 (title, category, date, version, author, status)"
    echo "  - 카테고리 유효성"
    echo "  - 날짜 형식"
    echo "  - 상태 유효성"
    echo "  - 파일명 규칙"
}

# 인자 확인
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# 스크립트 실행
main "$1"