package com.jeonbuk.report.presentation.controller;

import com.jeonbuk.report.application.service.UserService;
import com.jeonbuk.report.domain.entity.User;
import com.jeonbuk.report.presentation.dto.request.UserRegistrationRequest;
import com.jeonbuk.report.presentation.dto.request.UserUpdateRequest;
import com.jeonbuk.report.presentation.dto.request.PasswordChangeRequest;
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
import java.util.stream.Collectors;

/**
 * 사용자 관리 컨트롤러
 * - 사용자 등록, 조회, 수정, 삭제
 * - 권한 기반 접근 제어
 * - 관리자 전용 기능
 */
@Slf4j
@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
@Tag(name = "User Management", description = "사용자 관리 API")
public class UserController {

  private final UserService userService;

  @Operation(summary = "사용자 등록", description = "새로운 사용자를 등록합니다.")
  @PostMapping("/register")
  public ResponseEntity<ApiResponse<UserResponse>> registerUser(
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
