-- 인증 관련 테이블 추가

-- 휴대폰/이메일 인증 이력 테이블
CREATE TABLE verification_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(20) NOT NULL CHECK (type IN ('sms', 'email')), -- 인증 유형
    target VARCHAR(255) NOT NULL, -- 휴대폰 번호 또는 이메일
    code VARCHAR(10) NOT NULL, -- 인증번호
    verified BOOLEAN DEFAULT false, -- 인증 완료 여부
    verified_at TIMESTAMP WITH TIME ZONE, -- 인증 완료 시간
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL, -- 만료 시간
    ip_address INET, -- 요청 IP
    user_agent TEXT, -- 사용자 에이전트
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 실명인증 이력 테이블
CREATE TABLE identity_verifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    request_token VARCHAR(255) UNIQUE NOT NULL, -- 인증 요청 토큰
    provider VARCHAR(50) NOT NULL, -- 'nice', 'kcb', 'pass' 등
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'expired')),
    
    -- 인증 결과 데이터
    verified_name VARCHAR(100), -- 인증된 실명
    verified_birthday VARCHAR(8), -- 생년월일 (YYYYMMDD)
    verified_gender VARCHAR(1), -- 성별 (1: 남, 2: 여)
    verified_phone VARCHAR(20), -- 인증된 휴대폰 번호
    carrier VARCHAR(20), -- 통신사
    
    -- 고유 식별값 (개인정보 보호를 위해 해시화)
    ci_hash VARCHAR(64), -- 개인식별정보 해시
    di_hash VARCHAR(64), -- 중복가입확인정보 해시
    
    -- 메타데이터
    ip_address INET, -- 요청 IP
    user_agent TEXT, -- 사용자 에이전트
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMP WITH TIME ZONE, -- 인증 완료 시간
    expires_at TIMESTAMP WITH TIME ZONE -- 요청 만료 시간
);

-- 사용자 테이블에 인증 관련 필드 추가
ALTER TABLE users ADD COLUMN phone_verified BOOLEAN DEFAULT false;
ALTER TABLE users ADD COLUMN phone_verified_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN identity_verified BOOLEAN DEFAULT false;
ALTER TABLE users ADD COLUMN identity_verified_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN identity_verification_id UUID REFERENCES identity_verifications(id);

-- 인덱스 생성
CREATE INDEX idx_verification_logs_target ON verification_logs(target);
CREATE INDEX idx_verification_logs_type ON verification_logs(type);
CREATE INDEX idx_verification_logs_created_at ON verification_logs(created_at);
CREATE INDEX idx_verification_logs_verified ON verification_logs(verified);

CREATE INDEX idx_identity_verifications_user_id ON identity_verifications(user_id);
CREATE INDEX idx_identity_verifications_token ON identity_verifications(request_token);
CREATE INDEX idx_identity_verifications_status ON identity_verifications(status);
CREATE INDEX idx_identity_verifications_provider ON identity_verifications(provider);
CREATE INDEX idx_identity_verifications_ci_hash ON identity_verifications(ci_hash);
CREATE INDEX idx_identity_verifications_di_hash ON identity_verifications(di_hash);

-- 사용자 테이블 인증 관련 인덱스
CREATE INDEX idx_users_phone_verified ON users(phone_verified);
CREATE INDEX idx_users_identity_verified ON users(identity_verified);

-- 중복 가입 방지 제약조건 (동일한 CI로는 하나의 계정만 생성 가능)
CREATE UNIQUE INDEX idx_identity_verifications_unique_ci 
ON identity_verifications(ci_hash) 
WHERE status = 'completed' AND ci_hash IS NOT NULL;