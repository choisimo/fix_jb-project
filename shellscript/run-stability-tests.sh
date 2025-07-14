#!/bin/bash

# 전북신고 플랫폼 시스템 안정성 테스트 실행 스크립트
# 사용법: ./run-stability-tests.sh [test-type]
# test-type: all, sms, email, nice, jwt, user, redis, integration

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_header() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${WHITE}$1${NC}"
    echo -e "${PURPLE}========================================${NC}"
}

# 환경 변수 설정
export SPRING_PROFILES_ACTIVE=test
export DATABASE_URL=${DATABASE_URL:-jdbc:postgresql://localhost:5432/jeonbuk_report_test}
export DATABASE_USERNAME=${DATABASE_USERNAME:-postgres}
export DATABASE_PASSWORD=${DATABASE_PASSWORD:-password}
export REDIS_HOST=${REDIS_HOST:-localhost}
export REDIS_PASSWORD=${REDIS_PASSWORD:-}
export JWT_SECRET=${JWT_SECRET:-test-jwt-secret-key-for-stability-testing-only}

# 메이븐 또는 그래들 확인
if [ -f "pom.xml" ]; then
    BUILD_TOOL="maven"
    TEST_CMD="mvn test"
elif [ -f "build.gradle" ]; then
    BUILD_TOOL="gradle"
    TEST_CMD="./gradlew test"
else
    log_error "pom.xml 또는 build.gradle 파일을 찾을 수 없습니다."
    exit 1
fi

log_info "빌드 도구: $BUILD_TOOL"

# 테스트 타입 확인
TEST_TYPE=${1:-all}

log_header "전북신고 플랫폼 시스템 안정성 테스트"
log_info "테스트 타입: $TEST_TYPE"
log_info "시작 시간: $(date '+%Y-%m-%d %H:%M:%S')"

# 사전 요구사항 확인
log_info "사전 요구사항 확인 중..."

# Java 버전 확인
if ! command -v java &> /dev/null; then
    log_error "Java가 설치되어 있지 않습니다."
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
if [ "$JAVA_VERSION" -lt 17 ]; then
    log_error "Java 17 이상이 필요합니다. 현재 버전: $JAVA_VERSION"
    exit 1
fi

log_success "Java 버전 확인 완료: $(java -version 2>&1 | head -n 1)"

# PostgreSQL 연결 확인 (선택사항)
if command -v pg_isready &> /dev/null; then
    if pg_isready -h localhost -p 5432 &> /dev/null; then
        log_success "PostgreSQL 연결 확인 완료"
    else
        log_warning "PostgreSQL 연결을 확인할 수 없습니다. 계속 진행합니다."
    fi
fi

# Redis 연결 확인 (선택사항)
if command -v redis-cli &> /dev/null; then
    if redis-cli -h localhost ping &> /dev/null; then
        log_success "Redis 연결 확인 완료"
    else
        log_warning "Redis 연결을 확인할 수 없습니다. 계속 진행합니다."
    fi
fi

# 테스트 실행 함수
run_test() {
    local test_class=$1
    local test_name=$2
    
    log_info "$test_name 실행 중..."
    
    if [ "$BUILD_TOOL" = "maven" ]; then
        if mvn test -Dtest="$test_class" -q; then
            log_success "$test_name 완료"
            return 0
        else
            log_error "$test_name 실패"
            return 1
        fi
    else
        if ./gradlew test --tests "$test_class" -q; then
            log_success "$test_name 완료"
            return 0
        else
            log_error "$test_name 실패"
            return 1
        fi
    fi
}

# 테스트 결과 추적
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=()

# 테스트 실행
case $TEST_TYPE in
    "sms")
        log_header "SMS 인증 서비스 안정성 테스트"
        TOTAL_TESTS=1
        if run_test "SmsVerificationStabilityTest" "SMS 인증 서비스 테스트"; then
            ((PASSED_TESTS++))
        else
            FAILED_TESTS+=("SMS 인증 서비스")
        fi
        ;;
    
    "email")
        log_header "Email 인증 서비스 안정성 테스트"
        TOTAL_TESTS=1
        if run_test "EmailVerificationStabilityTest" "Email 인증 서비스 테스트"; then
            ((PASSED_TESTS++))
        else
            FAILED_TESTS+=("Email 인증 서비스")
        fi
        ;;
    
    "nice")
        log_header "NICE 실명인증 서비스 안정성 테스트"
        TOTAL_TESTS=1
        if run_test "NiceIdentityVerificationStabilityTest" "NICE 실명인증 서비스 테스트"; then
            ((PASSED_TESTS++))
        else
            FAILED_TESTS+=("NICE 실명인증 서비스")
        fi
        ;;
    
    "jwt")
        log_header "JWT 토큰 서비스 안정성 테스트"
        TOTAL_TESTS=1
        if run_test "JwtTokenServiceStabilityTest" "JWT 토큰 서비스 테스트"; then
            ((PASSED_TESTS++))
        else
            FAILED_TESTS+=("JWT 토큰 서비스")
        fi
        ;;
    
    "user")
        log_header "사용자 서비스 안정성 테스트"
        TOTAL_TESTS=1
        if run_test "UserServiceStabilityTest" "사용자 서비스 테스트"; then
            ((PASSED_TESTS++))
        else
            FAILED_TESTS+=("사용자 서비스")
        fi
        ;;
    
    "redis")
        log_header "Redis 서비스 안정성 테스트"
        TOTAL_TESTS=1
        if run_test "RedisServiceStabilityTest" "Redis 서비스 테스트"; then
            ((PASSED_TESTS++))
        else
            FAILED_TESTS+=("Redis 서비스")
        fi
        ;;
    
    "integration")
        log_header "통합 안정성 테스트"
        TOTAL_TESTS=1
        if run_test "IntegratedStabilityTest" "통합 안정성 테스트"; then
            ((PASSED_TESTS++))
        else
            FAILED_TESTS+=("통합 테스트")
        fi
        ;;
    
    "all")
        log_header "전체 시스템 안정성 테스트"
        
        # 개별 서비스 테스트
        TESTS=(
            "RedisServiceStabilityTest:Redis 서비스"
            "JwtTokenServiceStabilityTest:JWT 토큰 서비스"
            "UserServiceStabilityTest:사용자 서비스"
            "SmsVerificationStabilityTest:SMS 인증 서비스"
            "EmailVerificationStabilityTest:Email 인증 서비스"
            "NiceIdentityVerificationStabilityTest:NICE 실명인증 서비스"
        )
        
        TOTAL_TESTS=${#TESTS[@]}
        
        for test_info in "${TESTS[@]}"; do
            test_class=$(echo $test_info | cut -d':' -f1)
            test_name=$(echo $test_info | cut -d':' -f2)
            
            if run_test "$test_class" "$test_name"; then
                ((PASSED_TESTS++))
            else
                FAILED_TESTS+=("$test_name")
            fi
        done
        
        # 통합 테스트 실행
        log_header "통합 안정성 테스트 실행"
        ((TOTAL_TESTS++))
        if run_test "IntegratedStabilityTest" "통합 안정성 테스트"; then
            ((PASSED_TESTS++))
        else
            FAILED_TESTS+=("통합 테스트")
        fi
        ;;
    
    *)
        log_error "지원하지 않는 테스트 타입: $TEST_TYPE"
        log_info "사용 가능한 타입: all, sms, email, nice, jwt, user, redis, integration"
        exit 1
        ;;
esac

# 결과 출력
log_header "테스트 결과 요약"
log_info "완료 시간: $(date '+%Y-%m-%d %H:%M:%S')"
log_info "총 테스트 스위트: $TOTAL_TESTS"
log_success "성공: $PASSED_TESTS"

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
    log_error "실패: ${#FAILED_TESTS[@]}"
    log_error "실패한 테스트:"
    for failed in "${FAILED_TESTS[@]}"; do
        log_error "  - $failed"
    done
    echo ""
    log_error "일부 테스트가 실패했습니다. 로그를 확인하세요."
    exit 1
else
    log_success "모든 테스트가 성공했습니다! 🎉"
    echo ""
    log_info "시스템이 안정성 기준을 모두 충족했습니다."
    exit 0
fi