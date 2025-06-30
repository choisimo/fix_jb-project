package com.jeonbuk.report.presentation.controller;

import com.jeonbuk.report.application.service.UserService;
import com.jeonbuk.report.domain.entity.User;
import com.jeonbuk.report.dto.user.*;
import com.jeonbuk.report.dto.common.ApiResponse;
import com.jeonbuk.report.presentation.dto.request.UserRegistrationRequest;
import com.jeonbuk.report.presentation.dto.request.PasswordChangeRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * 사용자 관리 컨트롤러
 */
@Tag(name = "User", description = "사용자 관리 API")
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@Slf4j
public class UserController {

  private final UserService userService;

  /**
   * 사용자 등록
   */
  @Operation(summary = "사용자 등록", description = "새로운 사용자를 등록합니다.")
  @PostMapping("/register")
  public ResponseEntity<ApiResponse<UserResponse>> registerUser(
      @Valid @RequestBody UserRegistrationRequest request) {
    try {
      log.info("사용자 등록 요청: {}", request.email());
      
      User user = userService.registerUser(
          request.email(),
          request.password(),
          request.realName(),
          request.phoneNumber(),
          request.department());
      
      UserResponse response = UserResponse.fromEntity(user);
      return ResponseEntity.status(HttpStatus.CREATED)
          .body(ApiResponse.success(response));
    } catch (Exception e) {
      log.error("사용자 등록 실패", e);
      return ResponseEntity.status(HttpStatus.BAD_REQUEST)
          .body(ApiResponse.error("사용자 등록에 실패했습니다: " + e.getMessage()));
    }
  }

  /**
   * 사용자 정보 조회
   */
  @Operation(summary = "사용자 정보 조회", description = "사용자 ID로 정보를 조회합니다.")
  @GetMapping("/{userId}")
  @PreAuthorize("hasRole('ADMIN') or #userId == authentication.principal.id")
  public ResponseEntity<ApiResponse<UserResponse>> getUser(
      @Parameter(description = "사용자 ID") @PathVariable UUID userId) {
    try {
      log.info("사용자 조회 요청: {}", userId);
      
      User user = userService.findById(userId).orElseThrow(() -> 
          new RuntimeException("사용자를 찾을 수 없습니다"));
      UserResponse response = UserResponse.fromEntity(user);
      return ResponseEntity.ok(ApiResponse.success(response));
    } catch (Exception e) {
      log.error("사용자 조회 실패", e);
      return ResponseEntity.status(HttpStatus.NOT_FOUND)
          .body(ApiResponse.error("사용자를 찾을 수 없습니다"));
    }
  }

  /**
   * 사용자 정보 수정
   */
  @Operation(summary = "사용자 정보 수정", description = "사용자 정보를 수정합니다.")
  @PutMapping("/{userId}")
  @PreAuthorize("hasRole('ADMIN') or #userId == authentication.principal.id")
  public ResponseEntity<ApiResponse<UserResponse>> updateUser(
      @Parameter(description = "사용자 ID") @PathVariable UUID userId,
      @Valid @RequestBody UserUpdateRequest request) {
    try {
      log.info("사용자 정보 수정 요청: {}", userId);
      
      User user = userService.updateUser(
          userId,
          request.name(),
          request.phone(),
          request.department());
      
      UserResponse response = UserResponse.from(user);
      return ResponseEntity.ok(ApiResponse.success(response));
    } catch (Exception e) {
      log.error("사용자 정보 수정 실패", e);
      return ResponseEntity.status(HttpStatus.BAD_REQUEST)
          .body(ApiResponse.error("사용자 정보 수정에 실패했습니다"));
    }
  }

  /**
   * 비밀번호 변경
   */
  @Operation(summary = "비밀번호 변경", description = "사용자 비밀번호를 변경합니다.")
  @PutMapping("/{userId}/password")
  @PreAuthorize("#userId == authentication.principal.id")
  public ResponseEntity<ApiResponse<Void>> changePassword(
      @Parameter(description = "사용자 ID") @PathVariable UUID userId,
      @Valid @RequestBody PasswordChangeRequest request) {
    try {
      log.info("비밀번호 변경 요청: {}", userId);
      
      userService.changePassword(userId, request.currentPassword(), request.newPassword());
      return ResponseEntity.ok(ApiResponse.success(null));
    } catch (Exception e) {
      log.error("비밀번호 변경 실패", e);
      return ResponseEntity.status(HttpStatus.BAD_REQUEST)
          .body(ApiResponse.error("비밀번호 변경에 실패했습니다"));
    }
  }

  /**
   * 사용자 목록 조회 (관리자용)
   */
  @Operation(summary = "사용자 목록 조회", description = "모든 사용자 목록을 조회합니다.")
  @GetMapping
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<Page<UserResponse>>> getUsers(
      @Parameter(description = "페이징 정보") Pageable pageable) {
    try {
      log.info("사용자 목록 조회 요청");
      
      Page<User> users = userService.findAll(pageable);
      Page<UserResponse> response = users.map(user -> UserResponse.from(user));
      return ResponseEntity.ok(ApiResponse.success(response));
    } catch (Exception e) {
      log.error("사용자 목록 조회 실패", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(ApiResponse.error("사용자 목록 조회에 실패했습니다"));
    }
  }

  /**
   * 사용자 비활성화 (관리자용)
   */
  @Operation(summary = "사용자 비활성화", description = "사용자를 비활성화합니다.")
  @PutMapping("/{userId}/deactivate")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<Void>> deactivateUser(
      @Parameter(description = "사용자 ID") @PathVariable UUID userId) {
    try {
      log.info("사용자 비활성화 요청: {}", userId);
      
      userService.deactivateUser(userId);
      return ResponseEntity.ok(ApiResponse.success(null));
    } catch (Exception e) {
      log.error("사용자 비활성화 실패", e);
      return ResponseEntity.status(HttpStatus.BAD_REQUEST)
          .body(ApiResponse.error("사용자 비활성화에 실패했습니다"));
    }
  }

  /**
   * 사용자 활성화 (관리자용)
   */
  @Operation(summary = "사용자 활성화", description = "사용자를 활성화합니다.")
  @PutMapping("/{userId}/activate")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<Void>> activateUser(
      @Parameter(description = "사용자 ID") @PathVariable UUID userId) {
    try {
      log.info("사용자 활성화 요청: {}", userId);
      
      userService.activateUser(userId);
      return ResponseEntity.ok(ApiResponse.success(null));
    } catch (Exception e) {
      log.error("사용자 활성화 실패", e);
      return ResponseEntity.status(HttpStatus.BAD_REQUEST)
          .body(ApiResponse.error("사용자 활성화에 실패했습니다"));
    }
  }

  /**
   * 사용자 삭제 (관리자용)
   */
  @Operation(summary = "사용자 삭제", description = "사용자를 삭제합니다.")
  @DeleteMapping("/{userId}")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<Void>> deleteUser(
      @Parameter(description = "사용자 ID") @PathVariable UUID userId) {
    try {
      log.info("사용자 삭제 요청: {}", userId);
      
      userService.deleteUser(userId);
      return ResponseEntity.ok(ApiResponse.success(null));
    } catch (Exception e) {
      log.error("사용자 삭제 실패", e);
      return ResponseEntity.status(HttpStatus.BAD_REQUEST)
          .body(ApiResponse.error("사용자 삭제에 실패했습니다"));
    }
  }

  /**
   * 이메일 중복 확인
   */
  @Operation(summary = "이메일 중복 확인", description = "이메일 중복 여부를 확인합니다.")
  @GetMapping("/check-email")
  public ResponseEntity<ApiResponse<Boolean>> checkEmail(
      @Parameter(description = "이메일") @RequestParam String email) {
    try {
      log.info("이메일 중복 확인 요청: {}", email);
      
      boolean exists = userService.existsByEmail(email);
      return ResponseEntity.ok(ApiResponse.success(!exists));
    } catch (Exception e) {
      log.error("이메일 중복 확인 실패", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(ApiResponse.error("이메일 중복 확인에 실패했습니다"));
    }
  }
}
