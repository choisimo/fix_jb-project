-- H2 Database Schema for Development
-- 개발용 H2 데이터베이스 스키마 (PostGIS 기능 제외)

-- 사용자 테이블
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255),
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(500),
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    
    -- OAuth 정보
    oauth_provider VARCHAR(50),
    oauth_id VARCHAR(255),
    
    -- 메타데이터
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 카테고리 테이블
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7),
    icon VARCHAR(50),
    parent_id INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (parent_id) REFERENCES categories(id)
);

-- 상태 테이블  
CREATE TABLE statuses (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7),
    priority INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 신고서 테이블
CREATE TABLE reports (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    
    -- 기본 정보
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    content TEXT,
    category_id INTEGER,
    status_id INTEGER,
    priority VARCHAR(20) DEFAULT 'MEDIUM',
    
    -- 위치 정보
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    address TEXT,
    
    -- AI 분석 정보
    ai_analysis_results TEXT, -- JSON as TEXT for H2
    ai_confidence_score DECIMAL(5, 2),
    is_complex_subject BOOLEAN DEFAULT false,
    primary_image_index INTEGER DEFAULT 0,
    
    -- 관리 정보
    manager_id VARCHAR(36),
    manager_notes TEXT,
    estimated_completion DATE,
    actual_completion DATE,
    workspace_id VARCHAR(100),
    assigned_department VARCHAR(100),
    
    -- 메타데이터
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (status_id) REFERENCES statuses(id),
    FOREIGN KEY (manager_id) REFERENCES users(id)
);

-- 파일 테이블
CREATE TABLE report_files (
    id VARCHAR(36) PRIMARY KEY,
    report_id VARCHAR(36) NOT NULL,
    
    -- 파일 정보
    original_filename VARCHAR(255) NOT NULL,
    stored_filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT NOT NULL,
    content_type VARCHAR(100) NOT NULL,
    file_hash VARCHAR(64), -- SHA-256 해시
    
    -- 이미지 메타데이터
    width INTEGER,
    height INTEGER,
    exif_data TEXT, -- JSON as TEXT
    
    -- AI 분석 정보
    ai_analysis_results TEXT, -- JSON as TEXT
    ai_confidence_score DECIMAL(5, 2),
    
    -- 메타데이터
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE
);

-- 댓글 테이블
CREATE TABLE comments (
    id VARCHAR(36) PRIMARY KEY,
    report_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    
    -- 댓글 정보
    content TEXT NOT NULL,
    parent_id VARCHAR(36), -- 대댓글을 위한 부모 댓글 ID
    
    -- 메타데이터
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    
    FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (parent_id) REFERENCES comments(id)
);

-- 알림 테이블
CREATE TABLE notifications (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    report_id VARCHAR(36),
    
    -- 알림 정보
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL, -- REPORT_STATUS_CHANGED, COMMENT_ADDED, etc.
    
    -- 상태
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP,
    
    -- 메타데이터
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (report_id) REFERENCES reports(id)
);

-- 사용자 세션 테이블
CREATE TABLE user_sessions (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    
    -- 세션 정보
    session_token VARCHAR(255) UNIQUE NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    
    -- 유효성
    expires_at TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT true,
    
    -- 메타데이터
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 신고서 상태 이력 테이블
CREATE TABLE report_status_histories (
    id VARCHAR(36) PRIMARY KEY,
    report_id VARCHAR(36) NOT NULL,
    changed_by_user_id VARCHAR(36) NOT NULL,
    
    -- 상태 변경 정보
    previous_status VARCHAR(20),
    new_status VARCHAR(20) NOT NULL,
    reason TEXT,
    
    -- 메타데이터
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (report_id) REFERENCES reports(id),
    FOREIGN KEY (changed_by_user_id) REFERENCES users(id)
);

-- 인덱스 생성
CREATE INDEX idx_reports_user_id ON reports(user_id);
CREATE INDEX idx_reports_category_id ON reports(category_id);
CREATE INDEX idx_reports_status_id ON reports(status_id);
CREATE INDEX idx_reports_created_at ON reports(created_at);
CREATE INDEX idx_reports_location ON reports(latitude, longitude);

CREATE INDEX idx_report_files_report_id ON report_files(report_id);
CREATE INDEX idx_comments_report_id ON comments(report_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

-- AI 분석 결과 테이블
CREATE TABLE ai_analysis_results (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    report_id VARCHAR(36) NOT NULL,
    report_file_id VARCHAR(36),
    
    -- AI 서비스 정보
    ai_service VARCHAR(50) NOT NULL, -- ROBOFLOW, OPENROUTER, OPENAI, CUSTOM
    
    -- 분석 결과
    raw_response TEXT,              -- AI 서비스의 원본 응답 (JSON)
    parsed_result TEXT,             -- 파싱된 분석 결과 (JSON)
    status VARCHAR(20) NOT NULL,    -- PENDING, PROCESSING, COMPLETED, FAILED, RETRYING
    confidence_score DECIMAL(5, 2), -- 신뢰도 점수 (0.00 - 1.00)
    
    -- 오류 및 처리 정보
    error_message TEXT,             -- 실패 시 오류 메시지
    processing_time_ms BIGINT,      -- 처리 시간 (밀리초)
    retry_count INTEGER NOT NULL DEFAULT 0, -- 재시도 횟수
    
    -- 메타데이터
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- 외래 키 제약 조건
    FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE,
    FOREIGN KEY (report_file_id) REFERENCES report_files(id) ON DELETE CASCADE
);

-- AI 분석 결과 인덱스
CREATE INDEX idx_ai_analysis_report_id ON ai_analysis_results(report_id);
CREATE INDEX idx_ai_analysis_file_id ON ai_analysis_results(report_file_id);
CREATE INDEX idx_ai_analysis_status ON ai_analysis_results(status);
CREATE INDEX idx_ai_analysis_service ON ai_analysis_results(ai_service);
CREATE INDEX idx_ai_analysis_created_at ON ai_analysis_results(created_at);
CREATE INDEX idx_ai_analysis_confidence ON ai_analysis_results(confidence_score);
CREATE INDEX idx_ai_analysis_report_service ON ai_analysis_results(report_id, ai_service);
CREATE INDEX idx_ai_analysis_status_retry ON ai_analysis_results(status, retry_count);

-- 알림/경고 테이블 (notifications와는 별도의 더 긴급한 알림 시스템)
CREATE TABLE alerts (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    report_id VARCHAR(36),
    
    -- 알림 정보
    type VARCHAR(50) NOT NULL, -- CRITICAL, HIGH_PRIORITY, SYSTEM_ERROR, SECURITY_BREACH, etc.
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL, -- JSON으로 구조화된 알림 데이터
    severity VARCHAR(20) NOT NULL DEFAULT 'MEDIUM', -- LOW, MEDIUM, HIGH, CRITICAL
    
    -- 상태 및 처리 정보
    is_read BOOLEAN DEFAULT false,
    is_resolved BOOLEAN DEFAULT false,
    read_at TIMESTAMP,
    resolved_at TIMESTAMP,
    resolved_by_user_id VARCHAR(36),
    
    -- 메타데이터
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP, -- 알림 만료 시간 (자동 삭제)
    
    -- 외래 키 제약 조건
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE SET NULL,
    FOREIGN KEY (resolved_by_user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 알림 인덱스
CREATE INDEX idx_alerts_user_id ON alerts(user_id);
CREATE INDEX idx_alerts_report_id ON alerts(report_id);
CREATE INDEX idx_alerts_type ON alerts(type);
CREATE INDEX idx_alerts_severity ON alerts(severity);
CREATE INDEX idx_alerts_is_read ON alerts(is_read);
CREATE INDEX idx_alerts_is_resolved ON alerts(is_resolved);
CREATE INDEX idx_alerts_created_at ON alerts(created_at);
CREATE INDEX idx_alerts_expires_at ON alerts(expires_at);
CREATE INDEX idx_alerts_user_unread ON alerts(user_id, is_read, created_at);
CREATE INDEX idx_alerts_user_severity ON alerts(user_id, severity, created_at);