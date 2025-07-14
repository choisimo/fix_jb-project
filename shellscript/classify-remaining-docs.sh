#!/bin/bash

# 전북 리포트 플랫폼 - 문서 분류 완료 스크립트
# 작성자: opencode
# 날짜: 2025-07-13

set -e

echo "🏗️ 남은 문서들 분류 중..."

# PRD 관련 문서들
echo "📋 PRD 문서 분류..."
find documents/prd -name "*.md" -exec basename {} \; | while read file; do
    if [ -f "documents/prd/$file" ]; then
        safe_name=$(echo "prd_$file" | tr '/' '_')
        cp "documents/prd/$file" "documents-classified/planning/prd/$safe_name"
        echo "  PRD: $file → planning/prd/$safe_name"
    fi
done

# 하위 디렉토리 PRD 문서들
find documents/prd -type f -name "*.md" | while read file; do
    relative_path=${file#documents/prd/}
    safe_name=$(echo "prd_$relative_path" | tr '/' '_')
    cp "$file" "documents-classified/planning/prd/$safe_name"
    echo "  PRD: $relative_path → planning/prd/$safe_name"
done

# API 및 서비스 관련
echo "🔧 서비스 문서 분류..."
find documents -name "*API*" -o -name "*SERVICE*" | while read file; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        cp "$file" "documents-classified/service/api/$filename"
        echo "  API: $filename → service/api/"
    fi
done

# 데이터베이스 관련
echo "🗄️ 데이터베이스 문서 분류..."
find documents -name "*DATABASE*" -o -name "*SCHEMA*" -o -name "*DB*" | while read file; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        cp "$file" "documents-classified/infrastructure/database/$filename"
        echo "  DB: $filename → infrastructure/database/"
    fi
done

# 테스트 관련
echo "🧪 테스트 문서 분류..."
find documents -name "*TEST*" -o -name "*VALIDATION*" | while read file; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        cp "$file" "documents-classified/testing/validation/$filename"
        echo "  TEST: $filename → testing/validation/"
    fi
done

# 완성도 및 상태 보고서
echo "📊 분석 문서 분류..."
find documents -name "*REPORT*" -o -name "*STATUS*" -o -name "*COMPLETION*" | while read file; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        if [[ $filename =~ ERROR|FIX|TROUBLESHOOTING ]]; then
            cp "$file" "documents-classified/analysis/error-reports/$filename"
            echo "  ERROR: $filename → analysis/error-reports/"
        else
            cp "$file" "documents-classified/analysis/completion-status/$filename"
            echo "  STATUS: $filename → analysis/completion-status/"
        fi
    fi
done

# 나머지 문서들을 일반 문서로 분류
echo "📚 기타 문서 분류..."
find documents -maxdepth 1 -name "*.md" | while read file; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        # 이미 분류되지 않은 파일들만
        if ! find documents-classified -name "$filename" | grep -q .; then
            cp "$file" "documents-classified/general/documentation/$filename"
            echo "  GENERAL: $filename → general/documentation/"
        fi
    fi
done

# 하위 디렉토리의 기타 문서들
find documents -type f -name "*.md" | while read file; do
    filename=$(basename "$file")
    relative_path=${file#documents/}
    safe_name=$(echo "$relative_path" | tr '/' '_')
    
    # 이미 분류된 파일인지 확인
    if ! find documents-classified -name "$safe_name" -o -name "$filename" | grep -q .; then
        # 파일 내용 기반 간단 분류
        if grep -qi "error\|fix\|troubleshoot" "$file" 2>/dev/null; then
            cp "$file" "documents-classified/analysis/error-reports/$safe_name"
            echo "  ERROR: $relative_path → analysis/error-reports/$safe_name"
        elif grep -qi "api\|service\|endpoint" "$file" 2>/dev/null; then
            cp "$file" "documents-classified/service/implementation/$safe_name"
            echo "  SERVICE: $relative_path → service/implementation/$safe_name"
        elif grep -qi "test\|validation" "$file" 2>/dev/null; then
            cp "$file" "documents-classified/testing/validation/$safe_name"
            echo "  TEST: $relative_path → testing/validation/$safe_name"
        elif grep -qi "database\|schema" "$file" 2>/dev/null; then
            cp "$file" "documents-classified/infrastructure/database/$safe_name"
            echo "  DB: $relative_path → infrastructure/database/$safe_name"
        elif grep -qi "deploy\|setup\|install" "$file" 2>/dev/null; then
            cp "$file" "documents-classified/infrastructure/deployment/$safe_name"
            echo "  DEPLOY: $relative_path → infrastructure/deployment/$safe_name"
        else
            cp "$file" "documents-classified/general/documentation/$safe_name"
            echo "  GENERAL: $relative_path → general/documentation/$safe_name"
        fi
    fi
done

echo "✅ 문서 분류 완료!"