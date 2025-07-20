package com.jeonbuk.report.presentation.controller;

import com.jeonbuk.report.application.service.UserService;
import com.jeonbuk.report.domain.entity.User;
import com.jeonbuk.report.presentation.dto.request.UserRegistrationRequest;
import com.jeonbuk.report.presentation.dto.request.UserUpdateRequest;
import com.jeonbuk.report.presentation.dto.request.PasswordChangeRequest;
import com.jeonbuk.report.infrastructure.security.jwt.JwtTokenProvider;
import com.jeonbuk.report.presentation.dto.response.UserResponse;
import com.jeonbuk.report.presentation.dto.response.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;

/**
 * 사용자 관리 컨트롤러
 * - 사용자 등록, 조회, 수정, 삭제
 * - 권한 기반 접근 제어
 * - 관리자 전용 기능
 */
@Slf4j
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@Tag(name = "User Management", description = "사용자 관리 API")
public class UserController {

  private final UserService userService;
  private final JwtTokenProvider jwtTokenProvider;

  @Operation(summary = "JWT 로그인", description = "이메일/패스워드로 로그인하여 JWT 토큰을 발급합니다.")
  @PostMapping("/login")
  public ResponseEntity<ApiResponse<String>> login(@RequestParam String email, @RequestParam String password) {
    return userService.authenticateUser(email, password)
        .map(user -> {
          String token = jwtTokenProvider.createToken(user.getEmail());
          return ResponseEntity.ok(ApiResponse.success("로그인 성공", token));
        })
        .orElse(ResponseEntity.status(HttpStatus.UNAUTHORIZED)
            .body(ApiResponse.error("이메일 또는 패스워드가 올바르지 않습니다.")));
  }

  @Operation(summary = "사용자 등록", description = "새로운 사용자를 등록합니다. (관리자 전용)")
  @PostMapping("/register-admin")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<UserResponse>> registerUserByAdmin(
      @Valid @RequestBody UserRegistrationRequest request) {

    try {
      User user = userService.registerUser(
          request.getEmail(),
          request.getPassword(),
          request.getName(),
          request.getPhone(),
          request.getDepartment());

      UserResponse response = UserResponse.fromEntity(user);
      return ResponseEntity.status(HttpStatus.CREATED)
          .body(ApiResponse.success("사용자 등록이 완료되었습니다.", response));
    } catch (IllegalArgumentException e) {
      return ResponseEntity.badRequest()
          .body(ApiResponse.error(e.getMessage()));
    }
  }

  @Operation(summary = "사용자 프로필 조회", description = "현재 로그인한 사용자의 프로필을 조회합니다.")
  @GetMapping("/profile")
  @PreAuthorize("isAuthenticated()")
  public ResponseEntity<ApiResponse<UserResponse>> getProfile(
      @RequestParam UUID userId) { // 실제로는 SecurityContext에서 가져와야 함

    return userService.findById(userId)
        .map(user -> ResponseEntity.ok(
            ApiResponse.success("사용자 프로필을 조회했습니다.", UserResponse.fromEntity(user))))
        .orElse(ResponseEntity.notFound().build());
  }

  @Operation(summary = "사용자 정보 수정", description = "사용자 정보를 수정합니다.")
  @PutMapping("/{userId}")
  @PreAuthorize("isAuthenticated() and (#userId == authentication.principal.id or hasRole('ADMIN'))")
  public ResponseEntity<ApiResponse<UserResponse>> updateUser(
      @PathVariable UUID userId,
      @Valid @RequestBody UserUpdateRequest request) {

    try {
      User user = userService.updateUser(
          userId,
          request.getName(),
          request.getPhone(),
          request.getDepartment());

      UserResponse response = UserResponse.fromEntity(user);
      return ResponseEntity.ok(
          ApiResponse.success("사용자 정보가 수정되었습니다.", response));
    } catch (IllegalArgumentException e) {
      return ResponseEntity.badRequest()
          .body(ApiResponse.error(e.getMessage()));
    }
  }

  @Operation(summary = "패스워드 변경", description = "사용자 패스워드를 변경합니다.")
  @PutMapping("/{userId}/password")
  @PreAuthorize("isAuthenticated() and #userId == authentication.principal.id")
  public ResponseEntity<ApiResponse<Void>> changePassword(
      @PathVariable UUID userId,
      @Valid @RequestBody PasswordChangeRequest request) {

    try {
      userService.changePassword(userId, request.getCurrentPassword(), request.getNewPassword());
      return ResponseEntity.ok(
          ApiResponse.success("패스워드가 변경되었습니다.", null));
    } catch (IllegalArgumentException | IllegalStateException e) {
      return ResponseEntity.badRequest()
          .body(ApiResponse.error(e.getMessage()));
    }
  }

  @Operation(summary = "사용자 목록 조회", description = "사용자 목록을 조회합니다. (관리자 전용)")
  @GetMapping
  @PreAuthorize("hasRole('MANAGER') or hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<Page<UserResponse>>> getUsers(
      @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable,
      @RequestParam(required = false) String keyword) {

    Page<User> users;
    if (keyword != null && !keyword.trim().isEmpty()) {
      users = userService.searchUsers(keyword.trim(), pageable);
    } else {
      users = userService.findActiveUsers(pageable);
    }

    Page<UserResponse> response = users.map(UserResponse::fromEntity);
    return ResponseEntity.ok(
        ApiResponse.success("사용자 목록을 조회했습니다.", response));
  }

  @Operation(summary = "사용자 서비스 상태", description = "사용자 서비스의 상태를 확인합니다.")
  @GetMapping("/status")
  public ResponseEntity<ApiResponse<Map<String, Object>>> getUserServiceStatus() {
    try {
      long totalUsers = userService.getTotalUserCount();
      long activeUsers = userService.getActiveUserCount();
      
      Map<String, Object> status = new HashMap<>();
      status.put("service", "User Management Service");
      status.put("status", "ACTIVE");
      status.put("version", "1.0.0");
      status.put("statistics", Map.of(
        "totalUsers", totalUsers,
        "activeUsers", activeUsers,
        "inactiveUsers", totalUsers - activeUsers
      ));
      status.put("features", new String[]{
        "사용자 등록/수정",
        "프로필 관리",
        "권한 관리",
        "사용자 검색"
      });
      status.put("timestamp", System.currentTimeMillis());
      
      return ResponseEntity.ok(ApiResponse.success("사용자 서비스 상태 조회 완료", status));
    } catch (Exception e) {
      log.error("User service status error", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(ApiResponse.error("사용자 서비스 상태 조회 중 오류가 발생했습니다."));
    }
  }

  @Operation(summary = "사용자 상세 조회", description = "특정 사용자의 상세 정보를 조회합니다. (관리자 전용)")
  @GetMapping("/{userId}")
  @PreAuthorize("hasRole('MANAGER') or hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<UserResponse>> getUserById(@PathVariable UUID userId) {
    return userService.findById(userId)
        .map(user -> ResponseEntity.ok(
            ApiResponse.success("사용자 정보를 조회했습니다.", UserResponse.fromEntity(user))))
        .orElse(ResponseEntity.notFound().build());
  }

  @Operation(summary = "사용자 역할 변경", description = "사용자의 역할을 변경합니다. (관리자 전용)")
  @PutMapping("/{userId}/role")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<UserResponse>> changeUserRole(
      @PathVariable UUID userId,
      @RequestParam User.UserRole role) {

    try {
      User user = userService.changeUserRole(userId, role);
      UserResponse response = UserResponse.fromEntity(user);
      return ResponseEntity.ok(
          ApiResponse.success("사용자 역할이 변경되었습니다.", response));
    } catch (IllegalArgumentException e) {
      return ResponseEntity.badRequest()
          .body(ApiResponse.error(e.getMessage()));
    }
  }

  @Operation(summary = "사용자 활성화/비활성화", description = "사용자를 활성화 또는 비활성화합니다. (관리자 전용)")
  @PutMapping("/{userId}/toggle-active")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<UserResponse>> toggleUserActive(@PathVariable UUID userId) {
    try {
      User user = userService.toggleUserActive(userId);
      UserResponse response = UserResponse.fromEntity(user);
      return ResponseEntity.ok(
          ApiResponse.success("사용자 상태가 변경되었습니다.", response));
    } catch (IllegalArgumentException e) {
      return ResponseEntity.badRequest()
          .body(ApiResponse.error(e.getMessage()));
    }
  }

  @Operation(summary = "관리자 목록 조회", description = "관리자 사용자 목록을 조회합니다.")
  @GetMapping("/managers")
  @PreAuthorize("hasRole('MANAGER') or hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<List<UserResponse>>> getManagers() {
    List<User> managers = userService.getActiveManagers();
    List<UserResponse> response = managers.stream()
        .map(UserResponse::fromEntity)
        .collect(Collectors.toList());

    return ResponseEntity.ok(
        ApiResponse.success("관리자 목록을 조회했습니다.", response));
  }

  @Operation(summary = "사용자 통계", description = "사용자 관련 통계를 조회합니다. (관리자 전용)")
  @GetMapping("/statistics")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<Object>> getUserStatistics() {
    // 통계 정보 구성
    var statistics = new Object() {
      public final long totalUsers = userService.getTotalActiveUsers();
      public final long userCount = userService.getUserCountByRole(User.UserRole.USER);
      public final long managerCount = userService.getUserCountByRole(User.UserRole.MANAGER);
      public final long adminCount = userService.getUserCountByRole(User.UserRole.ADMIN);
      public final int recentlyActiveCount = userService.getRecentlyActiveUsers(7).size();
    };

    return ResponseEntity.ok(
        ApiResponse.success("사용자 통계를 조회했습니다.", statistics));
  }
}
