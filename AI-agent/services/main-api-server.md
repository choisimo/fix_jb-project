# Main API Server 상세 역할 및 구조

## 🎯 Main API Server 개요

Main API Server는 전북 신고 플랫폼의 **핵심 비즈니스 로직**을 담당하는 주요 서비스로, 사용자 관리, 신고 관리, 인증/권한, 알림 등의 주요 기능을 제공합니다.

## 📁 프로젝트 구조

```
main-api-server/
├── src/main/java/com/jeonbuk/report/
│   ├── presentation/           # 프레젠테이션 계층
│   │   ├── controller/         # REST API 컨트롤러
│   │   │   ├── UserController.java
│   │   │   ├── ReportController.java
│   │   │   ├── AuthController.java
│   │   │   ├── NotificationController.java
│   │   │   └── AiRoutingController.java
│   │   └── dto/               # 데이터 전송 객체
│   │       ├── request/       # 요청 DTO
│   │       └── response/      # 응답 DTO
│   ├── application/           # 애플리케이션 계층
│   │   └── service/          # 비즈니스 서비스
│   │       ├── UserService.java
│   │       ├── ReportService.java
│   │       ├── AuthService.java
│   │       ├── NotificationService.java
│   │       ├── AiRoutingService.java
│   │       ├── IntegratedAiAgentService.java
│   │       ├── ValidationAiAgentService.java
│   │       ├── GisService.java
│   │       └── TokenService.java
│   ├── domain/               # 도메인 계층
│   │   ├── entity/           # JPA 엔티티
│   │   │   ├── User.java
│   │   │   ├── Report.java
│   │   │   ├── ReportCategory.java
│   │   │   ├── ReportFile.java
│   │   │   ├── Comment.java
│   │   │   └── Notification.java
│   │   └── repository/       # 레포지토리 인터페이스
│   └── infrastructure/       # 인프라 계층
│       ├── config/           # 설정 클래스
│       │   ├── SecurityConfig.java
│       │   ├── WebSocketConfig.java
│       │   ├── AsyncConfig.java
│       │   ├── CorsConfig.java
│       │   └── DevConfig.java
│       ├── security/         # 보안 관련
│       │   └── jwt/          # JWT 토큰 처리
│       ├── external/         # 외부 API 연동
│       │   ├── roboflow/     # Roboflow API
│       │   └── openrouter/   # OpenRouter API
│       └── websocket/        # WebSocket 처리
└── src/main/resources/
    ├── application.yml       # 애플리케이션 설정
    ├── data.sql             # 초기 데이터
    └── static/              # 정적 리소스
```

## 🔧 핵심 기능 및 책임

### 1. 사용자 관리 (User Management)

#### UserController.java
```java
// 주요 엔드포인트
POST   /users/login              # JWT 로그인
POST   /users/register-admin     # 관리자 사용자 등록
GET    /users/profile           # 사용자 프로필 조회
PUT    /users/{userId}          # 사용자 정보 수정
DELETE /users/{userId}          # 사용자 삭제
GET    /users/stats             # 사용자 통계
```

#### UserService.java
**핵심 기능:**
- 사용자 등록 및 인증
- 패스워드 암호화 (BCrypt)
- 역할 기반 권한 관리 (USER, MANAGER, ADMIN)
- 사용자 프로필 관리
- OAuth 소셜 로그인 처리

**비즈니스 로직:**
```java
// 사용자 등록 로직
public User registerUser(String email, String password, String name, String phone, String department) {
    // 이메일 중복 검증
    // 패스워드 암호화
    // 기본 역할 설정 (USER)
    // 데이터베이스 저장
    // 환영 알림 발송
}

// 인증 처리
public Optional<User> authenticateUser(String email, String password) {
    // 사용자 존재 확인
    // 패스워드 검증
    // 로그인 시간 업데이트
    // 세션 정보 생성
}
```

### 2. 신고 관리 (Report Management)

#### ReportController.java
```java
// 주요 엔드포인트
POST   /reports                 # 새 신고 작성
GET    /reports                 # 신고 목록 조회 (페이징)
GET    /reports/{reportId}      # 특정 신고 상세 조회
PUT    /reports/{reportId}      # 신고 수정
DELETE /reports/{reportId}      # 신고 삭제
POST   /reports/{reportId}/files # 파일 업로드
PUT    /reports/{reportId}/status # 상태 변경
GET    /reports/stats           # 신고 통계
```

#### ReportService.java
**핵심 기능:**
- 신고 CRUD 작업
- 파일 업로드 및 관리
- 상태 변경 및 이력 추적
- 위치 정보 처리 (GIS)
- AI 분석 결과 통합

**비즈니스 로직:**
```java
// 신고 생성 로직
public Report createReport(CreateReportRequest request, UUID userId) {
    // 사용자 권한 검증
    // 위치 정보 유효성 검사
    // 신고 엔티티 생성
    // 파일 처리 (이미지/동영상)
    // AI 분석 이벤트 발생
    // 담당 부서 자동 배정
    // 생성 알림 발송
}

// 상태 변경 로직
public Report updateReportStatus(UUID reportId, ReportStatus newStatus, UUID managerId) {
    // 권한 검증 (담당자/관리자만)
    // 상태 변경 가능성 검증
    // 이력 기록
    // 신고자 알림
    // 통계 업데이트
}
```

### 3. 인증 및 권한 (Authentication & Authorization)

#### AuthController.java
```java
// 주요 엔드포인트
POST   /auth/login              # 일반 로그인
POST   /auth/oauth/google       # Google OAuth
POST   /auth/oauth/kakao        # Kakao OAuth
POST   /auth/refresh            # 토큰 갱신
POST   /auth/logout             # 로그아웃
```

#### SecurityConfig.java
**보안 설정:**
- JWT 기반 인증
- 메서드 레벨 권한 검증
- CORS 설정
- CSRF 보호
- 세션 관리

**권한 매트릭스:**
```java
public enum UserRole {
    USER("일반 사용자"),      // 자신의 신고만 관리
    MANAGER("담당자"),        // 배정된 신고 관리
    ADMIN("시스템 관리자");   // 전체 시스템 관리
}

// 권한 검증 어노테이션 예시
@PreAuthorize("hasRole('ADMIN')")                    // 관리자만
@PreAuthorize("hasRole('MANAGER') or hasRole('ADMIN')") // 담당자 이상
@PreAuthorize("#userId == authentication.principal.id") // 본인만
```

### 4. 실시간 알림 (Real-time Notifications)

#### NotificationController.java
```java
// 주요 엔드포인트
GET    /notifications           # 알림 목록 조회
POST   /notifications/read      # 알림 읽음 처리
DELETE /notifications/{id}      # 알림 삭제
GET    /notifications/unread-count # 읽지 않은 알림 수
```

#### WebSocketConfig.java
**실시간 통신:**
- STOMP 프로토콜 사용
- 개인/그룹 알림 지원
- 연결 상태 관리
- 메시지 브로커 설정

**알림 유형:**
```java
public enum NotificationType {
    REPORT_CREATED("신고 접수"),
    REPORT_ASSIGNED("신고 배정"),
    STATUS_UPDATED("상태 변경"),
    COMMENT_ADDED("댓글 추가"),
    REPORT_COMPLETED("처리 완료"),
    SYSTEM_NOTICE("시스템 공지")
}
```

### 5. AI 라우팅 및 통합 (AI Routing & Integration)

#### AiRoutingController.java
```java
// 주요 엔드포인트
POST   /ai-routing/analyze      # AI 분석 및 라우팅
POST   /ai-routing/analyze/simple # 간단 분석
POST   /ai-routing/analyze/batch # 배치 분석
GET    /ai-routing/health       # AI 서비스 상태
GET    /ai-routing/stats        # AI 분석 통계
```

#### IntegratedAiAgentService.java
**핵심 기능:**
- OpenRouter API를 통한 텍스트 분석
- Roboflow 모델 라우팅 결정
- 비동기 AI 분석 처리
- 분석 결과 검증 및 후처리

**AI 워크플로우:**
```java
// AI 분석 파이프라인
public CompletableFuture<AnalysisResult> analyzeInputAsync(InputData inputData) {
    // 1. 입력 데이터 전처리
    // 2. OpenRouter로 텍스트 분석
    // 3. 적절한 Roboflow 모델 선택
    // 4. AI Analysis Server 호출
    // 5. 결과 검증 및 후처리
    // 6. 담당 부서 결정
    // 7. 우선순위 설정
}
```

### 6. 지리정보 서비스 (GIS Service)

#### GisService.java
**핵심 기능:**
- 좌표 유효성 검증
- 행정구역 판별
- 담당 부서 매핑
- 거리 계산
- 지도 데이터 처리

**지역별 담당 부서 매핑:**
```java
// 전북 14개 시군 담당 부서 자동 배정
private String determineDepartment(String administrativeDivision, String workspace) {
    return switch (administrativeDivision) {
        case "전주시" -> "전주시청 도로관리과";
        case "군산시" -> "군산시청 건설과";
        case "익산시" -> "익산시청 도시관리과";
        // ... 나머지 시군 매핑
        default -> "전북도청 도로교통과";
    };
}
```

## 🔗 외부 서비스 연동

### 1. AI Analysis Server 연동
```java
// 동기 호출
@Retryable(maxAttempts = 3)
public AIAnalysisResponse callAiAnalysisSync(AnalysisRequest request);

// 비동기 호출
public CompletableFuture<AIAnalysisResponse> callAiAnalysisAsync(AnalysisRequest request);
```

### 2. Roboflow API 연동
```java
// RoboflowApiClient.java
public CompletableFuture<RoboflowAnalysisResult> analyzeImageAsync(String imageData, String modelId);
public AnalysisResult analyzeWithQwen(MultipartFile image);
```

### 3. OpenRouter API 연동
```java
// OpenRouterApiClient.java
public OpenRouterDto.ChatResponse chatCompletion(OpenRouterDto.ChatRequest request);
public CompletableFuture<OpenRouterDto.ChatResponse> chatCompletionAsync(OpenRouterDto.ChatRequest request);
```

## 📊 데이터베이스 연동

### JPA 엔티티 설계
```java
@Entity
@Table(name = "reports")
public class Report {
    @Id
    @GeneratedValue(generator = "UUID")
    private UUID id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;
    
    @Column(name = "ai_analysis_results", columnDefinition = "jsonb")
    @JdbcTypeCode(SqlTypes.JSON)
    private JsonNode aiAnalysisResults;
    
    @Column(name = "location_point", columnDefinition = "geometry(Point,4326)")
    private Point locationPoint;
}
```

### Repository 패턴
```java
@Repository
public interface ReportRepository extends JpaRepository<Report, UUID> {
    Page<Report> findByUserIdAndDeletedAtIsNull(UUID userId, Pageable pageable);
    
    @Query("SELECT r FROM Report r WHERE ST_DWithin(r.locationPoint, :point, :distance)")
    List<Report> findNearbyReports(@Param("point") Point point, @Param("distance") double distance);
    
    @Query("SELECT COUNT(r) FROM Report r WHERE r.status = :status AND r.createdAt >= :startDate")
    long countByStatusAndCreatedAtAfter(@Param("status") ReportStatus status, @Param("startDate") LocalDateTime startDate);
}
```

## 🔧 설정 및 환경

### application.yml 주요 설정
```yaml
app:
  jwt:
    secret: ${JWT_SECRET}
    expiration: 86400000  # 24 hours
  
  roboflow:
    api-key: ${ROBOFLOW_API_KEY}
    workspace-url: ${ROBOFLOW_WORKSPACE_URL}
  
  openrouter:
    api:
      key: ${OPENROUTER_API_KEY}
      base-url: https://openrouter.ai/api/v1
      model: qwen/qwen2.5-vl-72b-instruct:free

spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/jeonbuk_report_db
  
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        dialect: org.hibernate.spatial.dialect.postgis.PostgisPG95Dialect
```

## 📈 성능 최적화

### 캐싱 전략
```java
@Cacheable(value = "reports", key = "#reportId")
public Report findById(UUID reportId);

@CacheEvict(value = "reports", key = "#report.id")
public Report updateReport(Report report);
```

### 비동기 처리
```java
@Async("taskExecutor")
public CompletableFuture<Void> sendNotificationAsync(Notification notification);

@Async("aiAnalysisExecutor")
public CompletableFuture<AIAnalysisResult> processAiAnalysisAsync(Report report);
```

### 페이징 및 정렬
```java
public Page<Report> getReports(ReportSearchCriteria criteria, Pageable pageable) {
    return reportRepository.findAll(
        ReportSpecification.withCriteria(criteria), 
        pageable
    );
}
```

## 🧪 테스트 전략

### 단위 테스트
```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    @Mock private UserRepository userRepository;
    @Mock private PasswordEncoder passwordEncoder;
    @InjectMocks private UserService userService;
    
    @Test
    void shouldCreateUserSuccessfully() {
        // Given, When, Then
    }
}
```

### 통합 테스트
```java
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ReportControllerIntegrationTest {
    @Autowired private MockMvc mockMvc;
    @Autowired private TestRestTemplate restTemplate;
    
    @Test
    void shouldCreateReportWithAuthentication() {
        // Test implementation
    }
}
```

---

*문서 버전: 1.0*  
*최종 업데이트: 2025년 7월 12일*  
*작성자: Main API Server 개발팀*