# 외부 서비스 연동 상세 가이드

## 🎯 외부 서비스 연동 개요

전북 신고 플랫폼은 다양한 외부 AI 서비스와 OAuth 제공자를 연동하여 **지능형 이미지 분석**, **자연어 처리**, **소셜 로그인** 기능을 제공합니다. 모든 외부 연동은 **안정성, 보안성, 확장성**을 고려하여 설계되었습니다.

## 🤖 AI 서비스 연동

### 1. Roboflow API 연동

#### 연동 개요
```
Service: Roboflow Computer Vision Platform
Purpose: 이미지 객체 감지 및 분류
API Version: v1
Documentation: https://docs.roboflow.com/
```

#### 연동 아키텍처
```
┌─────────────────┐    HTTPS/REST    ┌─────────────────┐
│ AI Analysis     │◄─────────────────►│ Roboflow API    │
│ Server          │                  │                 │
│                 │  POST /workspace │ • Object Detection│
│ • 이미지 전처리  │  /project/version │ • Image Classification│
│ • API 호출      │  ?api_key=xxx    │ • Confidence Scoring│
│ • 결과 후처리   │                  │ • Batch Processing│
│ • 오류 처리     │                  │                 │
└─────────────────┘                  └─────────────────┘
```

#### 설정 정보
```yaml
# AI Analysis Server application.yml
roboflow:
  api:
    key: ${ROBOFLOW_API_KEY}
    url: https://detect.roboflow.com
  workspace: ${ROBOFLOW_WORKSPACE}  # jeonbuk-infrastructure
  project: ${ROBOFLOW_PROJECT}      # road-facility-detection
  version: 1
  timeout:
    connection: 30000  # 30초
    read: 60000       # 60초
```

#### API 호출 예시
```java
// RoboflowService.java
public AIAnalysisResponse analyzeImage(AIAnalysisRequest request) {
    String url = String.format("%s/%s/%s/%s?api_key=%s&confidence=%.2f&overlap=%.2f",
        baseApiUrl, workspace, project, version, apiKey, 
        confidence, overlap);
    
    // 멀티파트 요청 구성
    MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
    body.add("file", new ByteArrayResource(request.getImage().getBytes()) {
        @Override
        public String getFilename() {
            return request.getImage().getOriginalFilename();
        }
    });
    
    HttpHeaders headers = new HttpHeaders();
    headers.setContentType(MediaType.MULTIPART_FORM_DATA);
    headers.set("User-Agent", "Jeonbuk-FieldReport/2.0.1");
    
    ResponseEntity<String> response = restTemplate.postForEntity(
        url, new HttpEntity<>(body, headers), String.class);
    
    return parseRoboflowResponse(response.getBody());
}
```

#### 응답 데이터 구조
```json
{
  "time": 1.23,
  "image": {
    "width": 640,
    "height": 480
  },
  "predictions": [
    {
      "x": 320.5,
      "y": 240.3,
      "width": 150.2,
      "height": 100.8,
      "confidence": 0.85,
      "class": "pothole",
      "class_id": 0,
      "detection_id": "abc123"
    }
  ],
  "inference_id": "xyz789"
}
```

#### 전북지역 특화 모델
```java
// 전북 인프라 문제 감지 모델
private final Map<String, String> jeonbukModels = Map.of(
    "도로관리", "jeonbuk-road-v3",           // 포트홀, 균열, 도로손상
    "시설관리", "jeonbuk-facility-v2",       // 가로등, 표지판, 벤치
    "환경관리", "jeonbuk-environment-v1",    // 쓰레기, 낙서, 불법투기
    "안전관리", "jeonbuk-safety-v2",         // 가드레일, 안전시설
    "교통관리", "jeonbuk-traffic-v1"         // 신호등, 교통표지
);
```

#### 오류 처리 및 재시도
```java
@Retryable(
    retryFor = {ResourceAccessException.class, HttpServerErrorException.class},
    maxAttempts = 3,
    backoff = @Backoff(delay = 1000, multiplier = 2)
)
public AIAnalysisResponse analyzeImageWithRetry(AIAnalysisRequest request) {
    try {
        return analyzeImage(request);
    } catch (HttpClientErrorException e) {
        if (e.getStatusCode() == HttpStatus.UNAUTHORIZED) {
            throw new RoboflowException("API 키가 유효하지 않습니다.", e);
        } else if (e.getStatusCode() == HttpStatus.TOO_MANY_REQUESTS) {
            throw new RoboflowException("API 호출 한도를 초과했습니다.", e);
        }
        throw new RoboflowException("Roboflow API 오류: " + e.getMessage(), e);
    }
}

@Recover
public AIAnalysisResponse recoverFromRoboflowError(Exception ex, AIAnalysisRequest request) {
    log.error("Roboflow API 호출 실패, 기본값 반환: {}", ex.getMessage());
    return createFallbackResponse();
}
```

### 2. OpenRouter API 연동

#### 연동 개요
```
Service: OpenRouter LLM Gateway
Purpose: 대화형 AI 및 텍스트 분석
API Version: v1
Models: Qwen2.5-VL-72B-Instruct, GPT-4, Claude-3
Documentation: https://openrouter.ai/docs
```

#### 연동 아키텍처
```
┌─────────────────┐    HTTPS/REST    ┌─────────────────┐
│ Main API        │◄─────────────────►│ OpenRouter API  │
│ Server          │                  │                 │
│                 │  POST /chat/     │ • LLM Chat      │
│ • 프롬프트 생성 │  completions     │ • Text Analysis │
│ • API 호출      │  Authorization:  │ • Vision Models │
│ • 응답 파싱     │  Bearer <key>    │ • Multi-modal   │
│ • 결과 통합     │                  │                 │
└─────────────────┘                  └─────────────────┘
```

#### API 호출 예시
```java
// OpenRouterApiClient.java
public OpenRouterDto.ChatResponse chatCompletion(OpenRouterDto.ChatRequest request) {
    HttpHeaders headers = new HttpHeaders();
    headers.setContentType(MediaType.APPLICATION_JSON);
    headers.setBearerAuth(apiKey);
    headers.set("HTTP-Referer", "https://jeonbuk-report.kr");
    headers.set("X-Title", "Jeonbuk Report Platform");
    
    HttpEntity<OpenRouterDto.ChatRequest> entity = new HttpEntity<>(request, headers);
    
    ResponseEntity<OpenRouterDto.ChatResponse> response = restTemplate.exchange(
        baseUrl + "/chat/completions",
        HttpMethod.POST,
        entity,
        OpenRouterDto.ChatResponse.class
    );
    
    return response.getBody();
}
```

#### 텍스트 분석 프롬프트 예시
```java
// IntegratedAiAgentService.java
private String buildAnalysisPrompt(InputData inputData) {
    return """
        다음 신고 내용을 분석하여 JSON 형식으로 결과를 반환해주세요:
        
        제목: %s
        설명: %s
        위치: %s
        
        다음 정보를 추출해주세요:
        {
          "objectType": "감지된 객체 유형 (pothole, traffic_sign, road_damage, infrastructure, general)",
          "damageType": "손상 정도 (minor, moderate, severe, critical)",
          "environment": "환경 정보 (urban, rural, highway, residential)",
          "priority": "우선순위 (low, medium, high, critical)",
          "category": "신고 카테고리",
          "keywords": ["관련", "키워드", "목록"],
          "confidence": 0.85
        }
        """.formatted(inputData.getTitle(), inputData.getDescription(), inputData.getLocation());
}
```

## 🔐 OAuth 소셜 로그인 연동

### 1. Google OAuth 2.0

#### 설정 정보
```yaml
# application.yml
spring:
  security:
    oauth2:
      client:
        registration:
          google:
            client-id: ${GOOGLE_CLIENT_ID}
            client-secret: ${GOOGLE_CLIENT_SECRET}
            scope: profile,email
            redirect-uri: "{baseUrl}/login/oauth2/code/google"
        provider:
          google:
            authorization-uri: https://accounts.google.com/o/oauth2/auth
            token-uri: https://oauth2.googleapis.com/token
            user-info-uri: https://www.googleapis.com/oauth2/v2/userinfo
            user-name-attribute: email
```

#### OAuth 핸들러 구현
```java
@Service
@RequiredArgsConstructor
public class OAuth2UserService extends DefaultOAuth2UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    
    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oauth2User = super.loadUser(userRequest);
        
        String registrationId = userRequest.getClientRegistration().getRegistrationId();
        String userNameAttributeName = userRequest.getClientRegistration()
            .getProviderDetails().getUserInfoEndpoint().getUserNameAttributeName();
        
        // OAuth 정보 추출
        Map<String, Object> attributes = oauth2User.getAttributes();
        OAuthAttributes oAuthAttributes = OAuthAttributes.of(registrationId, userNameAttributeName, attributes);
        
        // 사용자 생성 또는 업데이트
        User user = saveOrUpdateUser(oAuthAttributes);
        
        return new CustomOAuth2User(
            Collections.singleton(new SimpleGrantedAuthority("ROLE_" + user.getRole().name())),
            attributes,
            userNameAttributeName,
            user
        );
    }
    
    private User saveOrUpdateUser(OAuthAttributes attributes) {
        User user = userRepository.findByOauthProviderAndOauthId(
                attributes.getProvider(), attributes.getOauthId())
            .map(entity -> entity.update(attributes.getName(), attributes.getEmail()))
            .orElseGet(() -> User.builder()
                .email(attributes.getEmail())
                .name(attributes.getName())
                .oauthProvider(attributes.getProvider())
                .oauthId(attributes.getOauthId())
                .oauthEmail(attributes.getEmail())
                .role(User.UserRole.USER)
                .isActive(true)
                .emailVerified(true)
                .build());
        
        return userRepository.save(user);
    }
}
```

### 2. Kakao OAuth

#### 설정 정보
```yaml
spring:
  security:
    oauth2:
      client:
        registration:
          kakao:
            client-id: ${KAKAO_CLIENT_ID}
            client-secret: ${KAKAO_CLIENT_SECRET}
            client-authentication-method: client_secret_post
            authorization-grant-type: authorization_code
            redirect-uri: "{baseUrl}/login/oauth2/code/kakao"
            scope: profile_nickname,account_email
        provider:
          kakao:
            authorization-uri: https://kauth.kakao.com/oauth/authorize
            token-uri: https://kauth.kakao.com/oauth/token
            user-info-uri: https://kapi.kakao.com/v2/user/me
            user-name-attribute: id
```

#### Kakao 사용자 정보 파싱
```java
public class KakaoOAuthAttributes {
    public static OAuthAttributes of(Map<String, Object> attributes) {
        Map<String, Object> kakaoAccount = (Map<String, Object>) attributes.get("kakao_account");
        Map<String, Object> profile = (Map<String, Object>) kakaoAccount.get("profile");
        
        return OAuthAttributes.builder()
            .oauthId(String.valueOf(attributes.get("id")))
            .email((String) kakaoAccount.get("email"))
            .name((String) profile.get("nickname"))
            .provider("kakao")
            .attributes(attributes)
            .build();
    }
}
```

## 📱 알림 서비스 연동

### 1. Firebase Cloud Messaging (FCM)

#### 설정 및 초기화
```java
@Configuration
@EnableConfigurationProperties(FirebaseProperties.class)
public class FirebaseConfig {
    
    @Bean
    public FirebaseApp firebaseApp(FirebaseProperties properties) throws IOException {
        if (FirebaseApp.getApps().isEmpty()) {
            FileInputStream serviceAccount = new FileInputStream(properties.getServiceAccountPath());
            
            FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                .setDatabaseUrl(properties.getDatabaseUrl())
                .build();
            
            return FirebaseApp.initializeApp(options);
        }
        return FirebaseApp.getInstance();
    }
    
    @Bean
    public FirebaseMessaging firebaseMessaging(FirebaseApp firebaseApp) {
        return FirebaseMessaging.getInstance(firebaseApp);
    }
}
```

#### 푸시 알림 전송
```java
@Service
@RequiredArgsConstructor
public class PushNotificationService {
    
    private final FirebaseMessaging firebaseMessaging;
    
    public void sendReportStatusUpdate(String deviceToken, Report report) {
        Message message = Message.builder()
            .setToken(deviceToken)
            .setNotification(Notification.builder()
                .setTitle("신고 상태 업데이트")
                .setBody(String.format("'%s' 신고의 상태가 '%s'으로 변경되었습니다.", 
                    report.getTitle(), report.getStatus().getDescription()))
                .build())
            .putData("reportId", report.getId().toString())
            .putData("status", report.getStatus().name())
            .putData("type", "REPORT_STATUS_UPDATE")
            .setAndroidConfig(AndroidConfig.builder()
                .setPriority(AndroidConfig.Priority.HIGH)
                .build())
            .setApnsConfig(ApnsConfig.builder()
                .setAps(Aps.builder()
                    .setAlert(ApsAlert.builder()
                        .setTitle("신고 상태 업데이트")
                        .setBody("신고 처리 상태가 변경되었습니다.")
                        .build())
                    .setBadge(1)
                    .setSound("default")
                    .build())
                .build())
            .build();
        
        try {
            String response = firebaseMessaging.send(message);
            log.info("FCM 메시지 전송 성공: {}", response);
        } catch (FirebaseMessagingException e) {
            log.error("FCM 메시지 전송 실패: {}", e.getMessage(), e);
        }
    }
}
```

### 2. WebSocket 실시간 알림

#### WebSocket 설정
```java
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {
    
    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        config.enableSimpleBroker("/topic", "/queue");
        config.setApplicationDestinationPrefixes("/app");
        config.setUserDestinationPrefix("/user");
    }
    
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws")
            .setAllowedOriginPatterns("*")
            .withSockJS();
    }
}
```

#### 실시간 알림 브로드캐스트
```java
@Service
@RequiredArgsConstructor
public class WebSocketNotificationService {
    
    private final SimpMessagingTemplate messagingTemplate;
    
    public void notifyReportCreated(Report report) {
        Map<String, Object> notification = Map.of(
            "type", "REPORT_CREATED",
            "reportId", report.getId(),
            "title", report.getTitle(),
            "category", report.getCategory().getName(),
            "timestamp", System.currentTimeMillis()
        );
        
        // 담당 관리자들에게 알림
        messagingTemplate.convertAndSend("/topic/admin-alerts", notification);
        
        // 신고자에게 개인 알림
        messagingTemplate.convertAndSendToUser(
            report.getUser().getId().toString(),
            "/queue/notifications",
            notification
        );
    }
}
```

## 🔄 서비스 간 통신 패턴

### 1. 동기 HTTP 통신
```java
// Main API Server → AI Analysis Server
@Service
@RequiredArgsConstructor
public class AiAnalysisClient {
    
    private final RestTemplate restTemplate;
    
    @Value("${ai-analysis.base-url}")
    private String aiAnalysisBaseUrl;
    
    public AIAnalysisResponse analyzeImageSync(MultipartFile image) {
        String url = aiAnalysisBaseUrl + "/api/v1/analyze";
        
        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        body.add("image", image.getResource());
        body.add("confidence", 70);
        body.add("overlap", 30);
        
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);
        
        HttpEntity<MultiValueMap<String, Object>> requestEntity = 
            new HttpEntity<>(body, headers);
        
        return restTemplate.postForObject(url, requestEntity, AIAnalysisResponse.class);
    }
}
```

### 2. 비동기 메시지 큐 통신
```java
// Kafka를 통한 비동기 이벤트 발행
@Service
@RequiredArgsConstructor
public class ReportEventPublisher {
    
    private final KafkaTemplate<String, Object> kafkaTemplate;
    
    public void publishReportCreated(Report report) {
        ReportCreatedEvent event = ReportCreatedEvent.builder()
            .reportId(report.getId())
            .userId(report.getUser().getId())
            .category(report.getCategory().getName())
            .imageUrls(report.getFiles().stream()
                .map(ReportFile::getFileUrl)
                .collect(Collectors.toList()))
            .timestamp(Instant.now())
            .build();
        
        kafkaTemplate.send("image_requests", event);
    }
}

// AI Analysis Server에서 이벤트 처리
@KafkaListener(topics = "image_requests")
public void handleReportCreated(ReportCreatedEvent event) {
    log.info("AI 분석 요청 수신: reportId={}", event.getReportId());
    
    // 비동기로 이미지 분석 시작
    CompletableFuture.runAsync(() -> {
        try {
            AIAnalysisResponse result = analyzeReportImages(event);
            publishAnalysisResult(event.getReportId(), result);
        } catch (Exception e) {
            log.error("AI 분석 실패: reportId={}", event.getReportId(), e);
            publishAnalysisFailure(event.getReportId(), e.getMessage());
        }
    });
}
```

## 🛡️ 보안 및 오류 처리

### API 키 보안 관리
```java
@Component
public class ExternalApiKeyManager {
    
    @Value("${security.encryption.key}")
    private String encryptionKey;
    
    public String getDecryptedApiKey(String service) {
        String encryptedKey = systemSettingsService.getSetting(service + ".api.key");
        return decrypt(encryptedKey);
    }
    
    private String decrypt(String encryptedValue) {
        // AES 복호화 구현
        return aesDecrypt(encryptedValue, encryptionKey);
    }
}
```

### Circuit Breaker 패턴
```java
@Component
public class ExternalServiceCircuitBreaker {
    
    private final Map<String, Boolean> circuitStates = new ConcurrentHashMap<>();
    private final Map<String, Long> lastFailureTime = new ConcurrentHashMap<>();
    
    public boolean isServiceAvailable(String serviceName) {
        Boolean isOpen = circuitStates.get(serviceName);
        if (isOpen == null || !isOpen) {
            return true;
        }
        
        // 5분 후 재시도 허용
        Long lastFailure = lastFailureTime.get(serviceName);
        if (lastFailure != null && System.currentTimeMillis() - lastFailure > 300000) {
            circuitStates.put(serviceName, false);
            return true;
        }
        
        return false;
    }
    
    public void recordFailure(String serviceName) {
        circuitStates.put(serviceName, true);
        lastFailureTime.put(serviceName, System.currentTimeMillis());
    }
}
```

---

*문서 버전: 1.0*  
*최종 업데이트: 2025년 7월 12일*  
*작성자: 외부연동 개발팀*