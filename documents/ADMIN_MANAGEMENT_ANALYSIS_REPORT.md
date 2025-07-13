# 관리자 페이지 및 API 키 설정 관리 시스템 분석 보고서

## 📋 개요

전북 신고 플랫폼의 관리자 페이지 및 API 키 설정 관리 시스템에 대한 현재 구현 상태를 분석하고, 필요한 개선사항을 제시합니다.

---

## 🔍 현재 구현 상태 분석

### 1. 관리자 전용 페이지 현황

#### ❌ **현재 상태: 관리자 전용 페이지 미구현**

**발견된 내용:**
- 백엔드에는 `@PreAuthorize("hasRole('ADMIN')")` 어노테이션으로 관리자 권한 검증 로직 존재
- 프론트엔드 관리자 페이지는 **완전히 누락됨**
- 관리자가 시스템 설정을 변경할 수 있는 UI 인터페이스가 없음

**확인된 관리자 권한 API들:**
```java
// UserController.java
@PostMapping("/register-admin")
@PreAuthorize("hasRole('ADMIN')")
public ResponseEntity<ApiResponse<UserResponse>> registerUserByAdmin()

@PreAuthorize("hasRole('ADMIN')")
public ResponseEntity<ApiResponse<Void>> deleteUser()

@PreAuthorize("hasRole('ADMIN')")
public ResponseEntity<ApiResponse<UserStatsResponse>> getUserStats()
```

### 2. API 키 설정 관리 현황

#### ⚠️ **현재 상태: 환경변수 의존, 동적 변경 불가**

**현재 구현 방식:**
```yaml
# application.yml
app:
  roboflow:
    api-key: ${ROBOFLOW_API_KEY:your-roboflow-api-key}
    workspace-url: ${ROBOFLOW_WORKSPACE_URL:your-workspace-url}
  
  openrouter:
    api:
      key: ${OPENROUTER_API_KEY:your-openrouter-api-key}
      base-url: ${OPENROUTER_BASE_URL:https://openrouter.ai/api/v1}
      model: ${OPENROUTER_MODEL:qwen/qwen2.5-vl-72b-instruct:free}
```

**문제점:**
- API 키가 환경변수로만 설정되어 서버 재시작 없이는 변경 불가
- 관리자가 웹 인터페이스를 통해 API 키를 동적으로 변경할 수 없음
- API 키 변경 시 시스템 전체 재배포 필요

### 3. 데이터베이스 설정 저장소 현황

#### ✅ **데이터베이스 테이블은 준비됨**

**System Settings 테이블 구조:**
```sql
-- schema.sql (라인 208-216)
CREATE TABLE system_settings (
    key VARCHAR(100) PRIMARY KEY,
    value TEXT NOT NULL,
    description TEXT,
    data_type VARCHAR(20) DEFAULT 'string' CHECK (data_type IN ('string', 'number', 'boolean', 'json')),
    is_public BOOLEAN DEFAULT false, -- 클라이언트에서 접근 가능한지 여부
    updated_by UUID REFERENCES users(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

**문제점:**
- 테이블은 존재하지만 **이를 활용하는 비즈니스 로직이 전혀 구현되지 않음**
- API 키를 데이터베이스에서 읽어오는 서비스 없음
- 설정 변경을 위한 관리자 API 없음

### 4. 보안 및 인증 현황

#### ✅ **기본 보안 체계는 구축됨**

**구현된 보안 기능:**
- JWT 기반 인증 시스템
- 역할 기반 접근 제어 (RBAC): `USER`, `MANAGER`, `ADMIN`
- Spring Security PreAuthorize 어노테이션 활용
- CORS 설정 구현

**관리자 계정:**
```sql
-- data.sql (라인 30)
INSERT INTO users VALUES (
    '550e8400-e29b-41d4-a716-446655440000', 
    'admin@jeonbuk.go.kr', 
    '$2a$10$N9qo8uLOickgx2ZMRZoMye8IKDjT4v6RFJhGC5XXy5IxYHlE.E8m2', 
    '시스템 관리자', 
    '010-1234-5678', 
    '전북 전주시', 
    'ADMIN', 
    true, 
    NOW(), 
    NOW()
);
```

---

## 🚨 주요 문제점 및 누락 사항

### 1. **관리자 페이지 완전 누락**
- 관리자 전용 웹 UI가 전혀 존재하지 않음
- 시스템 설정, 사용자 관리, 통계 조회 등을 할 수 있는 인터페이스 없음
- API는 있지만 이를 호출할 수 있는 프론트엔드 없음

### 2. **동적 설정 관리 시스템 미구현**
- API 키 변경을 위해서는 서버 재시작 필요
- 데이터베이스 설정 테이블이 있지만 활용되지 않음
- 설정 변경 API와 서비스 로직 부재

### 3. **설정 관리 서비스 계층 부재**
- `SystemSettingsService` 또는 `ConfigurationService` 미구현
- 동적 설정 로딩 및 캐싱 메커니즘 없음
- API 키 유효성 검증 로직 부재

### 4. **관리자 기능 API 부족**
- API 키 CRUD 작업을 위한 API 없음
- 시스템 설정 변경 API 없음
- 설정 변경 이력 추적 기능 없음

---

## 💡 필수 구현 사항

### 1. **관리자 페이지 프론트엔드 개발**

#### 필요한 페이지들:
```
/admin
├── /dashboard          # 대시보드 (통계, 알림)
├── /settings          # 시스템 설정
│   ├── /api-keys      # API 키 관리
│   ├── /integrations  # 외부 서비스 연동 설정
│   └── /system        # 일반 시스템 설정
├── /users             # 사용자 관리
├── /reports           # 신고서 관리
├── /categories        # 카테고리 관리
└── /logs              # 시스템 로그 조회
```

#### 필요한 컴포넌트:
- **API 키 관리 인터페이스**
  - ROBOFLOW API 키 설정
  - OpenRouter API 키 설정
  - API 키 유효성 테스트 버튼
  - 키 마스킹 표시 (보안)

- **설정 변경 폼**
  - 실시간 저장 및 적용
  - 변경 이력 표시
  - 롤백 기능

### 2. **설정 관리 서비스 계층 구현**

#### SystemSettingsService 구현 필요:
```java
@Service
public class SystemSettingsService {
    // 설정 조회
    public String getSettingValue(String key);
    public <T> T getSettingValue(String key, Class<T> type);
    
    // 설정 변경
    public void updateSetting(String key, String value, UUID updatedBy);
    public void updateSettings(Map<String, String> settings, UUID updatedBy);
    
    // API 키 관리
    public void updateRoboflowApiKey(String apiKey, UUID updatedBy);
    public void updateOpenRouterApiKey(String apiKey, UUID updatedBy);
    
    // 유효성 검증
    public boolean validateApiKey(String service, String apiKey);
    
    // 캐시 관리
    public void refreshCache();
}
```

#### ConfigurationRefreshService 구현 필요:
```java
@Service
public class ConfigurationRefreshService {
    // 동적 설정 갱신 (서버 재시작 없이)
    public void refreshRoboflowConfiguration();
    public void refreshOpenRouterConfiguration();
    
    // 설정 적용 상태 확인
    public boolean isConfigurationValid(String service);
}
```

### 3. **관리자 API 엔드포인트 구현**

#### SystemSettingsController 구현 필요:
```java
@RestController
@RequestMapping("/admin/settings")
@PreAuthorize("hasRole('ADMIN')")
public class SystemSettingsController {
    
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllSettings();
    
    @GetMapping("/{key}")
    public ResponseEntity<SystemSetting> getSetting(@PathVariable String key);
    
    @PutMapping("/{key}")
    public ResponseEntity<Void> updateSetting(
        @PathVariable String key, 
        @RequestBody SettingUpdateRequest request
    );
    
    @PostMapping("/api-keys/validate")
    public ResponseEntity<ValidationResult> validateApiKey(
        @RequestBody ApiKeyValidationRequest request
    );
    
    @PostMapping("/refresh")
    public ResponseEntity<Void> refreshConfiguration();
}
```

### 4. **데이터베이스 활용 로직 구현**

#### SystemSetting 엔티티 구현:
```java
@Entity
@Table(name = "system_settings")
public class SystemSetting {
    @Id
    private String key;
    
    @Column(nullable = false)
    private String value;
    
    private String description;
    
    @Enumerated(EnumType.STRING)
    private DataType dataType;
    
    private Boolean isPublic;
    
    @ManyToOne
    @JoinColumn(name = "updated_by")
    private User updatedBy;
    
    private LocalDateTime updatedAt;
}
```

#### SystemSettingsRepository 구현:
```java
@Repository
public interface SystemSettingsRepository extends JpaRepository<SystemSetting, String> {
    List<SystemSetting> findByIsPublic(Boolean isPublic);
    List<SystemSetting> findByKeyStartingWith(String prefix);
    
    @Query("SELECT s FROM SystemSetting s WHERE s.key IN :keys")
    List<SystemSetting> findByKeys(@Param("keys") List<String> keys);
}
```

### 5. **동적 설정 로딩 메커니즘 구현**

#### ConfigurationProperties 동적 갱신:
```java
@Component
@ConfigurationProperties(prefix = "app")
@RefreshScope  // Spring Cloud Config 사용 시
public class DynamicAppProperties {
    private RoboflowProperties roboflow = new RoboflowProperties();
    private OpenRouterProperties openrouter = new OpenRouterProperties();
    
    // 데이터베이스에서 설정을 동적으로 로드
    @PostConstruct
    public void loadFromDatabase() {
        SystemSettingsService settingsService = 
            ApplicationContextProvider.getBean(SystemSettingsService.class);
        
        String roboflowApiKey = settingsService.getSettingValue("roboflow.api-key");
        if (roboflowApiKey != null) {
            roboflow.setApiKey(roboflowApiKey);
        }
        
        String openrouterApiKey = settingsService.getSettingValue("openrouter.api-key");
        if (openrouterApiKey != null) {
            openrouter.getApi().setKey(openrouterApiKey);
        }
    }
}
```

### 6. **API 키 보안 강화**

#### 암호화 저장:
```java
@Service
public class EncryptionService {
    public String encrypt(String plainText);
    public String decrypt(String encryptedText);
}

// SystemSettingsService에서 활용
public void updateApiKey(String key, String value, UUID updatedBy) {
    String encryptedValue = encryptionService.encrypt(value);
    systemSettingsRepository.save(new SystemSetting(key, encryptedValue, updatedBy));
    refreshConfigurationCache();
}
```

#### 키 마스킹:
```java
public class ApiKeyMasker {
    public static String maskApiKey(String apiKey) {
        if (apiKey == null || apiKey.length() < 8) {
            return "****";
        }
        String prefix = apiKey.substring(0, 4);
        String suffix = apiKey.substring(apiKey.length() - 4);
        return prefix + "****" + suffix;
    }
}
```

---

## 🛡️ 보안 고려사항

### 1. **API 키 보호**
- 데이터베이스 저장 시 AES 암호화 필수
- 로그에 API 키 노출 방지
- 프론트엔드에서 마스킹 처리

### 2. **접근 권한 제어**
- 설정 조회: `ADMIN` 또는 `MANAGER` 권한
- 설정 변경: `ADMIN` 권한만
- 감사 로그 기록 필수

### 3. **변경 이력 추적**
```sql
CREATE TABLE system_settings_audit (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    setting_key VARCHAR(100) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    changed_by UUID NOT NULL REFERENCES users(id),
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    change_reason TEXT
);
```

---

## 📋 구현 우선순위

### **1단계 (긴급) - 2주**
1. `SystemSettingsService` 구현
2. 기본 관리자 API 엔드포인트 개발
3. API 키 데이터베이스 저장 및 로딩 로직

### **2단계 (중요) - 4주**
1. 관리자 페이지 프론트엔드 개발
2. 동적 설정 갱신 메커니즘 구현
3. API 키 유효성 검증 기능

### **3단계 (개선) - 2주**
1. 설정 변경 이력 추적
2. 암호화 저장 구현
3. 감사 로그 시스템

---

## 🔧 기술 스택 권장사항

### **프론트엔드**
- **React.js** 또는 **Vue.js** (기존 Flutter와 별도)
- **Material-UI** 또는 **Ant Design** (관리자 UI 컴포넌트)
- **Chart.js** (통계 대시보드)

### **백엔드**
- **Spring Boot** (기존 구조 활용)
- **Spring Data JPA** (설정 엔티티 관리)
- **Spring Security** (권한 제어)
- **Spring Cache** (설정 캐싱)

### **보안**
- **AES-256** (API 키 암호화)
- **BCrypt** (관리자 비밀번호)
- **HTTPS** 강제 적용

---

## 📊 예상 효과

### **운영 효율성**
- API 키 변경 시 서버 재시작 불필요 → **배포 시간 90% 단축**
- 웹 인터페이스를 통한 직관적 설정 관리
- 실시간 설정 적용 및 검증

### **보안 강화**
- API 키 암호화 저장으로 보안 위험 최소화
- 변경 이력 추적으로 감사 추적성 확보
- 권한 기반 접근 제어로 무분별한 설정 변경 방지

### **개발 생산성**
- 개발/테스트 환경에서 쉬운 설정 변경
- 설정 변경으로 인한 장애 시 빠른 롤백 가능
- 통합된 관리 인터페이스로 관리 복잡성 감소

---

## 🎯 결론

현재 전북 신고 플랫폼은 **관리자 페이지가 완전히 누락**되어 있고, **API 키 관리가 정적 환경변수에만 의존**하고 있어 운영상 심각한 제약이 있습니다. 

**시급히 필요한 개선사항:**

1. **관리자 전용 웹 인터페이스 개발**
2. **동적 API 키 관리 시스템 구축** 
3. **데이터베이스 기반 설정 관리 로직 구현**
4. **보안 강화 및 감사 추적 시스템 도입**

이러한 개선을 통해 시스템의 **운영성, 보안성, 확장성**을 크게 향상시킬 수 있을 것입니다.

---

*보고서 작성일: 2025년 7월 12일*  
*작성자: 시스템 분석팀*