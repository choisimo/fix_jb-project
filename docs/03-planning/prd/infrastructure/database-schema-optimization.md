# PRD: AI Analysis Database Schema 오류 해결

## 1. 문제 정의 (Problem Statement)

### 1.1 현재 상황
- **메인 API 서버**: 시작되지 않고 지속적으로 재시작 중
- **오류 메시지**: `Schema-validation: wrong column type encountered in column [confidence_score] in table [ai_analysis_results]; found [numeric (Types#NUMERIC)], but expecting [float(53) (Types#FLOAT)]`
- **근본 원인**: AI Analysis Results 테이블의 스키마 불일치 및 외래키 타입 오류

### 1.2 상세 분석
1. **Entity vs Database Schema 불일치**:
   - **Entity**: `confidence_score` → `Double` (Java)
   - **Database**: `confidence_score` → `DECIMAL(5, 2)` (PostgreSQL)
   - **Hibernate 예상**: `FLOAT` 타입

2. **외래키 타입 불일치**:
   - **Migration SQL**: `report_id VARCHAR(36)`, `report_file_id VARCHAR(36)`
   - **실제 참조 테이블**: `UUID` 타입
   - **오류**: `Key columns "report_id" and "id" are of incompatible types: character varying and uuid`

3. **테이블 생성 실패**:
   - `ai_analysis_results` 테이블이 생성되지 않음
   - 후속 인덱스 생성도 모두 실패

## 2. 목표 (Objectives)

### 2.1 기본 목표
- 메인 API 서버 정상 시작 및 안정적 운영
- AI Analysis Results 테이블 정상 생성 및 운영
- Entity와 Database Schema 간 완전한 일치

### 2.2 성공 기준
- [ ] 메인 API 서버가 오류 없이 시작됨
- [ ] `ai_analysis_results` 테이블이 정상 생성됨
- [ ] Hibernate 스키마 검증 통과
- [ ] AI 분석 기능 정상 동작

## 3. 해결 방안 (Solution)

### 3.1 우선순위 1: 데이터타입 통일
#### 변경사항
```sql
-- 기존 (문제)
confidence_score DECIMAL(5, 2)

-- 변경 후 (해결)
confidence_score DOUBLE PRECISION  -- 또는 FLOAT8
```

#### Entity 확인 및 수정
```java
// AiAnalysisResult.java - 현재 (올바름)
@Column(name = "confidence_score")
private Double confidenceScore;
```

### 3.2 우선순위 2: 외래키 타입 수정
#### 변경사항
```sql
-- 기존 (문제)
report_id VARCHAR(36) NOT NULL,
report_file_id VARCHAR(36),

-- 변경 후 (해결)
report_id UUID NOT NULL,
report_file_id UUID,
```

### 3.3 우선순위 3: 완전한 스키마 재생성
#### 수정된 Migration SQL
```sql
CREATE TABLE ai_analysis_results (
    id BIGSERIAL PRIMARY KEY,
    report_id UUID NOT NULL,
    report_file_id UUID,
    
    -- AI 서비스 정보
    ai_service VARCHAR(50) NOT NULL,
    
    -- 분석 결과
    raw_response TEXT,
    parsed_result TEXT,
    status VARCHAR(20) NOT NULL,
    confidence_score DOUBLE PRECISION,  -- 수정된 부분
    
    -- 오류 및 처리 정보
    error_message TEXT,
    processing_time_ms BIGINT,
    retry_count INTEGER NOT NULL DEFAULT 0,
    
    -- 메타데이터
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- 외래 키 제약 조건 (수정된 부분)
    FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE,
    FOREIGN KEY (report_file_id) REFERENCES report_files(id) ON DELETE CASCADE
);
```

## 4. 구현 계획 (Implementation Plan)

### 4.1 Phase 1: 긴급 수정 (즉시 실행)
1. **데이터베이스 정리**
   - 기존 실패한 테이블 구조 확인
   - 필요시 `DROP TABLE ai_analysis_results` 실행

2. **Migration SQL 수정**
   - `database/migrations/ai_analysis_results.sql` 파일 수정
   - 타입 불일치 문제 해결

3. **테이블 재생성**
   - 수정된 스키마로 테이블 생성
   - 인덱스 생성 확인

### 4.2 Phase 2: 검증 및 테스트 (수정 후 즉시)
1. **서버 시작 확인**
   - 메인 API 서버 재시작
   - 로그에서 오류 확인

2. **Hibernate 스키마 검증**
   - 스키마 검증 모드 확인
   - Entity 매핑 정상성 검증

3. **기능 테스트**
   - AI 분석 API 호출 테스트
   - 데이터 삽입/조회 테스트

### 4.3 Phase 3: 예방 조치 (추후 개선)
1. **스키마 버전 관리**
   - Flyway 또는 Liquibase 도입 검토
   - 스키마 변경 이력 관리

2. **개발 프로세스 개선**
   - Entity 변경 시 Migration 자동 생성
   - CI/CD에서 스키마 검증 추가

## 5. 위험 요소 및 대응 (Risks & Mitigation)

### 5.1 위험 요소
1. **데이터 손실**: 기존 `ai_analysis_results` 데이터 존재 시
2. **서비스 중단**: 스키마 변경 중 서비스 불가
3. **종속성 문제**: 다른 서비스에서 해당 테이블 참조 시

### 5.2 대응 방안
1. **데이터 백업**: 스키마 변경 전 전체 데이터베이스 백업
2. **점진적 배포**: 개발 → 스테이징 → 프로덕션 순서로 적용
3. **롤백 계획**: 문제 발생 시 즉시 이전 상태로 복원 가능한 계획 수립

## 6. 일정 및 리소스 (Timeline & Resources)

### 6.1 예상 일정
- **긴급 수정**: 1시간 이내
- **검증 및 테스트**: 2시간 이내
- **문서화 및 배포**: 1시간 이내
- **총 소요 시간**: 4시간 이내

### 6.2 필요 리소스
- **개발자**: 1명 (백엔드)
- **DBA**: 1명 (선택사항)
- **테스터**: 1명 (기능 검증)

## 7. 성공 지표 (Success Metrics)

### 7.1 기술적 지표
- [ ] 메인 API 서버 시작 성공률: 100%
- [ ] Hibernate 스키마 검증 통과율: 100%
- [ ] AI 분석 API 응답 시간: 2초 이내
- [ ] 데이터베이스 연결 오류율: 0%

### 7.2 비즈니스 지표
- [ ] 시스템 가용성: 99% 이상
- [ ] 사용자 불편 신고: 0건
- [ ] AI 분석 기능 정상 동작: 100%

## 8. 후속 조치 (Follow-up Actions)

### 8.1 단기 조치 (1주일 이내)
1. 유사한 스키마 불일치 문제 전체 점검
2. Entity-Database 매핑 검증 자동화 도구 도입
3. 개발팀 스키마 관리 가이드라인 작성

### 8.2 중장기 조치 (1개월 이내)
1. 데이터베이스 마이그레이션 도구 도입
2. CI/CD 파이프라인에 스키마 검증 단계 추가
3. 모니터링 시스템에 스키마 관련 알림 추가

---

**문서 정보**
- 작성일: 2025-07-13
- 작성자: AI Assistant
- 버전: 1.0
- 상태: 승인 대기

**관련 파일**
- `/main-api-server/src/main/java/com/jeonbuk/report/domain/entity/AiAnalysisResult.java`
- `/database/migrations/ai_analysis_results.sql`
- `/database/schema.sql`