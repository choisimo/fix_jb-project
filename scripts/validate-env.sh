#!/bin/bash

# =============================================================================
# 환경변수 검증 스크립트
# =============================================================================

set -e

ENV_FILE="${1:-.env}"

echo "🔍 환경변수 파일 검증 시작: $ENV_FILE"

# 파일 존재 확인
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ ERROR: 환경변수 파일을 찾을 수 없습니다: $ENV_FILE"
    exit 1
fi

# 환경변수 로딩 유틸리티 사용
source "$(dirname "$0")/env-utils.sh"

# 환경변수 파일 로드
if ! load_env "$ENV_FILE"; then
    echo "❌ ERROR: 환경변수 파일 로딩 실패"
    exit 1
fi

# 필수 환경변수 확인
required_vars=(
    "ENVIRONMENT"
    "DATABASE_USERNAME"
    "DATABASE_PASSWORD"
    "DATABASE_URL"
    "REDIS_HOST"
    "REDIS_PASSWORD"
    "JWT_SECRET"
)

# 환경별 추가 필수 변수
if [ "$ENVIRONMENT" = "production" ]; then
    required_vars+=(
        "GOOGLE_CLIENT_ID"
        "GOOGLE_CLIENT_SECRET"
        "KAKAO_CLIENT_ID"
        "KAKAO_CLIENT_SECRET"
        "ROBOFLOW_API_KEY"
        "OPENROUTER_API_KEY"
    )
fi

echo "🔎 필수 환경변수 검증 중..."
if ! validate_required_vars "${required_vars[@]}"; then
    exit 1
fi

# 형식 검증
echo "🔎 환경변수 형식 검증 중..."

validation_errors=0

# URL 형식 검증
if [[ -n "$DATABASE_URL" && ! "$DATABASE_URL" =~ ^jdbc:postgresql:// ]]; then
    echo "❌ ERROR: DATABASE_URL 형식이 올바르지 않습니다: $DATABASE_URL"
    validation_errors=$((validation_errors + 1))
fi

# 포트 번호 검증
if [[ -n "$REDIS_PORT" && ! "$REDIS_PORT" =~ ^[0-9]+$ ]]; then
    echo "❌ ERROR: REDIS_PORT는 숫자여야 합니다: $REDIS_PORT"
    validation_errors=$((validation_errors + 1))
fi

if [[ -n "$SERVER_PORT" && ! "$SERVER_PORT" =~ ^[0-9]+$ ]]; then
    echo "❌ ERROR: SERVER_PORT는 숫자여야 합니다: $SERVER_PORT"
    validation_errors=$((validation_errors + 1))
fi

# JWT 시크릿 길이 확인 (최소 32자)
if [[ -n "$JWT_SECRET" && ${#JWT_SECRET} -lt 32 ]]; then
    echo "❌ ERROR: JWT_SECRET은 최소 32자 이상이어야 합니다"
    validation_errors=$((validation_errors + 1))
fi

# 불린 값 검증
boolean_vars=("ENABLE_DEBUG_MODE" "ENABLE_MOCK_DATA" "ENABLE_LOGGING" "TEST_MODE")
for var in "${boolean_vars[@]}"; do
    value="${!var}"
    if [[ -n "$value" && ! "$value" =~ ^(true|false)$ ]]; then
        echo "❌ ERROR: $var는 true 또는 false여야 합니다: $value"
        validation_errors=$((validation_errors + 1))
    fi
done

# 숫자 값 검증
numeric_vars=("CONNECTION_TIMEOUT" "RECEIVE_TIMEOUT" "SEND_TIMEOUT" "MAX_RETRY_ATTEMPTS")
for var in "${numeric_vars[@]}"; do
    value="${!var}"
    if [[ -n "$value" && ! "$value" =~ ^[0-9]+$ ]]; then
        echo "❌ ERROR: $var는 숫자여야 합니다: $value"
        validation_errors=$((validation_errors + 1))
    fi
done

# 환경 타입 검증
if [[ -n "$ENVIRONMENT" && ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
    echo "❌ ERROR: ENVIRONMENT는 development, staging, production 중 하나여야 합니다: $ENVIRONMENT"
    validation_errors=$((validation_errors + 1))
fi

# Spring Profile 검증
if [[ -n "$SPRING_PROFILES_ACTIVE" && ! "$SPRING_PROFILES_ACTIVE" =~ ^(dev|staging|prod)$ ]]; then
    echo "❌ ERROR: SPRING_PROFILES_ACTIVE는 dev, staging, prod 중 하나여야 합니다: $SPRING_PROFILES_ACTIVE"
    validation_errors=$((validation_errors + 1))
fi

# 파일 경로 검증
if [[ -n "$FILE_STORAGE_PATH" && ! -d "$(dirname "$FILE_STORAGE_PATH")" ]]; then
    echo "⚠️  WARNING: FILE_STORAGE_PATH의 상위 디렉토리가 존재하지 않습니다: $FILE_STORAGE_PATH"
fi

# 중복 변수 확인
echo "🔎 중복 변수 확인 중..."
duplicate_keys=$(grep -v '^#' "$ENV_FILE" | grep -v '^$' | cut -d'=' -f1 | sort | uniq -d)
if [[ -n "$duplicate_keys" ]]; then
    echo "❌ ERROR: 중복된 환경변수 키 발견:"
    echo "$duplicate_keys"
    validation_errors=$((validation_errors + 1))
fi

# 빈 값 확인 (필수 변수 중)
echo "🔎 빈 값 확인 중..."
for var in "${required_vars[@]}"; do
    value="${!var}"
    if [[ -z "$value" ]]; then
        echo "❌ ERROR: 필수 환경변수 $var의 값이 비어있습니다"
        validation_errors=$((validation_errors + 1))
    fi
done

# 보안 변수 노출 확인
echo "🔎 보안 변수 노출 확인 중..."
sensitive_patterns=("password" "secret" "key" "token")
for pattern in "${sensitive_patterns[@]}"; do
    exposed_vars=$(grep -i "$pattern" "$ENV_FILE" | grep -v '^#' | grep '=.*[^*]' | head -3)
    if [[ -n "$exposed_vars" ]]; then
        echo "⚠️  WARNING: 민감한 정보가 포함된 변수가 평문으로 저장되어 있을 수 있습니다:"
        echo "$exposed_vars" | sed 's/=.*/=***/'
    fi
done

# 결과 출력
echo ""
if [ $validation_errors -eq 0 ]; then
    echo "✅ 환경변수 검증 성공"
    echo "📊 검증된 변수 수: $(grep -v '^#' "$ENV_FILE" | grep -v '^$' | wc -l)"
    exit 0
else
    echo "❌ 환경변수 검증 실패: $validation_errors 개의 오류 발견"
    exit 1
fi