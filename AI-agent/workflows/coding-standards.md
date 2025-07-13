# 개발 워크플로우 및 코딩 표준

## 🎯 개발 워크플로우 개요

전북 신고 플랫폼의 개발 워크플로우는 **효율성, 품질, 일관성**을 보장하기 위해 체계적으로 설계되었습니다. 모든 개발자는 이 가이드라인을 준수해야 합니다.

## 🔄 Git 워크플로우

### 브랜치 전략 (Git Flow 기반)
```
main (production)
├── develop (integration)
├── feature/* (새 기능 개발)
├── release/* (릴리스 준비)
├── hotfix/* (긴급 수정)
└── docs/* (문서 업데이트)
```

#### 브랜치 명명 규칙
```
feature/AI-XXXX-feature-name      # 새 기능
bugfix/AI-XXXX-bug-description    # 버그 수정
hotfix/AI-XXXX-critical-fix       # 긴급 수정
release/v1.2.0                    # 릴리스 준비
docs/update-api-documentation     # 문서 업데이트
refactor/optimize-roboflow-service # 리팩토링
```

### 커밋 메시지 표준
```
<type>(<scope>): <subject>

<body>

<footer>
```

#### 타입 분류
```
feat:     새로운 기능 추가
fix:      버그 수정
docs:     문서 변경
style:    코드 포맷팅, 세미콜론 누락 등
refactor: 기능 변경 없는 코드 리팩토링
test:     테스트 코드 추가/수정
chore:    빌드 프로세스, 보조 도구 변경
perf:     성능 개선
ci:       CI/CD 파이프라인 변경
```

#### 커밋 메시지 예시
```
feat(roboflow): add batch image analysis endpoint

- Implement parallel processing for multiple images
- Add circuit breaker pattern for error handling
- Support confidence and overlap parameter configuration

Closes #AI-1234
```

### Pull Request 워크플로우

#### 1. PR 생성 전 체크리스트
```bash
# 코드 품질 검증
./gradlew check                    # 린트 + 테스트
./gradlew jacocoTestReport        # 코드 커버리지

# 보안 검증
./gradlew dependencyCheckAnalyze  # 취약점 스캔

# 빌드 확인
./gradlew build                   # 전체 빌드
```

#### 2. PR 템플릿
```markdown
## 📋 작업 내용
- [ ] 기능 A 구현
- [ ] 기능 B 수정
- [ ] 테스트 케이스 추가

## 🔧 변경사항
### Added
- 새로운 API 엔드포인트: POST /api/v1/analyze/batch

### Changed
- Roboflow API 호출 방식 개선

### Fixed
- 이미지 업로드 시 메모리 누수 문제 해결

## 🧪 테스트
- [ ] 단위 테스트 작성
- [ ] 통합 테스트 작성  
- [ ] 수동 테스트 완료

## 📖 관련 문서
- API 문서 업데이트: [링크]
- 아키텍처 문서 업데이트: [링크]

## 🔗 관련 이슈
Closes #AI-1234
Related to #AI-5678
```

#### 3. PR 리뷰 기준
```
코드 품질:
✅ 코딩 컨벤션 준수
✅ SOLID 원칙 적용
✅ 적절한 디자인 패턴 사용
✅ 성능 고려사항 확인

테스트:
✅ 테스트 커버리지 80% 이상
✅ 엣지 케이스 테스트 포함
✅ 통합 테스트 포함

보안:
✅ 인증/권한 검증
✅ 입력 값 검증
✅ 민감 정보 노출 방지

문서화:
✅ API 문서 업데이트
✅ 코드 주석 적절성
✅ README 업데이트 (필요시)
```

## 📝 코딩 표준

### Java 코딩 컨벤션

#### 1. 네이밍 규칙
```java
// 클래스명: PascalCase
public class UserService {}
public class RoboflowApiClient {}

// 메서드명: camelCase
public void createUser() {}
public CompletableFuture<Result> analyzeImageAsync() {}

// 변수명: camelCase
private String userName;
private List<Report> reportList;

// 상수명: UPPER_SNAKE_CASE
private static final String DEFAULT_MODEL_ID = "general-detection";
private static final int MAX_RETRY_ATTEMPTS = 3;

// 패키지명: lowercase
package com.jeonbuk.report.application.service;
```

#### 2. 클래스 구조
```java
@Service
@RequiredArgsConstructor
@Slf4j
public class ReportService {
    
    // 1. 상수
    private static final String DEFAULT_STATUS = "PENDING";
    
    // 2. 의존성 (final fields)
    private final ReportRepository reportRepository;
    private final NotificationService notificationService;
    
    // 3. 설정 값 (@Value)
    @Value("${app.report.max-file-size}")
    private long maxFileSize;
    
    // 4. Public 메서드
    public Report createReport(CreateReportRequest request) {
        // Implementation
    }
    
    // 5. Private 메서드
    private void validateRequest(CreateReportRequest request) {
        // Implementation
    }
    
    // 6. 내부 클래스/열거형
    public enum ReportStatus {
        PENDING, IN_PROGRESS, COMPLETED, REJECTED
    }
}
```

#### 3. 메서드 구조
```java
/**
 * 신고를 생성하고 AI 분석을 시작합니다.
 * 
 * @param request 신고 생성 요청 데이터
 * @param userId 신고자 사용자 ID
 * @return 생성된 신고 정보
 * @throws IllegalArgumentException 입력 데이터가 유효하지 않은 경우
 * @throws ReportCreationException 신고 생성 중 오류가 발생한 경우
 */
@Transactional
public Report createReport(CreateReportRequest request, UUID userId) {
    // 1. 입력 검증
    validateCreateReportRequest(request);
    validateUserExists(userId);
    
    // 2. 비즈니스 로직
    Report report = buildReportEntity(request, userId);
    Report savedReport = reportRepository.save(report);
    
    // 3. 부가 작업
    triggerAiAnalysis(savedReport);
    sendNotificationToManagers(savedReport);
    
    // 4. 로깅
    log.info("Report created successfully: reportId={}, userId={}", 
        savedReport.getId(), userId);
    
    return savedReport;
}
```

#### 4. 예외 처리
```java
// 커스텀 예외 정의
@ResponseStatus(HttpStatus.BAD_REQUEST)
public class InvalidReportDataException extends RuntimeException {
    public InvalidReportDataException(String message) {
        super(message);
    }
    
    public InvalidReportDataException(String message, Throwable cause) {
        super(message, cause);
    }
}

// 예외 처리 예시
public class ReportService {
    
    public Report createReport(CreateReportRequest request, UUID userId) {
        try {
            // 비즈니스 로직
            return processReport(request, userId);
            
        } catch (DataIntegrityViolationException e) {
            log.error("Database constraint violation while creating report", e);
            throw new InvalidReportDataException("중복된 신고이거나 데이터가 유효하지 않습니다.", e);
            
        } catch (ExternalServiceException e) {
            log.error("External service call failed", e);
            throw new ReportProcessingException("외부 서비스 연동 중 오류가 발생했습니다.", e);
            
        } catch (Exception e) {
            log.error("Unexpected error during report creation", e);
            throw new ReportCreationException("신고 생성 중 예상치 못한 오류가 발생했습니다.", e);
        }
    }
}
```

### Spring Boot 특화 패턴

#### 1. 컨트롤러 패턴
```java
@RestController
@RequestMapping("/api/v1/reports")
@RequiredArgsConstructor
@Validated
@Tag(name = "Report Management", description = "신고 관리 API")
public class ReportController {
    
    private final ReportService reportService;
    
    @PostMapping
    @Operation(summary = "신고 생성", description = "새로운 신고를 생성합니다.")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<ReportResponse>> createReport(
            @Valid @RequestBody CreateReportRequest request,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        
        try {
            Report report = reportService.createReport(request, currentUser.getId());
            ReportResponse response = ReportResponse.from(report);
            
            return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("신고가 성공적으로 생성되었습니다.", response));
                
        } catch (InvalidReportDataException e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/{reportId}")
    @Operation(summary = "신고 조회", description = "특정 신고의 상세 정보를 조회합니다.")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<ReportResponse>> getReport(
            @PathVariable UUID reportId,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        
        return reportService.findByIdAndUserId(reportId, currentUser.getId())
            .map(report -> ResponseEntity.ok(
                ApiResponse.success("신고 조회 성공", ReportResponse.from(report))))
            .orElse(ResponseEntity.notFound().build());
    }
}
```

#### 2. 서비스 레이어 패턴
```java
@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
@Slf4j
public class ReportService {
    
    private final ReportRepository reportRepository;
    private final UserRepository userRepository;
    private final AiAnalysisService aiAnalysisService;
    
    @Transactional
    public Report createReport(CreateReportRequest request, UUID userId) {
        // 트랜잭션 내에서 실행
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new UserNotFoundException("사용자를 찾을 수 없습니다."));
        
        Report report = Report.builder()
            .title(request.getTitle())
            .description(request.getDescription())
            .user(user)
            .status(ReportStatus.PENDING)
            .build();
        
        Report savedReport = reportRepository.save(report);
        
        // 비동기 AI 분석 시작
        aiAnalysisService.analyzeReportAsync(savedReport);
        
        return savedReport;
    }
    
    public Page<Report> getReportsByUser(UUID userId, Pageable pageable) {
        return reportRepository.findByUserIdAndDeletedAtIsNull(userId, pageable);
    }
}
```

#### 3. 레포지토리 패턴
```java
@Repository
public interface ReportRepository extends JpaRepository<Report, UUID> {
    
    // 메서드 명명 규칙: findBy + 필드명 + 조건
    Page<Report> findByUserIdAndDeletedAtIsNull(UUID userId, Pageable pageable);
    
    List<Report> findByStatusAndCreatedAtAfter(ReportStatus status, LocalDateTime date);
    
    // 커스텀 쿼리
    @Query("SELECT r FROM Report r WHERE r.status = :status AND r.priority = :priority")
    List<Report> findByStatusAndPriority(
        @Param("status") ReportStatus status, 
        @Param("priority") ReportPriority priority);
    
    // 네이티브 쿼리
    @Query(value = "SELECT * FROM reports WHERE ST_DWithin(location_point, :point, :distance)", 
           nativeQuery = true)
    List<Report> findNearbyReports(@Param("point") Point point, @Param("distance") double distance);
    
    // 벌크 업데이트
    @Modifying
    @Query("UPDATE Report r SET r.status = :newStatus WHERE r.status = :oldStatus")
    int updateReportStatus(@Param("oldStatus") ReportStatus oldStatus, 
                          @Param("newStatus") ReportStatus newStatus);
}
```

### API 설계 원칙

#### 1. RESTful API 설계
```
GET    /api/v1/reports              # 신고 목록 조회
POST   /api/v1/reports              # 신고 생성
GET    /api/v1/reports/{id}         # 특정 신고 조회
PUT    /api/v1/reports/{id}         # 신고 수정
DELETE /api/v1/reports/{id}         # 신고 삭제

POST   /api/v1/reports/{id}/files   # 파일 업로드
PUT    /api/v1/reports/{id}/status  # 상태 변경
GET    /api/v1/reports/{id}/comments # 댓글 목록

# 필터링 및 정렬
GET /api/v1/reports?status=PENDING&sort=createdAt,desc&page=0&size=20
```

#### 2. 응답 형식 표준화
```java
// 성공 응답
{
    "success": true,
    "message": "요청이 성공적으로 처리되었습니다.",
    "data": {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "title": "도로 파손 신고",
        "status": "PENDING"
    },
    "timestamp": "2025-07-12T14:30:00Z"
}

// 오류 응답
{
    "success": false,
    "message": "요청 처리 중 오류가 발생했습니다.",
    "error": {
        "code": "INVALID_REQUEST",
        "details": "필수 필드가 누락되었습니다: title"
    },
    "timestamp": "2025-07-12T14:30:00Z"
}

// 페이징 응답
{
    "success": true,
    "data": {
        "content": [...],
        "pageable": {
            "page": 0,
            "size": 20,
            "sort": "createdAt,desc"
        },
        "totalElements": 150,
        "totalPages": 8,
        "first": true,
        "last": false
    }
}
```

### 테스트 코딩 표준

#### 1. 테스트 네이밍
```java
// 패턴: should_ExpectedBehavior_When_StateUnderTest
@Test
void should_CreateReport_When_ValidDataProvided() {}

@Test  
void should_ThrowException_When_UserNotFound() {}

@Test
void should_ReturnEmptyList_When_NoReportsExist() {}
```

#### 2. 테스트 구조 (Given-When-Then)
```java
@Test
void should_CreateReport_When_ValidDataProvided() {
    // Given
    UUID userId = UUID.randomUUID();
    CreateReportRequest request = CreateReportRequest.builder()
        .title("테스트 신고")
        .description("테스트 설명")
        .build();
    
    User mockUser = User.builder()
        .id(userId)
        .email("test@example.com")
        .build();
    
    when(userRepository.findById(userId)).thenReturn(Optional.of(mockUser));
    when(reportRepository.save(any(Report.class))).thenAnswer(i -> i.getArgument(0));
    
    // When
    Report result = reportService.createReport(request, userId);
    
    // Then
    assertThat(result).isNotNull();
    assertThat(result.getTitle()).isEqualTo("테스트 신고");
    assertThat(result.getUser()).isEqualTo(mockUser);
    assertThat(result.getStatus()).isEqualTo(ReportStatus.PENDING);
    
    verify(reportRepository).save(any(Report.class));
    verify(aiAnalysisService).analyzeReportAsync(any(Report.class));
}
```

#### 3. 통합 테스트 패턴
```java
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Testcontainers
class ReportControllerIntegrationTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15")
        .withDatabaseName("testdb")
        .withUsername("test")
        .withPassword("test");
    
    @Test
    @WithMockUser(roles = "USER")
    void should_CreateReport_When_AuthenticatedUser() throws Exception {
        // Given
        CreateReportRequest request = CreateReportRequest.builder()
            .title("통합 테스트 신고")
            .description("통합 테스트 설명")
            .build();
        
        // When & Then
        mockMvc.perform(post("/api/v1/reports")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.success").value(true))
            .andExpect(jsonPath("$.data.title").value("통합 테스트 신고"));
    }
}
```

## 📋 코드 리뷰 체크리스트

### 기능성
- [ ] 요구사항을 정확히 구현했는가?
- [ ] 비즈니스 로직이 올바른가?
- [ ] 엣지 케이스가 적절히 처리되었는가?
- [ ] 에러 처리가 적절한가?

### 코드 품질
- [ ] 코딩 컨벤션을 준수했는가?
- [ ] 메서드/클래스 크기가 적절한가?
- [ ] 변수/메서드명이 명확한가?
- [ ] 중복 코드가 없는가?

### 성능
- [ ] 불필요한 데이터베이스 쿼리가 없는가?
- [ ] N+1 문제가 없는가?
- [ ] 메모리 누수 가능성이 없는가?
- [ ] 적절한 캐싱이 적용되었는가?

### 보안
- [ ] 인증/권한 검증이 적절한가?
- [ ] 입력 값 검증이 충분한가?
- [ ] SQL 인젝션 위험이 없는가?
- [ ] 민감 정보가 노출되지 않는가?

### 테스트
- [ ] 단위 테스트가 충분한가?
- [ ] 테스트 커버리지가 80% 이상인가?
- [ ] 모든 테스트가 통과하는가?
- [ ] 테스트 코드 품질이 양호한가?

---

*문서 버전: 1.0*  
*최종 업데이트: 2025년 7월 12일*  
*작성자: 개발팀 리드*