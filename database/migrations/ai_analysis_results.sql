-- AI Analysis Results Table Migration
-- Add this to your database schema or create as a separate migration

-- AI 분석 결과 테이블
CREATE TABLE ai_analysis_results (
    id BIGSERIAL PRIMARY KEY,
    report_id UUID NOT NULL,
    report_file_id UUID,    
    -- AI 서비스 정보
    ai_service VARCHAR(50) NOT NULL, -- ROBOFLOW, OPENROUTER, OPENAI, CUSTOM
    
    -- 분석 결과
    raw_response TEXT,              -- AI 서비스의 원본 응답 (JSON)
    parsed_result TEXT,             -- 파싱된 분석 결과 (JSON)
    status VARCHAR(20) NOT NULL,    -- PENDING, PROCESSING, COMPLETED, FAILED, RETRYING
    confidence_score DOUBLE PRECISION, -- 신뢰도 점수 (0.00 - 1.00) - DECIMAL에서 DOUBLE PRECISION으로 변경
    
    -- 오류 및 처리 정보
    error_message TEXT,             -- 실패 시 오류 메시지
    processing_time_ms BIGINT,      -- 처리 시간 (밀리초)
    retry_count INTEGER NOT NULL DEFAULT 0, -- 재시도 횟수
    
    -- 메타데이터
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- 외래 키 제약 조건
    FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE,
    FOREIGN KEY (report_file_id) REFERENCES report_files(id) ON DELETE CASCADE
);

-- 인덱스 생성
CREATE INDEX idx_ai_analysis_report_id ON ai_analysis_results(report_id);
CREATE INDEX idx_ai_analysis_file_id ON ai_analysis_results(report_file_id);
CREATE INDEX idx_ai_analysis_status ON ai_analysis_results(status);
CREATE INDEX idx_ai_analysis_service ON ai_analysis_results(ai_service);
CREATE INDEX idx_ai_analysis_created_at ON ai_analysis_results(created_at);
CREATE INDEX idx_ai_analysis_confidence ON ai_analysis_results(confidence_score);

-- 복합 인덱스
CREATE INDEX idx_ai_analysis_report_service ON ai_analysis_results(report_id, ai_service);
CREATE INDEX idx_ai_analysis_status_retry ON ai_analysis_results(status, retry_count);