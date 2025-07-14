#!/bin/bash

set -e

echo "=========================================="
echo "JB Report Platform - 전체 수정 작업 실행"
echo "=========================================="
echo ""

# Make all scripts executable
chmod +x scripts/*.sh

# Step 1: Fix package structure
echo "Step 1: 패키지 구조 통일..."
./scripts/fix-package-structure.sh

echo ""
echo "Press Enter to continue to Step 2..."
read

# Step 2: Fix dependencies
echo "Step 2: 의존성 수정..."
./scripts/fix-dependencies.sh

echo ""
echo "Press Enter to continue to Step 3..."
read

# Step 3: Create missing entities
echo "Step 3: Entity 클래스 생성..."
./scripts/create-missing-entities.sh

echo ""
echo "Press Enter to continue to Step 4..."
read

# Step 4: Test build
echo "Step 4: 빌드 테스트..."
./scripts/test-build.sh

echo ""
echo "=========================================="
echo "모든 수정 작업 완료!"
echo "=========================================="
