#!/bin/bash

set -e

echo "=========================================="
echo "JB Report Platform - 패키지 구조 통일 작업"
echo "목표: com.jeonbuk.report로 모든 패키지 통일"
echo "=========================================="
echo ""

# Backup directory
BACKUP_DIR="backup-$(date +%Y%m%d_%H%M%S)"
echo "백업 디렉토리: $BACKUP_DIR"

# Function to fix package structure
fix_package_structure() {
    local project=$1
    echo ""
    echo "=== $project 패키지 구조 수정 중 ==="
    
    cd "$project"
    
    # Create backup
    echo "백업 생성 중..."
    mkdir -p "../$BACKUP_DIR/$project"
    cp -r src "../$BACKUP_DIR/$project/"
    
    # Step 1: Create new directory structure
    echo "새 디렉토리 구조 생성..."
    mkdir -p src/main/java/com/jeonbuk/report/{domain,application,presentation,infrastructure,config,exception,dto,util}
    mkdir -p src/main/java/com/jeonbuk/report/domain/{entity,repository}
    mkdir -p src/main/java/com/jeonbuk/report/application/{service,dto}
    mkdir -p src/main/java/com/jeonbuk/report/presentation/{controller,dto}
    mkdir -p src/main/java/com/jeonbuk/report/infrastructure/{persistence,external}
    
    # Step 2: Move and rename files
    echo "파일 이동 및 패키지 수정..."
    
    # Find all Java files and process them
    find src/main/java -name "*.java" -type f | while read file; do
        # Skip if already in correct structure
        if [[ $file == *"com/jeonbuk/report"* ]]; then
            continue
        fi
        
        # Determine target location based on file type
        filename=$(basename "$file")
        target_dir=""
        
        # Entity files
        if [[ $filename == *Entity.java ]] || [[ $filename == User.java ]] || [[ $filename == Report.java ]] || [[ $filename == Alert.java ]]; then
            target_dir="src/main/java/com/jeonbuk/report/domain/entity"
        # Repository files
        elif [[ $filename == *Repository.java ]]; then
            target_dir="src/main/java/com/jeonbuk/report/domain/repository"
        # Controller files
        elif [[ $filename == *Controller.java ]]; then
            target_dir="src/main/java/com/jeonbuk/report/presentation/controller"
        # Service files
        elif [[ $filename == *Service.java ]] && [[ $filename != *ServiceImpl.java ]]; then
            target_dir="src/main/java/com/jeonbuk/report/application/service"
        # DTO files
        elif [[ $filename == *DTO.java ]] || [[ $filename == *Dto.java ]] || [[ $filename == *Request.java ]] || [[ $filename == *Response.java ]]; then
            if [[ $file == *controller* ]] || [[ $file == *presentation* ]]; then
                target_dir="src/main/java/com/jeonbuk/report/presentation/dto"
            else
                target_dir="src/main/java/com/jeonbuk/report/application/dto"
            fi
        # Config files
        elif [[ $filename == *Config.java ]] || [[ $filename == *Configuration.java ]]; then
            target_dir="src/main/java/com/jeonbuk/report/config"
        # Exception files
        elif [[ $filename == *Exception.java ]]; then
            target_dir="src/main/java/com/jeonbuk/report/exception"
        # Default to util
        else
            target_dir="src/main/java/com/jeonbuk/report/util"
        fi
        
        # Move file
        if [ -n "$target_dir" ]; then
            echo "  이동: $filename -> $target_dir/"
            mv "$file" "$target_dir/" 2>/dev/null || echo "    경고: $filename 이동 실패"
        fi
    done
    
    # Step 3: Fix package declarations and imports
    echo "패키지 선언 및 import 문 수정..."
    find src/main/java/com/jeonbuk/report -name "*.java" -type f | while read file; do
        # Fix package declaration
        if grep -q "^package com\.jbreport" "$file"; then
            # Determine correct package based on location
            dir=$(dirname "$file")
            package_path=$(echo "$dir" | sed 's|src/main/java/||' | sed 's|/|.|g')
            sed -i "s|^package com\.jbreport.*|package $package_path;|" "$file"
        fi
        
        # Fix imports
        sed -i 's|import com\.jbreport\.platform|import com.jeonbuk.report|g' "$file"
        sed -i 's|import com\.jbreport|import com.jeonbuk.report|g' "$file"
        
        # Fix specific imports based on new structure
        sed -i 's|import com\.jeonbuk\.report\.entity|import com.jeonbuk.report.domain.entity|g' "$file"
        sed -i 's|import com\.jeonbuk\.report\.repository|import com.jeonbuk.report.domain.repository|g' "$file"
        sed -i 's|import com\.jeonbuk\.report\.service|import com.jeonbuk.report.application.service|g' "$file"
        sed -i 's|import com\.jeonbuk\.report\.controller|import com.jeonbuk.report.presentation.controller|g' "$file"
        sed -i 's|import com\.jeonbuk\.report\.dto|import com.jeonbuk.report.application.dto|g' "$file"
    done
    
    # Step 4: Clean up empty directories
    echo "빈 디렉토리 정리..."
    find src/main/java -type d -empty -delete 2>/dev/null || true
    
    # Remove old package directories
    rm -rf src/main/java/com/jbreport 2>/dev/null || true
    
    cd ..
}

# Fix main-api-server
fix_package_structure "main-api-server"

# Fix ai-analysis-server
fix_package_structure "ai-analysis-server"

echo ""
echo "=== 패키지 구조 통일 완료 ==="
echo ""

# Generate report
echo "=== 변경 사항 요약 ==="
echo ""

for project in main-api-server ai-analysis-server; do
    echo "$project:"
    echo "  총 Java 파일 수: $(find $project/src/main/java -name "*.java" | wc -l)"
    echo "  Entity 파일: $(find $project/src/main/java/com/jeonbuk/report/domain/entity -name "*.java" 2>/dev/null | wc -l)"
    echo "  Repository 파일: $(find $project/src/main/java/com/jeonbuk/report/domain/repository -name "*.java" 2>/dev/null | wc -l)"
    echo "  Service 파일: $(find $project/src/main/java/com/jeonbuk/report/application/service -name "*.java" 2>/dev/null | wc -l)"
    echo "  Controller 파일: $(find $project/src/main/java/com/jeonbuk/report/presentation/controller -name "*.java" 2>/dev/null | wc -l)"
    echo ""
done

echo "백업 위치: $BACKUP_DIR"
echo ""
echo "다음 단계: ./scripts/fix-dependencies.sh 실행"
