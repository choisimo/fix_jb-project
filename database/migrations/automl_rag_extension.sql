-- Google AutoML Vision + RAG 시스템을 위한 데이터베이스 스키마 확장

-- PostgreSQL pgvector 확장 활성화 (벡터 검색용)
CREATE EXTENSION IF NOT EXISTS vector;

-- AutoML Vision 모델 관리 테이블
CREATE TABLE automl_models (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    model_id VARCHAR(255) NOT NULL UNIQUE, -- Google Cloud AutoML 모델 ID
    model_name VARCHAR(255) NOT NULL,
    model_type VARCHAR(50) NOT NULL CHECK (model_type IN ('CLASSIFICATION', 'OBJECT_DETECTION')),
    project_id VARCHAR(255) NOT NULL,
    location VARCHAR(100) NOT NULL DEFAULT 'us-central1',
    
    -- 모델 설정
    confidence_threshold FLOAT DEFAULT 0.7,
    max_predictions INTEGER DEFAULT 10,
    
    -- 모델 상태
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('TRAINING', 'ACTIVE', 'INACTIVE', 'DELETED')),
    
    -- 성능 지표
    accuracy FLOAT,
    precision_score FLOAT,
    recall_score FLOAT,
    f1_score FLOAT,
    
    -- 메타데이터
    description TEXT,
    tags JSONB,
    training_data_count INTEGER,
    
    -- 시간 정보
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP WITH TIME ZONE
);

-- AutoML Vision 분석 결과 테이블 (기존 ai_analysis_results 확장)
CREATE TABLE automl_analysis_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID REFERENCES reports(id) ON DELETE CASCADE,
    model_id UUID REFERENCES automl_models(id),
    
    -- 분석 결과
    analysis_type VARCHAR(20) NOT NULL CHECK (analysis_type IN ('CLASSIFICATION', 'OBJECT_DETECTION', 'HYBRID')),
    predictions JSONB NOT NULL, -- ClassificationPrediction[] or ObjectDetectionPrediction[]
    top_prediction JSONB, -- 최고 신뢰도 예측
    
    -- 성능 정보
    confidence FLOAT NOT NULL,
    processing_time_ms BIGINT,
    model_version VARCHAR(50),
    
    -- 메타데이터
    image_metadata JSONB, -- 이미지 크기, 형식 등
    analysis_metadata JSONB, -- 추가 분석 정보
    
    -- 상태
    status VARCHAR(20) DEFAULT 'SUCCESS' CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED')),
    error_message TEXT,
    
    -- 시간 정보
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 문서 벡터 저장 테이블 (RAG 시스템용)
CREATE TABLE document_vectors (
    id BIGSERIAL PRIMARY KEY,
    document_id VARCHAR(255) NOT NULL, -- 원본 문서 식별자
    content_type VARCHAR(50) NOT NULL, -- AI_ANALYSIS, REPORT, KNOWLEDGE_BASE, MANUAL, FAQ
    
    -- 텍스트 청크 정보
    chunk_text TEXT NOT NULL,
    chunk_index INTEGER NOT NULL DEFAULT 0,
    chunk_length INTEGER GENERATED ALWAYS AS (length(chunk_text)) STORED,
    
    -- 벡터 임베딩 (1536차원, OpenAI text-embedding-ada-002 기준)
    embedding vector(1536) NOT NULL,
    
    -- 메타데이터
    metadata JSONB,
    
    -- 검색 최적화를 위한 전문 검색 벡터
    search_vector tsvector GENERATED ALWAYS AS (to_tsvector('korean', chunk_text)) STORED,
    
    -- 시간 정보
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- RAG 분석 결과 테이블
CREATE TABLE rag_analysis_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID REFERENCES reports(id) ON DELETE CASCADE,
    
    -- 원본 요청
    original_query TEXT NOT NULL,
    
    -- 분석 결과
    original_analysis_id UUID REFERENCES automl_analysis_results(id),
    enhanced_analysis TEXT NOT NULL,
    
    -- 컨텍스트 정보
    context_sources JSONB, -- DocumentChunk[] 참조 정보
    context_source_count INTEGER DEFAULT 0,
    
    -- 성능 지표
    confidence FLOAT,
    processing_time_ms BIGINT,
    improvement_ratio FLOAT, -- 원본 대비 향상도
    
    -- 메타데이터
    metadata JSONB,
    
    -- 상태
    status VARCHAR(20) DEFAULT 'SUCCESS' CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED')),
    error_message TEXT,
    
    -- 시간 정보
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- RAG 질의응답 로그 테이블
CREATE TABLE rag_qa_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- 질의응답 정보
    question TEXT NOT NULL,
    answer TEXT,
    context_query TEXT, -- 실제 검색에 사용된 쿼리
    
    -- 검색 결과
    context_sources JSONB, -- 참조된 문서 청크들
    context_source_count INTEGER DEFAULT 0,
    
    -- 성능 지표
    confidence FLOAT,
    processing_time_ms BIGINT,
    search_time_ms BIGINT,
    generation_time_ms BIGINT,
    
    -- 사용자 정보
    user_id UUID REFERENCES users(id),
    session_id VARCHAR(255),
    
    -- 피드백
    user_rating INTEGER CHECK (user_rating BETWEEN 1 AND 5),
    user_feedback TEXT,
    
    -- 시간 정보
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 성능 최적화를 위한 인덱스 생성

-- AutoML 모델 관련 인덱스
CREATE INDEX idx_automl_models_model_id ON automl_models(model_id);
CREATE INDEX idx_automl_models_status ON automl_models(status);
CREATE INDEX idx_automl_models_model_type ON automl_models(model_type);
CREATE INDEX idx_automl_models_last_used ON automl_models(last_used_at DESC);

-- AutoML 분석 결과 인덱스
CREATE INDEX idx_automl_analysis_report_id ON automl_analysis_results(report_id);
CREATE INDEX idx_automl_analysis_model_id ON automl_analysis_results(model_id);
CREATE INDEX idx_automl_analysis_type ON automl_analysis_results(analysis_type);
CREATE INDEX idx_automl_analysis_confidence ON automl_analysis_results(confidence DESC);
CREATE INDEX idx_automl_analysis_created_at ON automl_analysis_results(created_at DESC);

-- 문서 벡터 관련 인덱스
CREATE INDEX idx_document_vectors_document_id ON document_vectors(document_id);
CREATE INDEX idx_document_vectors_content_type ON document_vectors(content_type);
CREATE INDEX idx_document_vectors_chunk_index ON document_vectors(document_id, chunk_index);

-- 벡터 유사도 검색을 위한 HNSW 인덱스 (성능 최적화)
CREATE INDEX idx_document_vectors_embedding_cosine ON document_vectors 
USING hnsw (embedding vector_cosine_ops) WITH (m = 16, ef_construction = 64);

-- 전문 검색 인덱스
CREATE INDEX idx_document_vectors_search_vector ON document_vectors USING gin(search_vector);

-- RAG 분석 결과 인덱스
CREATE INDEX idx_rag_analysis_report_id ON rag_analysis_results(report_id);
CREATE INDEX idx_rag_analysis_original_id ON rag_analysis_results(original_analysis_id);
CREATE INDEX idx_rag_analysis_confidence ON rag_analysis_results(confidence DESC);
CREATE INDEX idx_rag_analysis_created_at ON rag_analysis_results(created_at DESC);

-- RAG 질의응답 로그 인덱스
CREATE INDEX idx_rag_qa_logs_user_id ON rag_qa_logs(user_id);
CREATE INDEX idx_rag_qa_logs_session_id ON rag_qa_logs(session_id);
CREATE INDEX idx_rag_qa_logs_created_at ON rag_qa_logs(created_at DESC);
CREATE INDEX idx_rag_qa_logs_confidence ON rag_qa_logs(confidence DESC);
CREATE INDEX idx_rag_qa_logs_rating ON rag_qa_logs(user_rating);

-- 복합 인덱스
CREATE INDEX idx_document_vectors_type_created ON document_vectors(content_type, created_at DESC);
CREATE INDEX idx_automl_analysis_report_type ON automl_analysis_results(report_id, analysis_type);

-- 기존 ai_analysis_results 테이블 확장 (AutoML 통합을 위해)
ALTER TABLE ai_analysis_results 
ADD COLUMN IF NOT EXISTS automl_model_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS automl_confidence FLOAT,
ADD COLUMN IF NOT EXISTS automl_predictions JSONB,
ADD COLUMN IF NOT EXISTS rag_enhanced BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS rag_context_count INTEGER DEFAULT 0;

-- 기존 테이블에 인덱스 추가
CREATE INDEX IF NOT EXISTS idx_ai_analysis_automl_model ON ai_analysis_results(automl_model_id);
CREATE INDEX IF NOT EXISTS idx_ai_analysis_rag_enhanced ON ai_analysis_results(rag_enhanced);

-- 함수: 문서 벡터 통계 조회
CREATE OR REPLACE FUNCTION get_document_vector_stats()
RETURNS TABLE (
    content_type VARCHAR(50),
    total_documents BIGINT,
    total_chunks BIGINT,
    avg_chunk_length NUMERIC,
    latest_update TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dv.content_type,
        COUNT(DISTINCT dv.document_id) as total_documents,
        COUNT(*) as total_chunks,
        AVG(dv.chunk_length) as avg_chunk_length,
        MAX(dv.created_at) as latest_update
    FROM document_vectors dv
    GROUP BY dv.content_type
    ORDER BY total_chunks DESC;
END;
$$ LANGUAGE plpgsql;

-- 함수: 유사 문서 검색 (코사인 유사도)
CREATE OR REPLACE FUNCTION find_similar_documents(
    query_embedding vector(1536),
    content_type_filter VARCHAR(50) DEFAULT NULL,
    similarity_threshold FLOAT DEFAULT 0.7,
    max_results INTEGER DEFAULT 10
)
RETURNS TABLE (
    id BIGINT,
    document_id VARCHAR(255),
    chunk_text TEXT,
    similarity_score FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dv.id,
        dv.document_id,
        dv.chunk_text,
        (1 - (dv.embedding <=> query_embedding))::FLOAT as similarity_score
    FROM document_vectors dv
    WHERE 
        (content_type_filter IS NULL OR dv.content_type = content_type_filter)
        AND (1 - (dv.embedding <=> query_embedding)) >= similarity_threshold
    ORDER BY dv.embedding <=> query_embedding
    LIMIT max_results;
END;
$$ LANGUAGE plpgsql;

-- 트리거: updated_at 자동 업데이트
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 트리거 적용
CREATE TRIGGER update_automl_models_updated_at 
    BEFORE UPDATE ON automl_models 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_automl_analysis_results_updated_at 
    BEFORE UPDATE ON automl_analysis_results 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_document_vectors_updated_at 
    BEFORE UPDATE ON document_vectors 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rag_analysis_results_updated_at 
    BEFORE UPDATE ON rag_analysis_results 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 초기 데이터: 기본 AutoML 모델 설정
INSERT INTO automl_models (model_id, model_name, model_type, project_id, location, description) VALUES
('mock-classification-model', '기본 이미지 분류 모델', 'CLASSIFICATION', 'jeonbuk-report-platform', 'us-central1', '전북 신고 플랫폼 기본 분류 모델'),
('mock-detection-model', '기본 객체 탐지 모델', 'OBJECT_DETECTION', 'jeonbuk-report-platform', 'us-central1', '전북 신고 플랫폼 기본 객체 탐지 모델')
ON CONFLICT (model_id) DO NOTHING;

-- 뷰: 통합 AI 분석 결과 (AutoML + RAG)
CREATE OR REPLACE VIEW unified_ai_analysis AS
SELECT 
    r.id as report_id,
    r.title,
    r.category_id,
    
    -- 기존 AI 분석
    ai.analysis_result as basic_analysis,
    ai.confidence as basic_confidence,
    
    -- AutoML 분석
    aml.analysis_type as automl_type,
    aml.predictions as automl_predictions,
    aml.confidence as automl_confidence,
    aml.processing_time_ms as automl_processing_time,
    
    -- RAG 분석
    rag.enhanced_analysis as rag_analysis,
    rag.confidence as rag_confidence,
    rag.context_source_count,
    rag.improvement_ratio,
    rag.processing_time_ms as rag_processing_time,
    
    -- 종합 정보
    GREATEST(COALESCE(ai.confidence, 0), COALESCE(aml.confidence, 0), COALESCE(rag.confidence, 0)) as max_confidence,
    r.created_at,
    r.updated_at
    
FROM reports r
LEFT JOIN ai_analysis_results ai ON r.id = ai.report_id
LEFT JOIN automl_analysis_results aml ON r.id = aml.report_id
LEFT JOIN rag_analysis_results rag ON r.id = rag.report_id;

-- 통계 뷰: AI 분석 성능 대시보드
CREATE OR REPLACE VIEW ai_analysis_stats AS
SELECT 
    DATE_TRUNC('day', created_at) as analysis_date,
    COUNT(*) as total_analyses,
    
    -- 기본 AI 통계
    COUNT(CASE WHEN ai_analysis_results.id IS NOT NULL THEN 1 END) as basic_ai_count,
    AVG(CASE WHEN ai_analysis_results.confidence IS NOT NULL THEN ai_analysis_results.confidence END) as avg_basic_confidence,
    
    -- AutoML 통계
    COUNT(CASE WHEN automl_analysis_results.id IS NOT NULL THEN 1 END) as automl_count,
    AVG(CASE WHEN automl_analysis_results.confidence IS NOT NULL THEN automl_analysis_results.confidence END) as avg_automl_confidence,
    AVG(CASE WHEN automl_analysis_results.processing_time_ms IS NOT NULL THEN automl_analysis_results.processing_time_ms END) as avg_automl_time,
    
    -- RAG 통계
    COUNT(CASE WHEN rag_analysis_results.id IS NOT NULL THEN 1 END) as rag_count,
    AVG(CASE WHEN rag_analysis_results.confidence IS NOT NULL THEN rag_analysis_results.confidence END) as avg_rag_confidence,
    AVG(CASE WHEN rag_analysis_results.context_source_count IS NOT NULL THEN rag_analysis_results.context_source_count END) as avg_context_sources,
    AVG(CASE WHEN rag_analysis_results.improvement_ratio IS NOT NULL THEN rag_analysis_results.improvement_ratio END) as avg_improvement_ratio
    
FROM reports
LEFT JOIN ai_analysis_results ON reports.id = ai_analysis_results.report_id
LEFT JOIN automl_analysis_results ON reports.id = automl_analysis_results.report_id  
LEFT JOIN rag_analysis_results ON reports.id = rag_analysis_results.report_id
GROUP BY DATE_TRUNC('day', reports.created_at)
ORDER BY analysis_date DESC;