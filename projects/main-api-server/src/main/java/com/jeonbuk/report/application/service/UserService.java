package com.jeonbuk.report.application.service;

import com.jeonbuk.report.domain.entity.User;
import com.jeonbuk.report.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 사용자 서비스
 * - 사용자 CRUD 작업
 * - 인증 및 권한 관리
 * - OAuth 통합
 * - 사용자 검색 및 통계
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

  private final UserRepository userRepository;
  private final PasswordEncoder passwordEncoder;

  /**
   * 사용자 등록 (이메일/패스워드)
   */
  @Transactional
  public User registerUser(String email, String password, String name, String phone, String department) {
    // 이메일 중복 확인
    if (userRepository.existsByEmail(email)) {
      throw new IllegalArgumentException("이미 존재하는 이메일입니다: " + email);
    }

    // 패스워드 해시화
    String hashedPassword = passwordEncoder.encode(password);

    // 사용자 생성
    User user = User.builder()
        .email(email)
        .passwordHash(hashedPassword)
        .name(name)
        .phone(phone)
        .department(department)
        .role(User.UserRole.USER)
        .isActive(true)
        .emailVerified(false)
        .build();

    User savedUser = userRepository.save(user);
    log.info("새 사용자 등록: {}", email);

    return savedUser;
  }

  /**
   * OAuth 사용자 등록/로그인
   */
  @Transactional
  public User processOAuthUser(String provider, String oauthId, String oauthEmail, String name) {
    // 기존 OAuth 사용자 확인
    Optional<User> existingUser = userRepository.findByOauthProviderAndOauthId(provider, oauthId);

    if (existingUser.isPresent()) {
      User user = existingUser.get();
      user.setLastLogin(LocalDateTime.now());
      log.info("기존 OAuth 사용자 로그인: {} via {}", oauthEmail, provider);
      return userRepository.save(user);
    }

    // 새 OAuth 사용자 생성
    User newUser = User.builder()
        .email(oauthEmail)
        .name(name)
        .oauthProvider(provider)
        .oauthId(oauthId)
        .oauthEmail(oauthEmail)
        .role(User.UserRole.USER)
        .isActive(true)
        .emailVerified(true) // OAuth는 이메일 인증됨으로 간주
        .lastLogin(LocalDateTime.now())
        .build();

    User savedUser = userRepository.save(newUser);
    log.info("새 OAuth 사용자 등록: {} via {}", oauthEmail, provider);

    return savedUser;
  }

  /**
   * 사용자 인증
   */
  public Optional<User> authenticateUser(String email, String password) {
    Optional<User> userOpt = userRepository.findByEmailAndIsActiveTrue(email);

    if (userOpt.isPresent()) {
      User user = userOpt.get();
      if (user.isPasswordUser() && passwordEncoder.matches(password, user.getPasswordHash())) {
        updateLastLogin(user.getId());
        return Optional.of(user);
      }
    }

    return Optional.empty();
  }

  /**
   * 사용자 조회
   */
  public Optional<User> findById(UUID id) {
    return userRepository.findById(id);
  }

  public Optional<User> findByEmail(String email) {
    return userRepository.findByEmail(email);
  }

  public List<User> findActiveUsers() {
    return userRepository.findByIsActiveTrue();
  }

  public Page<User> findActiveUsers(Pageable pageable) {
    return userRepository.findByIsActiveTrue(pageable);
  }

  public List<User> findByRole(User.UserRole role) {
    return userRepository.findByRoleAndIsActiveTrue(role);
  }

  /**
   * 사용자 검색
   */
  public Page<User> searchUsers(String keyword, Pageable pageable) {
    return userRepository.searchActiveUsers(keyword, pageable);
  }

  /**
   * 사용자 정보 업데이트
   */
  @Transactional
  public User updateUser(UUID userId, String name, String phone, String department) {
    User user = userRepository.findById(userId)
        .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다: " + userId));

    user.setName(name);
    user.setPhone(phone);
    user.setDepartment(department);

    return userRepository.save(user);
  }

  /**
   * 패스워드 변경
   */
  @Transactional
  public void changePassword(UUID userId, String currentPassword, String newPassword) {
    User user = userRepository.findById(userId)
        .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다: " + userId));

    if (!user.isPasswordUser()) {
      throw new IllegalStateException("OAuth 사용자는 패스워드를 변경할 수 없습니다");
    }

    if (!passwordEncoder.matches(currentPassword, user.getPasswordHash())) {
      throw new IllegalArgumentException("현재 패스워드가 일치하지 않습니다");
    }

    user.setPasswordHash(passwordEncoder.encode(newPassword));
    userRepository.save(user);

    log.info("사용자 패스워드 변경: {}", user.getEmail());
  }

  /**
   * 사용자 역할 변경 (관리자만)
   */
  @Transactional
  public User changeUserRole(UUID userId, User.UserRole newRole) {
    User user = userRepository.findById(userId)
        .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다: " + userId));

    user.setRole(newRole);
    User updatedUser = userRepository.save(user);

    log.info("사용자 역할 변경: {} -> {}", user.getEmail(), newRole);
    return updatedUser;
  }

  /**
   * 사용자 활성화/비활성화
   */
  @Transactional
  public User toggleUserActive(UUID userId) {
    User user = userRepository.findById(userId)
        .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다: " + userId));

    user.setIsActive(!user.getIsActive());
    User updatedUser = userRepository.save(user);

    log.info("사용자 상태 변경: {} -> {}", user.getEmail(), user.getIsActive() ? "활성" : "비활성");
    return updatedUser;
  }

  /**
   * 최근 로그인 시간 업데이트
   */
  @Transactional
  public void updateLastLogin(UUID userId) {
    User user = userRepository.findById(userId)
        .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다: " + userId));

    user.setLastLogin(LocalDateTime.now());
    userRepository.save(user);
  }

  /**
   * 이메일 인증 처리
   */
  @Transactional
  public void verifyEmail(UUID userId) {
    User user = userRepository.findById(userId)
        .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다: " + userId));

    user.setEmailVerified(true);
    userRepository.save(user);

    log.info("이메일 인증 완료: {}", user.getEmail());
  }

  /**
   * 사용자 통계
   */
  public long getTotalActiveUsers() {
    return userRepository.countActiveUsers();
  }

  public long getUserCountByRole(User.UserRole role) {
    return userRepository.countByRoleAndActive(role);
  }

  public List<User> getActiveManagers() {
    return userRepository.findActiveManagers();
  }

  public List<User> getRecentlyActiveUsers(int days) {
    LocalDateTime since = LocalDateTime.now().minusDays(days);
    return userRepository.findRecentlyActiveUsers(since);
  }

  /**
   * 중복 검증 메서드
   */
  public boolean isNameAvailable(String name) {
    return !userRepository.existsByNameAndIsActiveTrue(name);
  }

  public boolean isPhoneAvailable(String phone) {
    return !userRepository.existsByPhone(phone);
  }

  /**
   * 사용자 통계 메서드
   */
  public long getTotalUserCount() {
    return userRepository.count();
  }

  public long getActiveUserCount() {
    return userRepository.countActiveUsers();
  }
}
