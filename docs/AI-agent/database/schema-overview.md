# 데이터베이스 스키마 전체 개요

## 🎯 데이터베이스 아키텍처 개요

전북 신고 플랫폼의 데이터베이스는 **PostgreSQL 15.x**를 기반으로 하며, **PostGIS 확장**을 통해 지리공간 데이터를 효율적으로 처리합니다. **정규화된 관계형 설계**와 **NoSQL 요소(JSONB)**를 결합하여 확장성과 성능을 동시에 확보했습니다.

## 📊 스키마 구조 다이어그램

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Core User Management                               │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         │
│  │     users       │    │ user_sessions   │    │  categories     │         │
│  │                 │    │                 │    │                 │         │
│  │ • id (UUID)     │◄──┤ • user_id       │    │ • id (SERIAL)   │         │
│  │ • email         │    │ • token_hash    │    │ • name          │         │
│  │ • password_hash │    │ • expires_at    │    │ • description   │         │
│  │ • role          │    │ • device_info   │    │ • color         │         │
│  │ • oauth_*       │    └─────────────────┘    │ • is_active     │         │
│  └─────────────────┘                           └─────────────────┘         │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
┌─────────────────────────────────────────────────────────────────────────────┐
│                            Report Management                                │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         │
│  │    reports      │    │  report_files   │    │    comments     │         │
│  │                 │    │                 │    │                 │         │
│  │ • id (UUID)     │◄──┤ • report_id     │    │ • id (UUID)     │         │
│  │ • user_id       │    │ • file_path     │    │ • report_id     │◄────────┤
│  │ • title         │    │ • file_type     │    │ • user_id       │         │
│  │ • description   │    │ • file_size     │    │ • content       │         │
│  │ • category_id   │    │ • image_width   │    │ • parent_id     │         │
│  │ • status_id     │    │ • image_height  │    │ • is_internal   │         │
│  │ • priority      │    │ • is_primary    │    └─────────────────┘         │
│  │ • latitude      │    └─────────────────┘                                │
│  │ • longitude     │                                                       │
│  │ • location_point│                                                       │
│  │ • ai_analysis_* │                                                       │
│  │ • manager_id    │                                                       │
│  └─────────────────┘                                                       │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Workflow & Audit Trail                              │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         │
│  │    statuses     │    │report_status_   │    │ notifications   │         │
│  │                 │    │   history       │    │                 │         │
│  │ • id (SERIAL)   │    │ • id (UUID)     │    │ • id (UUID)     │         │
│  │ • name          │    │ • report_id     │    │ • user_id       │         │
│  │ • description   │    │ • from_status   │    │ • report_id     │         │
│  │ • color         │    │ • to_status     │    │ • title         │         │
│  │ • is_terminal   │    │ • changed_by    │    │ • message       │         │
│  │ • order_index   │    │ • reason        │    │ • type          │         │
│  └─────────────────┘    │ • changed_at    │    │ • is_read       │         │
│                         └─────────────────┘    └─────────────────┘         │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
┌─────────────────────────────────────────────────────────────────────────────┐
│                         System Configuration                                │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                        system_settings                                 ││
│  │                                                                         ││
│  │ • key (VARCHAR) PK          • value (TEXT)                            ││
│  │ • description (TEXT)        • data_type (ENUM)                        ││
│  │ • is_public (BOOLEAN)       • updated_by (UUID)                       ││
│  │ • updated_at (TIMESTAMP)                                               ││
│  └─────────────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🗃️ 핵심 테이블 상세 정보

### 1. users (사용자)
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255), -- NULL for OAuth users
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    department VARCHAR(100),
    role VARCHAR(20) NOT NULL DEFAULT 'user' 
        CHECK (role IN ('user', 'manager', 'admin')),
    
    -- OAuth 정보
    oauth_provider VARCHAR(50), -- 'google', 'kakao', 'naver'
    oauth_id VARCHAR(255),
    oauth_email VARCHAR(255),
    
    -- 메타데이터
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- 제약조건: OAuth 또는 일반 로그인 중 하나는 반드시 있어야 함
    CONSTRAINT oauth_user_check CHECK (
        (oauth_provider IS NOT NULL AND oauth_id IS NOT NULL) OR 
        (password_hash IS NOT NULL)
    )
);
```

**비즈니스 규칙:**
- 이메일은 전체 시스템에서 유일해야 함
- OAuth 사용자는 password_hash가 NULL일 수 있음
- role은 3단계 권한 체계: user → manager → admin
- soft delete 미적용 (사용자는 is_active로 관리)

### 2. reports (신고서)
```sql
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- 기본 정보
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(id),
    status_id INTEGER REFERENCES statuses(id),
    priority VARCHAR(20) DEFAULT 'medium' 
        CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    
    -- 위치 정보 (PostGIS 활용)
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    address TEXT,
    location_point GEOMETRY(POINT, 4326), -- PostGIS 포인트
    
    -- AI 분석 정보 (JSONB 활용)
    ai_analysis_results JSONB,
    ai_confidence_score DECIMAL(5, 2), -- 0.00 ~ 100.00
    is_complex_subject BOOLEAN DEFAULT false,
    primary_image_index INTEGER DEFAULT 0,
    
    -- 관리 정보
    manager_id UUID REFERENCES users(id),
    manager_notes TEXT,
    estimated_completion DATE,
    actual_completion DATE,
    
    -- 서명 및 인증
    signature_data TEXT, -- Base64 인코딩된 서명 이미지
    device_info JSONB,
    
    -- 메타데이터
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE, -- Soft delete
    
    -- 위치 좌표 유효성 검증
    CONSTRAINT valid_coordinates CHECK (
        (latitude IS NULL AND longitude IS NULL) OR 
        (latitude IS NOT NULL AND longitude IS NOT NULL)
    )
);
```

**비즈니스 규칙:**
- 신고는 반드시 작성자(user_id)와 연결
- 위치 정보는 latitude/longitude 쌍으로 존재하거나 둘 다 NULL
- location_point는 트리거를 통해 자동 생성
- AI 분석 결과는 JSONB로 저장하여 유연성 확보
- soft delete 적용으로 데이터 보존

### 3. report_files (신고 첨부파일)
```sql
CREATE TABLE report_files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
    
    -- 파일 정보
    original_filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_url VARCHAR(500),
    file_size BIGINT NOT NULL,
    file_type VARCHAR(50) NOT NULL, -- MIME 타입
    file_hash VARCHAR(64), -- SHA-256 해시
    
    -- 이미지 메타데이터
    image_width INTEGER,
    image_height INTEGER,
    exif_data JSONB,
    
    -- 썸네일 정보
    thumbnail_path VARCHAR(500),
    thumbnail_url VARCHAR(500),
    
    -- 순서 및 분류
    file_order INTEGER DEFAULT 0,
    is_primary BOOLEAN DEFAULT false, -- 대표 이미지
    tags VARCHAR(200)[], -- PostgreSQL 배열 타입
    
    -- 메타데이터
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE -- Soft delete
);
```

**비즈니스 규칙:**
- 하나의 신고당 최대 10개 파일 첨부 가능
- file_hash를 통한 중복 파일 감지
- is_primary는 신고당 하나만 true
- 이미지 파일은 자동으로 썸네일 생성
- 배열 타입을 활용한 태그 시스템

### 4. categories (카테고리)
```sql
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7), -- HEX 색상 코드 (#FF5733)
    icon VARCHAR(50), -- 아이콘 이름 (Material Icons)
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

**전북지역 특화 카테고리:**
```sql
INSERT INTO categories (name, description, color, icon) VALUES
('도로관리', '도로 파손, 포트홀, 균열 등', '#FF5722', 'road'),
('시설관리', '가로등, 표지판, 벤치 등 공공시설', '#2196F3', 'build'),
('환경관리', '쓰레기, 불법투기, 낙서 등', '#4CAF50', 'eco'),
('안전관리', '가드레일, 안전시설 파손 등', '#F44336', 'security'),
('교통관리', '신호등, 교통표지, 버스정류장 등', '#FF9800', 'traffic');
```

### 5. system_settings (시스템 설정)
```sql
CREATE TABLE system_settings (
    key VARCHAR(100) PRIMARY KEY,
    value TEXT NOT NULL,
    description TEXT,
    data_type VARCHAR(20) DEFAULT 'string' 
        CHECK (data_type IN ('string', 'number', 'boolean', 'json')),
    is_public BOOLEAN DEFAULT false, -- 클라이언트 접근 가능 여부
    updated_by UUID REFERENCES users(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

**시스템 설정 예시:**
```sql
INSERT INTO system_settings (key, value, description, data_type, is_public) VALUES
('roboflow.api.key', 'encrypted_api_key', 'Roboflow API 키', 'string', false),
('roboflow.confidence.threshold', '0.7', '객체 감지 신뢰도 임계값', 'number', true),
('system.maintenance.mode', 'false', '시스템 점검 모드', 'boolean', true),
('ui.theme.colors', '{"primary":"#1976D2","secondary":"#424242"}', 'UI 테마 색상', 'json', true);
```

## 🔍 인덱스 전략

### 성능 최적화 인덱스
```sql
-- 사용자 검색 최적화
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_oauth ON users(oauth_provider, oauth_id);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(is_active);

-- 신고 검색 최적화
CREATE INDEX idx_reports_user_id ON reports(user_id);
CREATE INDEX idx_reports_category ON reports(category_id);
CREATE INDEX idx_reports_status ON reports(status_id);
CREATE INDEX idx_reports_priority ON reports(priority);
CREATE INDEX idx_reports_created_at ON reports(created_at);
CREATE INDEX idx_reports_manager ON reports(manager_id);

-- 지리공간 검색 최적화 (PostGIS)
CREATE INDEX idx_reports_location ON reports USING GIST(location_point);

-- Soft delete 최적화
CREATE INDEX idx_reports_soft_delete ON reports(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_report_files_soft_delete ON report_files(deleted_at) WHERE deleted_at IS NULL;

-- 복합 인덱스 (자주 함께 사용되는 컬럼)
CREATE INDEX idx_reports_status_priority ON reports(status_id, priority);
CREATE INDEX idx_reports_user_created ON reports(user_id, created_at);
```

### 전문 검색 인덱스 (Full-text Search)
```sql
-- 텍스트 검색을 위한 GIN 인덱스
CREATE INDEX idx_reports_fulltext ON reports 
USING GIN(to_tsvector('korean', title || ' ' || description));

-- 사용 예시
SELECT * FROM reports 
WHERE to_tsvector('korean', title || ' ' || description) 
      @@ plainto_tsquery('korean', '도로 파손');
```

## 🔧 트리거 및 자동화

### 1. 자동 타임스탬프 업데이트
```sql
-- 트리거 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 트리거 적용
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reports_updated_at 
    BEFORE UPDATE ON reports
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### 2. 지리공간 데이터 자동 생성
```sql
-- 위치 포인트 자동 생성 트리거
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
```

### 3. 상태 변경 이력 자동 기록
```sql
-- 상태 변경 이력 자동 기록
CREATE OR REPLACE FUNCTION record_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status_id IS DISTINCT FROM NEW.status_id THEN
        INSERT INTO report_status_history (
            report_id, from_status_id, to_status_id, 
            changed_by, reason
        ) VALUES (
            NEW.id, OLD.status_id, NEW.status_id,
            NEW.manager_id, 'Status updated automatically'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER record_report_status_change
    AFTER UPDATE ON reports
    FOR EACH ROW EXECUTE FUNCTION record_status_change();
```

## 📊 데이터 타입 및 제약조건

### PostgreSQL 고급 타입 활용
```sql
-- JSONB 타입 (AI 분석 결과)
ai_analysis_results JSONB
-- 예시 데이터:
{
  "model_id": "pothole-detection-v1",
  "detections": [
    {
      "class": "pothole",
      "confidence": 0.85,
      "bbox": {"x": 320, "y": 240, "width": 150, "height": 100}
    }
  ],
  "processing_time": 1.23,
  "timestamp": "2025-07-12T14:30:00Z"
}

-- 배열 타입 (태그)
tags VARCHAR(200)[]
-- 예시: {"도로", "포트홀", "긴급"}

-- 지리공간 타입 (PostGIS)
location_point GEOMETRY(POINT, 4326)
-- SRID 4326 (WGS84) 좌표계 사용

-- ENUM 타입
CREATE TYPE report_priority AS ENUM ('low', 'medium', 'high', 'urgent');
CREATE TYPE user_role AS ENUM ('user', 'manager', 'admin');
```

### 체크 제약조건
```sql
-- 우선순위 제약
CONSTRAINT valid_priority CHECK (priority IN ('low', 'medium', 'high', 'urgent'))

-- 좌표 유효성 제약
CONSTRAINT valid_coordinates CHECK (
    (latitude IS NULL AND longitude IS NULL) OR 
    (latitude IS NOT NULL AND longitude IS NOT NULL AND
     latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180)
)

-- 신뢰도 점수 제약
CONSTRAINT valid_confidence CHECK (ai_confidence_score BETWEEN 0 AND 100)

-- 파일 크기 제약
CONSTRAINT valid_file_size CHECK (file_size > 0 AND file_size <= 52428800) -- 50MB
```

## 🗄️ 파티셔닝 전략

### 시간 기반 파티셔닝 (대량 데이터 대비)
```sql
-- 신고 테이블 월별 파티셔닝 (향후 적용 예정)
CREATE TABLE reports_2025_01 PARTITION OF reports
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE reports_2025_02 PARTITION OF reports
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

-- 알림 테이블 주별 파티셔닝
CREATE TABLE notifications_y2025w01 PARTITION OF notifications
    FOR VALUES FROM ('2025-01-01') TO ('2025-01-08');
```

## 🔐 보안 및 권한 관리

### 행 수준 보안 (Row Level Security)
```sql
-- 사용자별 데이터 접근 제어
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- 정책: 사용자는 자신의 신고만 조회 가능
CREATE POLICY reports_user_policy ON reports
    FOR ALL TO app_user
    USING (user_id = current_setting('app.current_user_id')::UUID);

-- 정책: 관리자는 모든 신고 조회 가능
CREATE POLICY reports_admin_policy ON reports
    FOR ALL TO app_admin
    USING (true);
```

### 데이터 암호화
```sql
-- 민감 정보 암호화 (pgcrypto 확장 사용)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- API 키 암호화 저장
UPDATE system_settings 
SET value = crypt(value, gen_salt('bf', 8)) 
WHERE key LIKE '%.api.key';
```

---

*문서 버전: 1.0*  
*최종 업데이트: 2025년 7월 12일*  
*작성자: 데이터베이스 아키텍트 팀*