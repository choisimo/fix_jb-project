-- 전북 신고 플랫폼 데이터베이스 스키마
-- PostgreSQL 데이터베이스 스키마 정의

-- 확장 모듈 활성화
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- 사용자 테이블
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255), -- NULL for OAuth users
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    department VARCHAR(100),
    role VARCHAR(20) NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'manager', 'admin')),
    
    -- OAuth 정보
    oauth_provider VARCHAR(50), -- 'google', 'kakao', 'naver' 등
    oauth_id VARCHAR(255),
    oauth_email VARCHAR(255),
    
    -- 메타데이터
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- OAuth 사용자의 경우 password_hash가 NULL일 수 있음
    CONSTRAINT oauth_user_check CHECK (
        (oauth_provider IS NOT NULL AND oauth_id IS NOT NULL) OR 
        (password_hash IS NOT NULL)
    )
);

-- 카테고리 테이블
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7), -- HEX 색상 코드
    icon VARCHAR(50), -- 아이콘 이름
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 상태 테이블
CREATE TABLE statuses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7), -- HEX 색상 코드
    is_terminal BOOLEAN DEFAULT false, -- 최종 상태 여부
    order_index INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 신고서 테이블
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- 기본 정보
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(id),
    status_id INTEGER REFERENCES statuses(id),
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    
    -- 위치 정보
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    address TEXT,
    location_point GEOMETRY(POINT, 4326), -- PostGIS 포인트
    
    -- AI 분석 정보
    ai_analysis_results JSONB, -- AI 분석 결과 저장
    ai_confidence_score DECIMAL(5, 2), -- 0.00 ~ 100.00
    is_complex_subject BOOLEAN DEFAULT false, -- 복합적 주제 여부
    primary_image_index INTEGER DEFAULT 0, -- 대표 이미지 인덱스
    
    -- 관리 정보
    manager_id UUID REFERENCES users(id), -- 담당 관리자
    manager_notes TEXT, -- 관리자 메모
    estimated_completion DATE, -- 예상 완료일
    actual_completion DATE, -- 실제 완료일
    
    -- 서명 및 인증
    signature_data TEXT, -- Base64 인코딩된 서명 이미지
    device_info JSONB, -- 디바이스 정보 (앱 버전, OS 등)
    
    -- 메타데이터
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE, -- 소프트 삭제
    
    -- 인덱스를 위한 제약조건
    CONSTRAINT valid_coordinates CHECK (
        (latitude IS NULL AND longitude IS NULL) OR 
        (latitude IS NOT NULL AND longitude IS NOT NULL)
    )
);

-- 신고서 파일 테이블
CREATE TABLE report_files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
    
    -- 파일 정보
    original_filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL, -- 실제 저장 경로
    file_url VARCHAR(500), -- 접근 가능한 URL
    file_size BIGINT NOT NULL, -- 바이트 단위
    file_type VARCHAR(50) NOT NULL, -- MIME 타입
    file_hash VARCHAR(64), -- SHA-256 해시 (중복 검사용)
    
    -- 이미지 메타데이터
    image_width INTEGER,
    image_height INTEGER,
    exif_data JSONB, -- EXIF 정보
    
    -- 썸네일 정보
    thumbnail_path VARCHAR(500),
    thumbnail_url VARCHAR(500),
    
    -- 순서 및 분류
    file_order INTEGER DEFAULT 0, -- 파일 순서
    is_primary BOOLEAN DEFAULT false, -- 대표 이미지 여부
    tags VARCHAR(200)[], -- 태그 배열
    
    -- 메타데이터
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE -- 소프트 삭제
);

-- 댓글 테이블
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES comments(id), -- 대댓글 지원
    
    -- 댓글 내용
    content TEXT NOT NULL,
    is_internal BOOLEAN DEFAULT false, -- 내부 댓글 여부 (관리자만 볼 수 있음)
    is_system BOOLEAN DEFAULT false, -- 시스템 자동 생성 댓글
    
    -- 첨부파일
    attachment_path VARCHAR(500),
    attachment_url VARCHAR(500),
    
    -- 메타데이터
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE -- 소프트 삭제
);

-- 신고서 상태 변경 이력 테이블
CREATE TABLE report_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
    from_status_id INTEGER REFERENCES statuses(id),
    to_status_id INTEGER NOT NULL REFERENCES statuses(id),
    changed_by UUID NOT NULL REFERENCES users(id),
    reason TEXT,
    notes TEXT,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 사용자 세션 테이블 (JWT 토큰 관리)
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(64) NOT NULL, -- JWT 토큰의 해시
    device_info JSONB,
    ip_address INET,
    user_agent TEXT,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_revoked BOOLEAN DEFAULT false
);

-- 알림 테이블
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    report_id UUID REFERENCES reports(id) ON DELETE CASCADE,
    
    -- 알림 내용
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL, -- 'status_update', 'comment', 'assignment' 등
    data JSONB, -- 추가 데이터
    
    -- 상태
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    
    -- 메타데이터
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE
);

-- 시스템 설정 테이블
CREATE TABLE system_settings (
    key VARCHAR(100) PRIMARY KEY,
    value TEXT NOT NULL,
    description TEXT,
    data_type VARCHAR(20) DEFAULT 'string' CHECK (data_type IN ('string', 'number', 'boolean', 'json')),
    is_public BOOLEAN DEFAULT false, -- 클라이언트에서 접근 가능한지 여부
    updated_by UUID REFERENCES users(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_oauth ON users(oauth_provider, oauth_id);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(is_active);

CREATE INDEX idx_reports_user_id ON reports(user_id);
CREATE INDEX idx_reports_category ON reports(category_id);
CREATE INDEX idx_reports_status ON reports(status_id);
CREATE INDEX idx_reports_priority ON reports(priority);
CREATE INDEX idx_reports_location ON reports USING GIST(location_point);
CREATE INDEX idx_reports_created_at ON reports(created_at);
CREATE INDEX idx_reports_updated_at ON reports(updated_at);
CREATE INDEX idx_reports_manager ON reports(manager_id);
CREATE INDEX idx_reports_complex_subject ON reports(is_complex_subject);
CREATE INDEX idx_reports_soft_delete ON reports(deleted_at) WHERE deleted_at IS NULL;

CREATE INDEX idx_report_files_report_id ON report_files(report_id);
CREATE INDEX idx_report_files_type ON report_files(file_type);
CREATE INDEX idx_report_files_primary ON report_files(is_primary);
CREATE INDEX idx_report_files_order ON report_files(file_order);
CREATE INDEX idx_report_files_hash ON report_files(file_hash);
CREATE INDEX idx_report_files_soft_delete ON report_files(deleted_at) WHERE deleted_at IS NULL;

CREATE INDEX idx_comments_report_id ON comments(report_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_comments_parent_id ON comments(parent_id);
CREATE INDEX idx_comments_created_at ON comments(created_at);
CREATE INDEX idx_comments_internal ON comments(is_internal);
CREATE INDEX idx_comments_soft_delete ON comments(deleted_at) WHERE deleted_at IS NULL;

CREATE INDEX idx_status_history_report_id ON report_status_history(report_id);
CREATE INDEX idx_status_history_changed_at ON report_status_history(changed_at);
CREATE INDEX idx_status_history_changed_by ON report_status_history(changed_by);

CREATE INDEX idx_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_sessions_token_hash ON user_sessions(token_hash);
CREATE INDEX idx_sessions_expires_at ON user_sessions(expires_at);
CREATE INDEX idx_sessions_active ON user_sessions(is_revoked, expires_at);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_report_id ON notifications(report_id);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = false;
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

-- 트리거 함수: updated_at 자동 업데이트
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 트리거 생성
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reports_updated_at BEFORE UPDATE ON reports
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 위치 정보 업데이트 트리거
CREATE OR REPLACE FUNCTION update_location_point()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
        NEW.location_point = ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326);
    ELSE
        NEW.location_point = NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_reports_location_point 
    BEFORE INSERT OR UPDATE ON reports
    FOR EACH ROW EXECUTE FUNCTION update_location_point();

-- 신고서 상태 변경 이력 자동 기록 트리거
CREATE OR REPLACE FUNCTION record_status_change()
RETURNS TRIGGER AS $$
BEGIN
    -- 상태가 변경된 경우에만 기록
    IF OLD.status_id IS DISTINCT FROM NEW.status_id THEN
        INSERT INTO report_status_history (
            report_id, 
            from_status_id, 
            to_status_id, 
            changed_by,
            reason
        ) VALUES (
            NEW.id,
            OLD.status_id,
            NEW.status_id,
            NEW.user_id, -- 실제로는 현재 사용자 ID를 별도로 전달받아야 함
            'Status updated'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER record_report_status_change
    AFTER UPDATE ON reports
    FOR EACH ROW EXECUTE FUNCTION record_status_change();
