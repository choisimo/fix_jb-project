#!/bin/bash

# =============================================================================
# 환경변수 로딩 유틸리티 함수
# =============================================================================

# 환경변수 파일 로딩 함수
load_env() {
    local env_file="${1:-.env}"
    
    if [ -f "$env_file" ]; then
        echo "📄 Loading environment variables from $env_file"
        
        # 주석과 빈 줄을 제외하고 환경변수 로드
        export $(cat "$env_file" | grep -v '^#' | grep -v '^$' | xargs)
        
        echo "✅ Environment variables loaded successfully"
        return 0
    else
        echo "❌ Environment file $env_file not found"
        return 1
    fi
}

# 환경별 환경변수 파일 로딩 함수
load_env_by_environment() {
    local environment="${1:-development}"
    
    case "$environment" in
        "development"|"dev")
            load_env ".env.dev"
            ;;
        "staging")
            load_env ".env.staging"
            ;;
        "production"|"prod")
            load_env ".env.prod"
            ;;
        *)
            # 기본적으로 .env 파일 로드
            load_env ".env"
            ;;
    esac
}

# 필수 환경변수 검증 함수
validate_required_vars() {
    local required_vars=("$@")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        echo "❌ Missing required environment variables:"
        for var in "${missing_vars[@]}"; do
            echo "   - $var"
        done
        echo ""
        echo "💡 Please set these variables in your environment file (.env, .env.dev, .env.staging, or .env.prod)"
        return 1
    else
        echo "✅ All required environment variables are set"
        return 0
    fi
}

# 환경변수 정보 출력 함수
print_env_info() {
    echo ""
    echo "🔧 Environment Configuration:"
    echo "   Environment: ${ENVIRONMENT:-not set}"
    echo "   Spring Profile: ${SPRING_PROFILES_ACTIVE:-not set}"
    echo "   Database URL: ${DATABASE_URL:-not set}"
    echo "   API Base URL: ${API_BASE_URL:-not set}"
    echo "   Log Level: ${LOG_LEVEL:-not set}"
    echo ""
}

# 도움말 함수
print_env_help() {
    echo ""
    echo "📚 Environment Management Help:"
    echo ""
    echo "Available environment files:"
    echo "   .env        - Default environment (currently development)"
    echo "   .env.dev    - Development environment"
    echo "   .env.staging - Staging environment"  
    echo "   .env.prod   - Production environment"
    echo ""
    echo "Usage examples:"
    echo "   load_env                    # Load default .env file"
    echo "   load_env .env.dev          # Load specific environment file"
    echo "   load_env_by_environment dev # Load by environment name"
    echo ""
    echo "To use in your scripts:"
    echo "   source scripts/env-utils.sh"
    echo "   load_env_by_environment \$ENVIRONMENT"
    echo ""
}

# 환경변수 파일 생성 함수 (백업용)
create_env_template() {
    local env_file="${1:-.env.template}"
    
    if [ -f "$env_file" ]; then
        echo "⚠️  $env_file already exists. Use --force to overwrite."
        return 1
    fi
    
    cat > "$env_file" << 'EOF'
# =============================================================================
# JB Report Platform - Environment Template
# =============================================================================

# Environment Configuration
ENVIRONMENT=development
SPRING_PROFILES_ACTIVE=dev

# Database Configuration
DATABASE_USERNAME=jbreport
DATABASE_PASSWORD=your_password_here
DATABASE_URL=jdbc:postgresql://localhost:5432/jbreport_prod

# Redis Configuration  
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=your_redis_password_here

# JWT Configuration
JWT_SECRET=your_jwt_secret_key_here
JWT_EXPIRATION=86400000
JWT_REFRESH_EXPIRATION=604800000

# Add other required environment variables...
EOF
    
    echo "✅ Environment template created: $env_file"
}

# 스크립트가 직접 실행된 경우 도움말 출력
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    print_env_help
fi