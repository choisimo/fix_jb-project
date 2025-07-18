-- 문서 벡터 테이블 생성
CREATE TABLE IF NOT EXISTS document_vectors (
    id BIGSERIAL PRIMARY KEY,
    document_id VARCHAR(255) NOT NULL,
    content_type VARCHAR(100),
    chunk_text TEXT,
    chunk_index INTEGER,
    embedding JSONB,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_document_vectors_document_id ON document_vectors(document_id);
CREATE INDEX IF NOT EXISTS idx_document_vectors_content_type ON document_vectors(content_type);
CREATE INDEX IF NOT EXISTS idx_document_vectors_chunk_index ON document_vectors(chunk_index);
CREATE INDEX IF NOT EXISTS idx_document_vectors_created_at ON document_vectors(created_at);

-- GIN 인덱스 (JSONB 필드용)
CREATE INDEX IF NOT EXISTS idx_document_vectors_embedding_gin ON document_vectors USING GIN(embedding);
CREATE INDEX IF NOT EXISTS idx_document_vectors_metadata_gin ON document_vectors USING GIN(metadata);

-- 복합 인덱스
CREATE INDEX IF NOT EXISTS idx_document_vectors_doc_chunk ON document_vectors(document_id, chunk_index);