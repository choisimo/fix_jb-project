#!/bin/bash

set -e

echo "=========================================="
echo "JB Report Platform - 실제 빌드 테스트"
echo "테스트 시작: $(date)"
echo "=========================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Log file
LOG_FILE="build-test-$(date +%Y%m%d_%H%M%S).log"

# Function to test build
test_build() {
    local project=$1
    local build_cmd=$2
    local test_name=$3
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "[$TOTAL_TESTS] $test_name... "
    
    cd "$project" 2>/dev/null || {
        echo -e "${RED}FAILED${NC} - 디렉토리 없음"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo "[$test_name] 디렉토리 없음: $project" >> "../$LOG_FILE"
        cd - > /dev/null
        return 1
    }
    
    # Run build command and capture output
    if $build_cmd > "../build_output_${project}.log" 2>&1; then
        echo -e "${GREEN}PASSED${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo "[$test_name] 성공" >> "../$LOG_FILE"
    else
        echo -e "${RED}FAILED${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        
        # Extract error details
        echo "[$test_name] 실패" >> "../$LOG_FILE"
        echo "빌드 로그:" >> "../$LOG_FILE"
        tail -50 "../build_output_${project}.log" >> "../$LOG_FILE"
        echo "---" >> "../$LOG_FILE"
        
        # Count compilation errors
        local compile_errors=$(grep -c "error:" "../build_output_${project}.log" 2>/dev/null || echo "0")
        echo "  컴파일 에러: $compile_errors 개"
    fi
    
    cd - > /dev/null
}

# Function to check file existence
check_file() {
    local file=$1
    local desc=$2
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "[$TOTAL_TESTS] $desc 확인... "
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}EXISTS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}MISSING${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo "[$desc] 파일 없음: $file" >> "$LOG_FILE"
    fi
}

# Function to test package structure
test_package_structure() {
    local project=$1
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "[$TOTAL_TESTS] $project 패키지 구조 확인... "
    
    cd "$project/src/main/java" 2>/dev/null || {
        echo -e "${RED}FAILED${NC} - 소스 디렉토리 없음"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    }
    
    # Count different package structures
    local jbreport_count=$(find . -name "*.java" -path "*/jbreport/*" | wc -l)
    local jeonbuk_count=$(find . -name "*.java" -path "*/jeonbuk/*" | wc -l)
    
    echo ""
    echo "  - com.jbreport.* 파일 수: $jbreport_count"
    echo "  - com.jeonbuk.* 파일 수: $jeonbuk_count"
    
    if [ $jbreport_count -gt 0 ] && [ $jeonbuk_count -gt 0 ]; then
        echo -e "  결과: ${YELLOW}WARNING${NC} - 패키지 구조 혼재"
        echo "[$project] 패키지 구조 혼재 - jbreport: $jbreport_count, jeonbuk: $jeonbuk_count" >> "../../../$LOG_FILE"
    elif [ $jbreport_count -eq 0 ] && [ $jeonbuk_count -eq 0 ]; then
        echo -e "  결과: ${RED}FAILED${NC} - Java 파일 없음"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    else
        echo -e "  결과: ${GREEN}PASSED${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    fi
    
    cd - > /dev/null
}

# Function to check dependencies
check_dependencies() {
    local build_file=$1
    local dep=$2
    
    if grep -q "$dep" "$build_file" 2>/dev/null; then
        echo -e "  - $dep: ${GREEN}✓${NC}"
    else
        echo -e "  - $dep: ${RED}✗${NC}"
    fi
}

echo "=== 1. 프로젝트 구조 검증 ==="
echo ""

# Check main directories
check_file "main-api-server/build.gradle" "Main API Server build.gradle"
check_file "ai-analysis-server/build.gradle" "AI Analysis Server build.gradle"
check_file "flutter-app/pubspec.yaml" "Flutter App pubspec.yaml"
check_file "docker-compose.yml" "Docker Compose 설정"

echo ""
echo "=== 2. 패키지 구조 분석 ==="
echo ""

test_package_structure "main-api-server"
test_package_structure "ai-analysis-server"

echo ""
echo "=== 3. 의존성 확인 ==="
echo ""

echo "Main API Server 의존성:"
check_dependencies "main-api-server/build.gradle" "spring-boot-starter-web"
check_dependencies "main-api-server/build.gradle" "spring-boot-starter-data-jpa"
check_dependencies "main-api-server/build.gradle" "jakarta.persistence-api"
check_dependencies "main-api-server/build.gradle" "validation-api"

echo ""
echo "AI Analysis Server 의존성:"
check_dependencies "ai-analysis-server/build.gradle" "spring-boot-starter-web"
check_dependencies "ai-analysis-server/build.gradle" "spring-boot-starter-data-jpa"

echo ""
echo "=== 4. 실제 빌드 테스트 ==="
echo ""

# Test builds
test_build "main-api-server" "./gradlew clean build -x test" "Main API Server 빌드"
test_build "ai-analysis-server" "./gradlew clean build -x test" "AI Analysis Server 빌드"
test_build "flutter-app" "flutter pub get" "Flutter 의존성 설치"

echo ""
echo "=== 5. JAR 파일 생성 확인 ==="
echo ""

check_file "main-api-server/build/libs/*.jar" "Main API Server JAR"
check_file "ai-analysis-server/build/libs/*.jar" "AI Analysis Server JAR"

echo ""
echo "=== 6. 실행 가능성 테스트 ==="
echo ""

# Try to run servers
TOTAL_TESTS=$((TOTAL_TESTS + 1))
echo -n "[$TOTAL_TESTS] Main API Server 실행 테스트... "

if [ -f "main-api-server/build/libs/"*.jar ]; then
    timeout 10 java -jar main-api-server/build/libs/*.jar --server.port=8090 > server_test.log 2>&1 &
    SERVER_PID=$!
    sleep 5
    
    if ps -p $SERVER_PID > /dev/null 2>&1; then
        echo -e "${GREEN}RUNNING${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        kill $SERVER_PID 2>/dev/null
    else
        echo -e "${RED}FAILED TO START${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        
        # Show error from log
        echo "  시작 오류:"
        grep -i "error\|exception" server_test.log | head -5
    fi
else
    echo -e "${RED}NO JAR FILE${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

echo ""
echo "=== 7. 데이터베이스 연결 테스트 ==="
echo ""

TOTAL_TESTS=$((TOTAL_TESTS + 1))
echo -n "[$TOTAL_TESTS] PostgreSQL 연결 테스트... "

if docker ps | grep -q "postgres"; then
    if docker exec jbreport-postgres pg_isready -U jbreport > /dev/null 2>&1; then
        echo -e "${GREEN}CONNECTED${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}CONNECTION FAILED${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
else
    echo -e "${YELLOW}CONTAINER NOT RUNNING${NC}"
fi

echo ""
echo "=========================================="
echo "테스트 완료: $(date)"
echo "=========================================="
echo ""
echo "총 테스트: $TOTAL_TESTS"
echo -e "성공: ${GREEN}$PASSED_TESTS${NC}"
echo -e "실패: ${RED}$FAILED_TESTS${NC}"
echo ""

# Calculate percentage
if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo "성공률: ${SUCCESS_RATE}%"
else
    echo "성공률: 0%"
fi

echo ""
echo "상세 로그: $LOG_FILE"
echo ""

# Generate detailed report
if [ $FAILED_TESTS -gt 0 ]; then
    echo "=== 주요 문제점 ==="
    echo ""
    
    # Check for common issues
    if grep -q "package.*does not exist" build_output_*.log 2>/dev/null; then
        echo "❌ 패키지 구조 문제 발견"
        grep "package.*does not exist" build_output_*.log | head -5
    fi
    
    if grep -q "cannot find symbol" build_output_*.log 2>/dev/null; then
        echo "❌ 심볼을 찾을 수 없음"
        grep "cannot find symbol" build_output_*.log | head -5
    fi
    
    if grep -q "dependencies" build_output_*.log 2>/dev/null; then
        echo "❌ 의존성 문제"
    fi
fi

exit $FAILED_TESTS
