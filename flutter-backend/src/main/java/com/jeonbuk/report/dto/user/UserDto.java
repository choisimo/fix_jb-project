package com.jeonbuk.report.dto.user;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.jeonbuk.report.domain.user.User;
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
    @Pattern(regexp = "^(?=.*[a-zA-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$", 
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
