#!/bin/bash

set -e

echo "=========================================="
echo "JB Report Platform - 빌드 테스트"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test main-api-server
echo "=== main-api-server 빌드 테스트 ==="
cd main-api-server

echo "Gradle 래퍼 확인..."
if [ ! -f "gradlew" ]; then
    echo "Gradle 래퍼 생성..."
    gradle wrapper --gradle-version=8.5
fi

echo "의존성 다운로드..."
./gradlew dependencies > /dev/null 2>&1

echo "클린 빌드 시작..."
if ./gradlew clean build -x test; then
    echo -e "${GREEN}✅ main-api-server 빌드 성공!${NC}"
    
    # Check JAR file
    JAR_FILE=$(find build/libs -name "*.jar" | head -1)
    if [ -f "$JAR_FILE" ]; then
        echo -e "${GREEN}✅ JAR 파일 생성: $JAR_FILE${NC}"
    fi
else
    echo -e "${RED}❌ main-api-server 빌드 실패${NC}"
    echo "에러 로그:"
    tail -50 build/reports/compilejava/*.txt 2>/dev/null || echo "로그 파일 없음"
fi

cd ..

echo ""
echo "=== ai-analysis-server 빌드 테스트 ==="
cd ai-analysis-server

echo "Gradle 래퍼 확인..."
if [ ! -f "gradlew" ]; then
    echo "Gradle 래퍼 생성..."
    gradle wrapper --gradle-version=8.5
fi

echo "의존성 다운로드..."
./gradlew dependencies > /dev/null 2>&1

echo "클린 빌드 시작..."
if ./gradlew clean build -x test; then
    echo -e "${GREEN}✅ ai-analysis-server 빌드 성공!${NC}"
    
    # Check JAR file
    JAR_FILE=$(find build/libs -name "*.jar" | head -1)
    if [ -f "$JAR_FILE" ]; then
        echo -e "${GREEN}✅ JAR 파일 생성: $JAR_FILE${NC}"
    fi
else
    echo -e "${RED}❌ ai-analysis-server 빌드 실패${NC}"
    echo "에러 로그:"
    tail -50 build/reports/compilejava/*.txt 2>/dev/null || echo "로그 파일 없음"
fi

cd ..

echo ""
echo "=== 빌드 결과 요약 ==="
echo ""

# Check build results
MAIN_JAR=$(find main-api-server/build/libs -name "*.jar" 2>/dev/null | head -1)
AI_JAR=$(find ai-analysis-server/build/libs -name "*.jar" 2>/dev/null | head -1)

if [ -f "$MAIN_JAR" ] && [ -f "$AI_JAR" ]; then
    echo -e "${GREEN}✅ 모든 프로젝트 빌드 성공!${NC}"
    echo ""
    echo "생성된 JAR 파일:"
    echo "  - $MAIN_JAR"
    echo "  - $AI_JAR"
    echo ""
    echo -e "${GREEN}시스템이 이제 실행 가능합니다!${NC}"
else
    echo -e "${RED}❌ 일부 프로젝트 빌드 실패${NC}"
    echo ""
    echo "빌드 실패 프로젝트를 확인하고 수정해주세요."
fi
