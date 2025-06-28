# 🏗️ 현장 보고 앱: Spring Boot 도메인 및 DTO 설계 가이드

## 📋 목차
- [1. 개요](#1-개요)
- [2. 도메인 엔티티 설계](#2-도메인-엔티티-설계)
- [3. DTO Record 설계](#3-dto-record-설계)
- [4. Mapper 설계](#4-mapper-설계)
- [5. 사용 예시](#5-사용-예시)

---

## 1. 개요

본 문서는 전북 현장 보고 시스템의 Spring Boot 백엔드를 위한 도메인 엔티티와 DTO 설계를 다룹니다.

### 🎯 설계 원칙
- **불변성**: DTO는 모두 `record` 타입으로 불변 객체 구현
- **명확성**: 도메인과 API 계층 간 명확한 책임 분리
- **검증**: Jakarta Bean Validation을 활용한 입력 검증
- **문서화**: Swagger/OpenAPI를 위한 상세한 어노테이션

### 🛠️ 기술 스택
```yaml
프레임워크: Spring Boot 3.x
ORM: Spring Data JPA + QueryDSL
검증: Jakarta Bean Validation
문서화: Swagger/OpenAPI 3
JSON 처리: Jackson
```

---

## 2. 도메인 엔티티 설계

### 2.1 공통 베이스 엔티티

```java
package com.jeonbuk.report.domain.common;

import jakarta.persistence.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public abstract class BaseEntity {
    
    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // Getters
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}
```

### 2.2 사용자 관련 엔티티

```java
package com.jeonbuk.report.domain.user;

import com.jeonbuk.report.domain.common.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "users")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class User extends BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Long id;
    
    @Column(name = "name", nullable = false, length = 50)
    private String name;
    
    @Column(name = "email", unique = true, nullable = false, length = 100)
    private String email;
    
    @Column(name = "password", length = 255)
    private String password;
    
    @Column(name = "phone_number", length = 20)
    private String phoneNumber;
    
    @Column(name = "department", length = 100)
    private String department;
    
    @Column(name = "profile_image_url", length = 255)
    private String profileImageUrl;
    
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = false;
    
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private Set<UserRole> userRoles = new HashSet<>();
    
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private Set<OAuthInfo> oauthInfos = new HashSet<>();
    
    @Builder
    public User(String name, String email, String password, String phoneNumber, 
                String department, String profileImageUrl, Boolean isActive) {
        this.name = name;
        this.email = email;
        this.password = password;
        this.phoneNumber = phoneNumber;
        this.department = department;
        this.profileImageUrl = profileImageUrl;
        this.isActive = isActive != null ? isActive : false;
    }
    
    // 비즈니스 메서드
    public void updateProfile(String name, String phoneNumber, String department) {
        this.name = name;
        this.phoneNumber = phoneNumber;
        this.department = department;
    }
    
    public void activate() {
        this.isActive = true;
    }
    
    public void deactivate() {
        this.isActive = false;
    }
}
```

### 2.3 보고서 관련 엔티티

```java
package com.jeonbuk.report.domain.report;

import com.jeonbuk.report.domain.common.BaseEntity;
import com.jeonbuk.report.domain.user.User;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Entity
@Table(name = "reports")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Report extends BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "report_id")
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id", nullable = false)
    private User author;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private ReportCategory category;
    
    @Column(name = "title", nullable = false, length = 255)
    private String title;
    
    @Column(name = "content", columnDefinition = "TEXT")
    private String content;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private ReportStatus status = ReportStatus.DRAFT;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "priority", nullable = false, length = 20)
    private ReportPriority priority = ReportPriority.MEDIUM;
    
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "location", columnDefinition = "jsonb")
    private Map<String, Object> location;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "approver_id")
    private User approver;
    
    @Column(name = "approved_at")
    private LocalDateTime approvedAt;
    
    @Column(name = "feedback", columnDefinition = "TEXT")
    private String feedback;
    
    @OneToMany(mappedBy = "report", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ReportFile> reportFiles = new ArrayList<>();
    
    @OneToMany(mappedBy = "report", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ReportSignature> reportSignatures = new ArrayList<>();
    
    @OneToMany(mappedBy = "report", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Comment> comments = new ArrayList<>();
    
    @Builder
    public Report(User author, ReportCategory category, String title, String content,
                  ReportStatus status, ReportPriority priority, Map<String, Object> location) {
        this.author = author;
        this.category = category;
        this.title = title;
        this.content = content;
        this.status = status != null ? status : ReportStatus.DRAFT;
        this.priority = priority != null ? priority : ReportPriority.MEDIUM;
        this.location = location;
    }
    
    // 비즈니스 메서드
    public void submit() {
        if (this.status != ReportStatus.DRAFT) {
            throw new IllegalStateException("초안 상태의 보고서만 제출할 수 있습니다.");
        }
        this.status = ReportStatus.SUBMITTED;
    }
    
    public void approve(User approver, String feedback) {
        if (this.status != ReportStatus.SUBMITTED) {
            throw new IllegalStateException("제출된 보고서만 승인할 수 있습니다.");
        }
        this.status = ReportStatus.APPROVED;
        this.approver = approver;
        this.approvedAt = LocalDateTime.now();
        this.feedback = feedback;
    }
    
    public void reject(User approver, String feedback) {
        if (this.status != ReportStatus.SUBMITTED) {
            throw new IllegalStateException("제출된 보고서만 반려할 수 있습니다.");
        }
        this.status = ReportStatus.REJECTED;
        this.approver = approver;
        this.approvedAt = LocalDateTime.now();
        this.feedback = feedback;
    }
    
    public void addFile(ReportFile reportFile) {
        this.reportFiles.add(reportFile);
        reportFile.setReport(this);
    }
    
    public void addSignature(ReportSignature signature) {
        this.reportSignatures.add(signature);
        signature.setReport(this);
    }
}
```

### 2.4 열거형 정의

```java
package com.jeonbuk.report.domain.report;

public enum ReportStatus {
    DRAFT("초안"),
    SUBMITTED("제출"),
    APPROVED("승인"),
    REJECTED("반려");
    
    private final String description;
    
    ReportStatus(String description) {
        this.description = description;
    }
    
    public String getDescription() {
        return description;
    }
}

public enum ReportPriority {
    LOW("낮음"),
    MEDIUM("보통"),
    HIGH("높음"),
    URGENT("긴급");
    
    private final String description;
    
    ReportPriority(String description) {
        this.description = description;
    }
    
    public String getDescription() {
        return description;
    }
}
```

---

## 3. DTO Record 설계

### 3.1 사용자 관련 DTO

```java
package com.jeonbuk.report.dto.user;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.*;

import java.time.LocalDateTime;
import java.util.Set;

/**
 * 사용자 등록 요청 DTO
 */
@Schema(description = "사용자 등록 요청")
public record UserCreateRequest(
    @Schema(description = "사용자 이름", example = "홍길동")
    @NotBlank(message = "이름은 필수입니다")
    @Size(max = 50, message = "이름은 50자 이하여야 합니다")
    String name,
    
    @Schema(description = "이메일 주소", example = "hong@example.com")
    @NotBlank(message = "이메일은 필수입니다")
    @Email(message = "올바른 이메일 형식이 아닙니다")
    @Size(max = 100, message = "이메일은 100자 이하여야 합니다")
    String email,
    
    @Schema(description = "비밀번호", example = "password123!")
    @NotBlank(message = "비밀번호는 필수입니다")
    @Size(min = 8, max = 255, message = "비밀번호는 8자 이상이어야 합니다")
    @Pattern(regexp = "^(?=.*[a-zA-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]", 
             message = "비밀번호는 영문, 숫자, 특수문자를 포함해야 합니다")
    String password,
    
    @Schema(description = "전화번호", example = "010-1234-5678")
    @Pattern(regexp = "^01[016789]-\\d{3,4}-\\d{4}$", 
             message = "올바른 전화번호 형식이 아닙니다")
    String phoneNumber,
    
    @Schema(description = "부서", example = "개발팀")
    @Size(max = 100, message = "부서명은 100자 이하여야 합니다")
    String department
) {
    
    /**
     * 도메인 엔티티로 변환
     */
    public User toEntity(String encodedPassword) {
        return User.builder()
            .name(name)
            .email(email)
            .password(encodedPassword)
            .phoneNumber(phoneNumber)
            .department(department)
            .isActive(false)
            .build();
    }
}

/**
 * 사용자 정보 수정 요청 DTO
 */
@Schema(description = "사용자 정보 수정 요청")
public record UserUpdateRequest(
    @Schema(description = "사용자 이름", example = "홍길동")
    @NotBlank(message = "이름은 필수입니다")
    @Size(max = 50, message = "이름은 50자 이하여야 합니다")
    String name,
    
    @Schema(description = "전화번호", example = "010-1234-5678")
    @Pattern(regexp = "^01[016789]-\\d{3,4}-\\d{4}$", 
             message = "올바른 전화번호 형식이 아닙니다")
    String phoneNumber,
    
    @Schema(description = "부서", example = "개발팀")
    @Size(max = 100, message = "부서명은 100자 이하여야 합니다")
    String department
) {}

/**
 * 사용자 응답 DTO
 */
@Schema(description = "사용자 정보 응답")
public record UserResponse(
    @Schema(description = "사용자 ID", example = "1")
    Long id,
    
    @Schema(description = "사용자 이름", example = "홍길동")
    String name,
    
    @Schema(description = "이메일 주소", example = "hong@example.com")
    String email,
    
    @Schema(description = "전화번호", example = "010-1234-5678")
    String phoneNumber,
    
    @Schema(description = "부서", example = "개발팀")
    String department,
    
    @Schema(description = "프로필 이미지 URL")
    String profileImageUrl,
    
    @Schema(description = "계정 활성화 여부", example = "true")
    Boolean isActive,
    
    @Schema(description = "사용자 역할 목록")
    Set<String> roles,
    
    @Schema(description = "생성일시")
    @JsonProperty("createdAt")
    LocalDateTime createdAt,
    
    @Schema(description = "수정일시")
    @JsonProperty("updatedAt")
    LocalDateTime updatedAt
) {
    
    /**
     * User 엔티티에서 DTO로 변환하는 정적 팩토리 메서드
     */
    public static UserResponse from(User user) {
        Set<String> roleNames = user.getUserRoles().stream()
            .map(userRole -> userRole.getRole().getRoleName())
            .collect(java.util.stream.Collectors.toSet());
            
        return new UserResponse(
            user.getId(),
            user.getName(),
            user.getEmail(),
            user.getPhoneNumber(),
            user.getDepartment(),
            user.getProfileImageUrl(),
            user.getIsActive(),
            roleNames,
            user.getCreatedAt(),
            user.getUpdatedAt()
        );
    }
}

/**
 * 사용자 목록 조회용 간단한 DTO
 */
@Schema(description = "사용자 목록 응답")
public record UserSummaryResponse(
    @Schema(description = "사용자 ID", example = "1")
    Long id,
    
    @Schema(description = "사용자 이름", example = "홍길동")
    String name,
    
    @Schema(description = "이메일 주소", example = "hong@example.com")
    String email,
    
    @Schema(description = "부서", example = "개발팀")
    String department,
    
    @Schema(description = "계정 활성화 여부", example = "true")
    Boolean isActive
) {
    
    public static UserSummaryResponse from(User user) {
        return new UserSummaryResponse(
            user.getId(),
            user.getName(),
            user.getEmail(),
            user.getDepartment(),
            user.getIsActive()
        );
    }
}
```

### 3.2 보고서 관련 DTO

```java
package com.jeonbuk.report.dto.report;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.jeonbuk.report.domain.report.*;
import com.jeonbuk.report.dto.user.UserSummaryResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 보고서 생성 요청 DTO
 */
@Schema(description = "보고서 생성 요청")
public record ReportCreateRequest(
    @Schema(description = "카테고리 ID", example = "1")
    @NotNull(message = "카테고리는 필수입니다")
    @Positive(message = "카테고리 ID는 양수여야 합니다")
    Long categoryId,
    
    @Schema(description = "보고서 제목", example = "긴급 안전 점검 보고")
    @NotBlank(message = "제목은 필수입니다")
    @Size(max = 255, message = "제목은 255자 이하여야 합니다")
    String title,
    
    @Schema(description = "보고서 내용", example = "현장에서 발견된 안전상 문제점에 대한 상세 보고...")
    @Size(max = 10000, message = "내용은 10,000자 이하여야 합니다")
    String content,
    
    @Schema(description = "우선순위", example = "HIGH", allowableValues = {"LOW", "MEDIUM", "HIGH", "URGENT"})
    ReportPriority priority,
    
    @Schema(description = "위치 정보")
    @Valid
    LocationInfo location,
    
    @Schema(description = "첨부 파일 목록")
    @Valid
    List<ReportFileRequest> files,
    
    @Schema(description = "서명 정보")
    @Valid
    ReportSignatureRequest signature
) {
    
    public Report toEntity(User author, ReportCategory category) {
        Map<String, Object> locationMap = location != null ? 
            Map.of(
                "latitude", location.latitude(),
                "longitude", location.longitude(),
                "address", location.address() != null ? location.address() : ""
            ) : null;
            
        return Report.builder()
            .author(author)
            .category(category)
            .title(title)
            .content(content)
            .priority(priority != null ? priority : ReportPriority.MEDIUM)
            .location(locationMap)
            .build();
    }
}

/**
 * 위치 정보 DTO
 */
@Schema(description = "위치 정보")
public record LocationInfo(
    @Schema(description = "위도", example = "35.824776")
    @NotNull(message = "위도는 필수입니다")
    @DecimalMin(value = "-90.0", message = "위도는 -90 이상이어야 합니다")
    @DecimalMax(value = "90.0", message = "위도는 90 이하여야 합니다")
    Double latitude,
    
    @Schema(description = "경도", example = "127.148029")
    @NotNull(message = "경도는 필수입니다")
    @DecimalMin(value = "-180.0", message = "경도는 -180 이상이어야 합니다")
    @DecimalMax(value = "180.0", message = "경도는 180 이하여야 합니다")
    Double longitude,
    
    @Schema(description = "주소", example = "전북 전주시 덕진구 백제대로 567")
    @Size(max = 500, message = "주소는 500자 이하여야 합니다")
    String address
) {}

/**
 * 보고서 파일 요청 DTO
 */
@Schema(description = "보고서 파일 정보")
public record ReportFileRequest(
    @Schema(description = "파일 URL", example = "https://storage.example.com/files/image1.jpg")
    @NotBlank(message = "파일 URL은 필수입니다")
    @Size(max = 512, message = "파일 URL은 512자 이하여야 합니다")
    String fileUrl,
    
    @Schema(description = "파일 타입", example = "IMAGE", allowableValues = {"IMAGE", "VIDEO", "DOCUMENT"})
    @NotBlank(message = "파일 타입은 필수입니다")
    String fileType,
    
    @Schema(description = "파일 설명", example = "현장 사진 1")
    @Size(max = 500, message = "파일 설명은 500자 이하여야 합니다")
    String description,
    
    @Schema(description = "정렬 순서", example = "1")
    @Min(value = 0, message = "정렬 순서는 0 이상이어야 합니다")
    Integer sortOrder
) {
    
    public ReportFile toEntity(Report report) {
        return ReportFile.builder()
            .report(report)
            .fileUrl(fileUrl)
            .fileType(fileType)
            .description(description)
            .sortOrder(sortOrder != null ? sortOrder : 0)
            .build();
    }
}

/**
 * 보고서 서명 요청 DTO
 */
@Schema(description = "보고서 서명 정보")
public record ReportSignatureRequest(
    @Schema(description = "서명 이미지 URL", example = "https://storage.example.com/signatures/sign1.png")
    @NotBlank(message = "서명 URL은 필수입니다")
    @Size(max = 512, message = "서명 URL은 512자 이하여야 합니다")
    String signatureUrl
) {
    
    public ReportSignature toEntity(Report report) {
        return ReportSignature.builder()
            .report(report)
            .signatureUrl(signatureUrl)
            .build();
    }
}

/**
 * 보고서 상세 응답 DTO
 */
@Schema(description = "보고서 상세 정보")
public record ReportDetailResponse(
    @Schema(description = "보고서 ID", example = "1")
    Long id,
    
    @Schema(description = "작성자 정보")
    UserSummaryResponse author,
    
    @Schema(description = "카테고리 정보")
    ReportCategoryResponse category,
    
    @Schema(description = "제목", example = "긴급 안전 점검 보고")
    String title,
    
    @Schema(description = "내용", example = "현장에서 발견된 안전상 문제점...")
    String content,
    
    @Schema(description = "상태", example = "SUBMITTED")
    ReportStatus status,
    
    @Schema(description = "우선순위", example = "HIGH")
    ReportPriority priority,
    
    @Schema(description = "위치 정보")
    LocationInfo location,
    
    @Schema(description = "승인자 정보")
    UserSummaryResponse approver,
    
    @Schema(description = "승인/반려 일시")
    @JsonProperty("approvedAt")
    LocalDateTime approvedAt,
    
    @Schema(description = "피드백")
    String feedback,
    
    @Schema(description = "첨부 파일 목록")
    List<ReportFileResponse> files,
    
    @Schema(description = "서명 목록")
    List<ReportSignatureResponse> signatures,
    
    @Schema(description = "댓글 목록")
    List<CommentResponse> comments,
    
    @Schema(description = "생성일시")
    @JsonProperty("createdAt")
    LocalDateTime createdAt,
    
    @Schema(description = "수정일시")
    @JsonProperty("updatedAt")
    LocalDateTime updatedAt
) {
    
    public static ReportDetailResponse from(Report report) {
        LocationInfo locationInfo = null;
        if (report.getLocation() != null) {
            Map<String, Object> loc = report.getLocation();
            locationInfo = new LocationInfo(
                (Double) loc.get("latitude"),
                (Double) loc.get("longitude"),
                (String) loc.get("address")
            );
        }
        
        return new ReportDetailResponse(
            report.getId(),
            UserSummaryResponse.from(report.getAuthor()),
            ReportCategoryResponse.from(report.getCategory()),
            report.getTitle(),
            report.getContent(),
            report.getStatus(),
            report.getPriority(),
            locationInfo,
            report.getApprover() != null ? UserSummaryResponse.from(report.getApprover()) : null,
            report.getApprovedAt(),
            report.getFeedback(),
            report.getReportFiles().stream()
                .map(ReportFileResponse::from)
                .toList(),
            report.getReportSignatures().stream()
                .map(ReportSignatureResponse::from)
                .toList(),
            report.getComments().stream()
                .map(CommentResponse::from)
                .toList(),
            report.getCreatedAt(),
            report.getUpdatedAt()
        );
    }
}

/**
 * 보고서 목록 조회용 요약 DTO
 */
@Schema(description = "보고서 목록 응답")
public record ReportSummaryResponse(
    @Schema(description = "보고서 ID", example = "1")
    Long id,
    
    @Schema(description = "제목", example = "긴급 안전 점검 보고")
    String title,
    
    @Schema(description = "작성자명", example = "홍길동")
    String authorName,
    
    @Schema(description = "카테고리명", example = "안전")
    String categoryName,
    
    @Schema(description = "상태", example = "SUBMITTED")
    ReportStatus status,
    
    @Schema(description = "우선순위", example = "HIGH")
    ReportPriority priority,
    
    @Schema(description = "생성일시")
    @JsonProperty("createdAt")
    LocalDateTime createdAt
) {
    
    public static ReportSummaryResponse from(Report report) {
        return new ReportSummaryResponse(
            report.getId(),
            report.getTitle(),
            report.getAuthor().getName(),
            report.getCategory() != null ? report.getCategory().getName() : null,
            report.getStatus(),
            report.getPriority(),
            report.getCreatedAt()
        );
    }
}

/**
 * 보고서 상태 변경 요청 DTO
 */
@Schema(description = "보고서 상태 변경 요청")
public record ReportStatusUpdateRequest(
    @Schema(description = "변경할 상태", example = "APPROVED", allowableValues = {"APPROVED", "REJECTED"})
    @NotNull(message = "상태는 필수입니다")
    ReportStatus status,
    
    @Schema(description = "피드백", example = "검토 완료하였습니다.")
    @Size(max = 1000, message = "피드백은 1,000자 이하여야 합니다")
    String feedback
) {}
```

### 3.3 검색 및 페이징 DTO

```java
package com.jeonbuk.report.dto.common;

import com.jeonbuk.report.domain.report.ReportPriority;
import com.jeonbuk.report.domain.report.ReportStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 보고서 검색 조건 DTO
 */
@Schema(description = "보고서 검색 조건")
public record ReportSearchCondition(
    @Schema(description = "검색 키워드 (제목, 내용에서 검색)", example = "안전")
    @Size(max = 100, message = "검색 키워드는 100자 이하여야 합니다")
    String keyword,
    
    @Schema(description = "상태 목록", example = "[\"SUBMITTED\", \"APPROVED\"]")
    List<ReportStatus> statuses,
    
    @Schema(description = "우선순위 목록", example = "[\"HIGH\", \"URGENT\"]")
    List<ReportPriority> priorities,
    
    @Schema(description = "카테고리 ID 목록", example = "[1, 2, 3]")
    List<Long> categoryIds,
    
    @Schema(description = "작성자 ID", example = "123")
    Long authorId,
    
    @Schema(description = "승인자 ID", example = "456")
    Long approverId,
    
    @Schema(description = "검색 시작일")
    LocalDateTime startDate,
    
    @Schema(description = "검색 종료일")
    LocalDateTime endDate
) {}

/**
 * 페이징 요청 DTO
 */
@Schema(description = "페이징 요청")
public record PageRequest(
    @Schema(description = "페이지 번호 (0부터 시작)", example = "0", defaultValue = "0")
    @Min(value = 0, message = "페이지 번호는 0 이상이어야 합니다")
    Integer page,
    
    @Schema(description = "페이지 크기", example = "20", defaultValue = "20")
    @Min(value = 1, message = "페이지 크기는 1 이상이어야 합니다")
    Integer size,
    
    @Schema(description = "정렬 기준", example = "createdAt", defaultValue = "createdAt")
    String sortBy,
    
    @Schema(description = "정렬 방향", example = "DESC", defaultValue = "DESC", allowableValues = {"ASC", "DESC"})
    String sortDirection
) {
    
    public Pageable toPageable() {
        int pageNumber = page != null ? page : 0;
        int pageSize = size != null ? size : 20;
        String sort = sortBy != null ? sortBy : "createdAt";
        Sort.Direction direction = "ASC".equalsIgnoreCase(sortDirection) ? 
            Sort.Direction.ASC : Sort.Direction.DESC;
            
        return PageRequest.of(pageNumber, pageSize, Sort.by(direction, sort));
    }
}

/**
 * 페이징 응답 DTO
 */
@Schema(description = "페이징 응답")
public record PageResponse<T>(
    @Schema(description = "데이터 목록")
    List<T> content,
    
    @Schema(description = "현재 페이지 번호", example = "0")
    int page,
    
    @Schema(description = "페이지 크기", example = "20")
    int size,
    
    @Schema(description = "전체 데이터 수", example = "150")
    long totalElements,
    
    @Schema(description = "전체 페이지 수", example = "8")
    int totalPages,
    
    @Schema(description = "첫 번째 페이지 여부", example = "true")
    boolean first,
    
    @Schema(description = "마지막 페이지 여부", example = "false")
    boolean last,
    
    @Schema(description = "비어있는 페이지 여부", example = "false")
    boolean empty
) {
    
    public static <T> PageResponse<T> from(org.springframework.data.domain.Page<T> page) {
        return new PageResponse<>(
            page.getContent(),
            page.getNumber(),
            page.getSize(),
            page.getTotalElements(),
            page.getTotalPages(),
            page.isFirst(),
            page.isLast(),
            page.isEmpty()
        );
    }
}
```

### 3.4 API 응답 공통 DTO

```java
package com.jeonbuk.report.dto.common;

import com.fasterxml.jackson.annotation.JsonInclude;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

/**
 * API 공통 응답 DTO
 */
@Schema(description = "API 응답")
@JsonInclude(JsonInclude.Include.NON_NULL)
public record ApiResponse<T>(
    @Schema(description = "성공 여부", example = "true")
    boolean success,
    
    @Schema(description = "응답 메시지", example = "요청이 성공적으로 처리되었습니다.")
    String message,
    
    @Schema(description = "응답 데이터")
    T data,
    
    @Schema(description = "에러 코드", example = "USER_NOT_FOUND")
    String errorCode,
    
    @Schema(description = "응답 시간")
    LocalDateTime timestamp
) {
    
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(
            true,
            "요청이 성공적으로 처리되었습니다.",
            data,
            null,
            LocalDateTime.now()
        );
    }
    
    public static <T> ApiResponse<T> success(String message, T data) {
        return new ApiResponse<>(
            true,
            message,
            data,
            null,
            LocalDateTime.now()
        );
    }
    
    public static <T> ApiResponse<T> error(String message, String errorCode) {
        return new ApiResponse<>(
            false,
            message,
            null,
            errorCode,
            LocalDateTime.now()
        );
    }
}

/**
 * 에러 응답 DTO
 */
@Schema(description = "에러 응답")
public record ErrorResponse(
    @Schema(description = "에러 코드", example = "VALIDATION_FAILED")
    String errorCode,
    
    @Schema(description = "에러 메시지", example = "입력값 검증에 실패했습니다.")
    String message,
    
    @Schema(description = "상세 에러 정보")
    Object details,
    
    @Schema(description = "발생 시간")
    LocalDateTime timestamp
) {
    
    public static ErrorResponse of(String errorCode, String message) {
        return new ErrorResponse(errorCode, message, null, LocalDateTime.now());
    }
    
    public static ErrorResponse of(String errorCode, String message, Object details) {
        return new ErrorResponse(errorCode, message, details, LocalDateTime.now());
    }
}
```

---

## 4. Mapper 설계

### 4.1 MapStruct를 활용한 매퍼

```java
package com.jeonbuk.report.mapper;

import com.jeonbuk.report.domain.report.Report;
import com.jeonbuk.report.domain.user.User;
import com.jeonbuk.report.dto.report.ReportDetailResponse;
import com.jeonbuk.report.dto.report.ReportSummaryResponse;
import com.jeonbuk.report.dto.user.UserResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;

import java.util.List;

@Mapper(
    componentModel = "spring",
    unmappedTargetPolicy = ReportingPolicy.IGNORE
)
public interface ReportMapper {
    
    @Mapping(target = "author", source = "author")
    @Mapping(target = "category", source = "category")
    @Mapping(target = "files", source = "reportFiles")
    @Mapping(target = "signatures", source = "reportSignatures")
    ReportDetailResponse toDetailResponse(Report report);
    
    @Mapping(target = "authorName", source = "author.name")
    @Mapping(target = "categoryName", source = "category.name")
    ReportSummaryResponse toSummaryResponse(Report report);
    
    List<ReportSummaryResponse> toSummaryResponseList(List<Report> reports);
}

@Mapper(componentModel = "spring")
public interface UserMapper {
    
    @Mapping(target = "roles", expression = "java(mapRoles(user))")
    UserResponse toResponse(User user);
    
    List<UserResponse> toResponseList(List<User> users);
    
    default Set<String> mapRoles(User user) {
        return user.getUserRoles().stream()
            .map(userRole -> userRole.getRole().getRoleName())
            .collect(java.util.stream.Collectors.toSet());
    }
}
```

---

## 5. 사용 예시

### 5.1 Controller에서의 사용

```java
package com.jeonbuk.report.controller;

import com.jeonbuk.report.dto.common.ApiResponse;
import com.jeonbuk.report.dto.common.PageResponse;
import com.jeonbuk.report.dto.report.*;
import com.jeonbuk.report.service.ReportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Tag(name = "보고서", description = "보고서 관리 API")
@RestController
@RequestMapping("/api/reports")
@RequiredArgsConstructor
public class ReportController {
    
    private final ReportService reportService;
    
    @Operation(summary = "보고서 생성", description = "새로운 보고서를 생성합니다.")
    @PostMapping
    public ResponseEntity<ApiResponse<Long>> createReport(
            @Valid @RequestBody ReportCreateRequest request,
            @AuthenticationPrincipal String username) {
        
        Long reportId = reportService.createReport(request, username);
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success("보고서가 생성되었습니다.", reportId));
    }
    
    @Operation(summary = "보고서 목록 조회", description = "보고서 목록을 페이징하여 조회합니다.")
    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<ReportSummaryResponse>>> getReports(
            @Valid @ModelAttribute ReportSearchCondition condition,
            @Valid @ModelAttribute com.jeonbuk.report.dto.common.PageRequest pageRequest) {
        
        Page<ReportSummaryResponse> reports = reportService.getReports(condition, pageRequest.toPageable());
        PageResponse<ReportSummaryResponse> response = PageResponse.from(reports);
        
        return ResponseEntity.ok(ApiResponse.success(response));
    }
    
    @Operation(summary = "보고서 상세 조회", description = "보고서 상세 정보를 조회합니다.")
    @GetMapping("/{reportId}")
    public ResponseEntity<ApiResponse<ReportDetailResponse>> getReport(@PathVariable Long reportId) {
        ReportDetailResponse report = reportService.getReport(reportId);
        return ResponseEntity.ok(ApiResponse.success(report));
    }
    
    @Operation(summary = "보고서 상태 변경", description = "보고서의 상태를 변경합니다.")
    @PatchMapping("/{reportId}/status")
    public ResponseEntity<ApiResponse<Void>> updateReportStatus(
            @PathVariable Long reportId,
            @Valid @RequestBody ReportStatusUpdateRequest request,
            @AuthenticationPrincipal String username) {
        
        reportService.updateReportStatus(reportId, request, username);
        return ResponseEntity.ok(ApiResponse.success("보고서 상태가 변경되었습니다.", null));
    }
}
```

### 5.2 Service에서의 사용

```java
package com.jeonbuk.report.service;

import com.jeonbuk.report.dto.report.*;
import com.jeonbuk.report.dto.common.ReportSearchCondition;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface ReportService {
    
    /**
     * 보고서 생성
     */
    Long createReport(ReportCreateRequest request, String username);
    
    /**
     * 보고서 목록 조회
     */
    Page<ReportSummaryResponse> getReports(ReportSearchCondition condition, Pageable pageable);
    
    /**
     * 보고서 상세 조회
     */
    ReportDetailResponse getReport(Long reportId);
    
    /**
     * 보고서 상태 변경
     */
    void updateReportStatus(Long reportId, ReportStatusUpdateRequest request, String username);
}
```

---

## 📋 정리

이 설계는 다음과 같은 특징을 가집니다:

### ✅ 장점
- **불변성**: Record 타입으로 데이터 불변성 보장
- **검증**: Jakarta Bean Validation으로 입력값 검증
- **문서화**: Swagger 어노테이션으로 API 문서 자동 생성
- **타입 안전성**: 컴파일 타임에 타입 검증
- **성능**: 불필요한 객체 생성 최소화

### 🎯 사용 시 주의사항
- Record는 Java 14+에서 사용 가능
- MapStruct 의존성 추가 필요
- 검증 어노테이션은 Controller에서 `@Valid` 어노테이션과 함께 사용
- 복잡한 비즈니스 로직은 Domain Entity에서 처리

이 설계를 통해 유지보수하기 쉽고 확장 가능한 Spring Boot 애플리케이션을 구축할 수 있습니다.
