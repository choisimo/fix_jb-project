package com.jeonbuk.report.presentation.controller;

import com.jeonbuk.report.application.service.OAuth2Service;
import com.jeonbuk.report.application.service.TokenService;
import com.jeonbuk.report.application.service.UserService;
import com.jeonbuk.report.application.service.VerificationService;
import com.jeonbuk.report.domain.entity.User;
import com.jeonbuk.report.infrastructure.security.jwt.JwtTokenProvider;
import com.jeonbuk.report.presentation.dto.request.*;
import com.jeonbuk.report.presentation.dto.response.ApiResponse;
import com.jeonbuk.report.presentation.dto.response.AuthResponse;
import com.jeonbuk.report.presentation.dto.response.UserResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.Optional;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.reactive.function.client.WebClient;

/**
 * 인증 관련 컨트롤러
 * - OAuth2 로그인
 * - 일반 로그인/회원가입
 * - 토큰 관리
 */
@Slf4j
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "인증 관리 API")
public class AuthController {

    private final UserService userService;
    private final OAuth2Service oauth2Service;
    private final TokenService tokenService;
    private final JwtTokenProvider jwtTokenProvider;
    private final VerificationService verificationService;

    @Operation(summary = "일반 로그인", description = "이메일/패스워드로 로그인합니다.")
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        try {
            Optional<User> userOpt = userService.authenticateUser(request.getEmail(), request.getPassword());
            
            if (userOpt.isEmpty()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("이메일 또는 비밀번호가 올바르지 않습니다."));
            }

            User user = userOpt.get();
            String accessToken = jwtTokenProvider.createToken(user.getEmail());
            String refreshToken = jwtTokenProvider.createRefreshToken(user.getEmail());
            long expiresIn = jwtTokenProvider.getTokenValidityInMilliseconds();

            // Refresh Token을 Redis에 저장
            tokenService.saveRefreshToken(user.getEmail(), refreshToken);

            UserResponse userResponse = UserResponse.fromEntity(user);
            AuthResponse authResponse = AuthResponse.success(accessToken, refreshToken, expiresIn, userResponse);

            return ResponseEntity.ok(ApiResponse.success("로그인 성공", authResponse));
            
        } catch (Exception e) {
            log.error("Login error", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("로그인 처리 중 오류가 발생했습니다."));
        }
    }

    @Operation(summary = "일반 회원가입", description = "이메일/패스워드로 회원가입합니다.")
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
        try {
            // SMS/Email 인증 확인 (필수)
            if (!verificationService.isPhoneVerified(request.getPhone())) {
                return ResponseEntity.badRequest()
                    .body(ApiResponse.error("휴대폰 인증을 완료해주세요."));
            }
            
            if (!verificationService.isEmailVerified(request.getEmail())) {
                return ResponseEntity.badRequest()
                    .body(ApiResponse.error("이메일 인증을 완료해주세요."));
            }

            User user = userService.registerUser(
                request.getEmail(),
                request.getPassword(),
                request.getName(),
                request.getPhone(),
                request.getDepartment()
            );

            String accessToken = jwtTokenProvider.createToken(user.getEmail());
            String refreshToken = jwtTokenProvider.createRefreshToken(user.getEmail());
            long expiresIn = jwtTokenProvider.getTokenValidityInMilliseconds();

            UserResponse userResponse = UserResponse.fromEntity(user);
            AuthResponse authResponse = AuthResponse.success(accessToken, refreshToken, expiresIn, userResponse);

            return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("회원가입이 완료되었습니다.", authResponse));
                
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            log.error("Registration error", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("회원가입 처리 중 오류가 발생했습니다."));
        }
    }

    @Operation(summary = "OAuth2 로그인 리다이렉트", description = "OAuth2 제공자로 리다이렉트합니다.")
    @GetMapping("/oauth2/authorization/{registrationId}")
    public void oauth2Login(@PathVariable String registrationId, HttpServletResponse response) throws IOException {
        String redirectUrl = String.format("/oauth2/authorization/%s", registrationId);
        response.sendRedirect(redirectUrl);
    }

    @Operation(summary = "OAuth2 콜백 처리", description = "OAuth2 인증 완료 후 사용자 정보를 처리합니다.")
    @GetMapping("/oauth2/callback/{registrationId}")
    public ResponseEntity<ApiResponse<AuthResponse>> oauth2Callback(
            @PathVariable String registrationId,
            @AuthenticationPrincipal OAuth2User oauth2User) {
        try {
            AuthResponse authResponse = oauth2Service.processOAuth2User(oauth2User, registrationId);
            return ResponseEntity.ok(ApiResponse.success("OAuth2 로그인 성공", authResponse));
            
        } catch (Exception e) {
            log.error("OAuth2 callback error for provider: {}", registrationId, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("OAuth2 로그인 처리 중 오류가 발생했습니다."));
        }
    }

    @Operation(summary = "소셜 회원가입 완료", description = "소셜 로그인 후 추가 정보를 입력하여 회원가입을 완료합니다.")
    @PostMapping("/complete-profile")
    public ResponseEntity<ApiResponse<AuthResponse>> completeProfile(
            @Valid @RequestBody CompleteProfileRequest request,
            HttpServletRequest httpRequest) {
        try {
            String token = extractTokenFromRequest(httpRequest);
            if (token == null || !jwtTokenProvider.validateToken(token) || !jwtTokenProvider.isTempToken(token)) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("유효하지 않은 임시 토큰입니다."));
            }

            String email = jwtTokenProvider.getUsername(token);
            Optional<User> userOpt = userService.findByEmail(email);
            
            if (userOpt.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error("사용자를 찾을 수 없습니다."));
            }

            User user = userService.updateUser(
                userOpt.get().getId(),
                request.getName(),
                request.getPhone(),
                request.getDepartment()
            );

            String accessToken = jwtTokenProvider.createToken(user.getEmail());
            String refreshToken = jwtTokenProvider.createRefreshToken(user.getEmail());
            long expiresIn = jwtTokenProvider.getTokenValidityInMilliseconds();

            UserResponse userResponse = UserResponse.fromEntity(user);
            AuthResponse authResponse = AuthResponse.success(accessToken, refreshToken, expiresIn, userResponse);

            return ResponseEntity.ok(ApiResponse.success("프로필 완성이 완료되었습니다.", authResponse));
            
        } catch (Exception e) {
            log.error("Complete profile error", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("프로필 완성 처리 중 오류가 발생했습니다."));
        }
    }

    @Operation(summary = "토큰 갱신", description = "Refresh Token으로 새로운 Access Token을 발급받습니다.")
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<AuthResponse>> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        try {
            String refreshToken = request.getRefreshToken();
            
            if (!jwtTokenProvider.validateToken(refreshToken) || !jwtTokenProvider.isRefreshToken(refreshToken)) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("유효하지 않은 리프레시 토큰입니다."));
            }

            String email = jwtTokenProvider.getUsername(refreshToken);
            
            // Redis에서 Refresh Token 검증
            if (!tokenService.isValidRefreshToken(email, refreshToken)) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("만료되거나 유효하지 않은 리프레시 토큰입니다."));
            }

            Optional<User> userOpt = userService.findByEmail(email);
            
            if (userOpt.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error("사용자를 찾을 수 없습니다."));
            }

            User user = userOpt.get();
            String newAccessToken = jwtTokenProvider.createToken(user.getEmail());
            String newRefreshToken = jwtTokenProvider.createRefreshToken(user.getEmail());
            long expiresIn = jwtTokenProvider.getTokenValidityInMilliseconds();

            // 기존 Refresh Token 삭제하고 새로운 Refresh Token 저장
            tokenService.deleteRefreshToken(user.getEmail());
            tokenService.saveRefreshToken(user.getEmail(), newRefreshToken);

            UserResponse userResponse = UserResponse.fromEntity(user);
            AuthResponse authResponse = AuthResponse.success(newAccessToken, newRefreshToken, expiresIn, userResponse);

            return ResponseEntity.ok(ApiResponse.success("토큰 갱신 성공", authResponse));
            
        } catch (Exception e) {
            log.error("Token refresh error", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("토큰 갱신 처리 중 오류가 발생했습니다."));
        }
    }

    @Operation(summary = "이메일 중복 확인", description = "이메일 사용 가능 여부를 확인합니다.")
    @GetMapping("/check-email")
    public ResponseEntity<ApiResponse<Boolean>> checkEmailAvailable(@RequestParam String email) {
        try {
            boolean available = !userService.findByEmail(email).isPresent();
            return ResponseEntity.ok(ApiResponse.success("이메일 중복 확인 완료", available));
        } catch (Exception e) {
            log.error("Email check error", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("이메일 중복 확인 중 오류가 발생했습니다."));
        }
    }

    @Operation(summary = "이름 중복 확인", description = "이름 사용 가능 여부를 확인합니다.")
    @GetMapping("/check-name")
    public ResponseEntity<ApiResponse<Boolean>> checkNameAvailable(@RequestParam String name) {
        try {
            boolean available = userService.isNameAvailable(name);
            return ResponseEntity.ok(ApiResponse.success("이름 중복 확인 완료", available));
        } catch (Exception e) {
            log.error("Name check error", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("이름 중복 확인 중 오류가 발생했습니다."));
        }
    }

    @Operation(summary = "전화번호 중복 확인", description = "전화번호 사용 가능 여부를 확인합니다.")
    @GetMapping("/check-phone")
    public ResponseEntity<ApiResponse<Boolean>> checkPhoneAvailable(@RequestParam String phone) {
        try {
            boolean available = userService.isPhoneAvailable(phone);
            return ResponseEntity.ok(ApiResponse.success("전화번호 중복 확인 완료", available));
        } catch (Exception e) {
            log.error("Phone check error", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("전화번호 중복 확인 중 오류가 발생했습니다."));
        }
    }

    @Operation(summary = "토큰 유효성 검증", description = "현재 토큰의 유효성을 검증합니다.")
    @GetMapping("/validate")
    public ResponseEntity<ApiResponse<Boolean>> validateToken(HttpServletRequest request) {
        try {
            String token = extractTokenFromRequest(request);
            
            if (token == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("토큰이 없습니다."));
            }
            
            boolean isValid = jwtTokenProvider.validateToken(token);
            
            if (!isValid) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("유효하지 않은 토큰입니다."));
            }
            
            // 블랙리스트 검증
            if (tokenService.isBlacklisted(token)) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("무효화된 토큰입니다."));
            }
            
            return ResponseEntity.ok(ApiResponse.success("토큰이 유효합니다.", true));
            
        } catch (Exception e) {
            log.error("Token validation error", e);
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("토큰 검증 중 오류가 발생했습니다."));
        }
    }

    @Operation(summary = "사용자 정보 조회", description = "현재 인증된 사용자의 정보를 조회합니다.")
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser(HttpServletRequest request) {
        try {
            String token = extractTokenFromRequest(request);
            
            if (token == null || !jwtTokenProvider.validateToken(token)) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("유효하지 않은 토큰입니다."));
            }
            
            // 블랙리스트 검증
            if (tokenService.isBlacklisted(token)) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("무효화된 토큰입니다."));
            }
            
            String email = jwtTokenProvider.getUsername(token);
            Optional<User> userOpt = userService.findByEmail(email);
            
            if (userOpt.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error("사용자를 찾을 수 없습니다."));
            }
            
            User user = userOpt.get();
            UserResponse userResponse = UserResponse.fromEntity(user);
            
            return ResponseEntity.ok(ApiResponse.success("사용자 정보 조회 성공", userResponse));
            
        } catch (Exception e) {
            log.error("Get current user error", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("사용자 정보 조회 중 오류가 발생했습니다."));
        }
    }

    @Operation(summary = "로그아웃", description = "현재 세션을 종료합니다.")
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(HttpServletRequest request) {
        try {
            String token = extractTokenFromRequest(request);
            if (token != null && jwtTokenProvider.validateToken(token)) {
                String email = jwtTokenProvider.getUsername(token);
                
                // Refresh Token 삭제
                tokenService.invalidateAllTokens(email);
                
                // Access Token을 블랙리스트에 추가
                tokenService.addToBlacklist(token);
                
                log.info("User logged out: {}", email);
            }
            
            return ResponseEntity.ok(ApiResponse.success("로그아웃 완료", null));
        } catch (Exception e) {
            log.error("Logout error", e);
            return ResponseEntity.ok(ApiResponse.success("로그아웃 완료", null)); // 에러가 발생해도 로그아웃은 성공으로 처리
        }
    }

    /**
     * HTTP 요청에서 JWT 토큰 추출
     */
    @Value("${spring.security.oauth2.client.registration.google.client-id}")
    private String googleClientId;

    @Operation(summary = "모바일 OAuth2 로그인", description = "모바일 앱에서 ID 토큰으로 로그인합니다.")
    @PostMapping("/oauth2/mobile/{registrationId}")
    public ResponseEntity<ApiResponse<AuthResponse>> mobileOAuth2Login(
            @PathVariable String registrationId,
            @RequestBody Map<String, String> body) {
        try {
            String token = body.get("token");
            if (token == null) {
                return ResponseEntity.badRequest().body(ApiResponse.error("토큰이 필요합니다."));
            }

            Map<String, Object> userAttributes = verifyIdToken(registrationId, token);

            OAuth2User oauth2User = new org.springframework.security.oauth2.core.user.DefaultOAuth2User(
                    Collections.singleton(new org.springframework.security.core.authority.SimpleGrantedAuthority("ROLE_USER")),
                    userAttributes,
                    "email"
            );

            AuthResponse authResponse = oauth2Service.processOAuth2User(oauth2User, registrationId);
            return ResponseEntity.ok(ApiResponse.success("모바일 OAuth2 로그인 성공", authResponse));

        } catch (Exception e) {
            log.error("Mobile OAuth2 login error for provider: {}", registrationId, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("모바일 OAuth2 로그인 처리 중 오류가 발생했습니다."));
        }
    }

    private Map<String, Object> verifyIdToken(String provider, String token) throws Exception {
        if ("google".equalsIgnoreCase(provider)) {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(), GsonFactory.getDefaultInstance())
                    .setAudience(Collections.singletonList(googleClientId))
                    .build();

            GoogleIdToken idToken = verifier.verify(token);
            if (idToken != null) {
                Payload payload = idToken.getPayload();
                Map<String, Object> attributes = new HashMap<>();
                attributes.put("sub", payload.getSubject());
                attributes.put("email", payload.getEmail());
                attributes.put("name", payload.get("name"));
                attributes.put("picture", payload.get("picture"));
                return attributes;
            } else {
                throw new IllegalArgumentException("Invalid Google ID token");
            }
        } else if ("kakao".equalsIgnoreCase(provider)) {
            WebClient webClient = WebClient.create("https://kapi.kakao.com");

            Map<String, Object> userInfo = webClient.post()
                    .uri("/v2/user/me")
                    .header("Authorization", "Bearer " + token)
                    .retrieve()
                    .bodyToMono(Map.class)
                    .block();

            if (userInfo != null) {
                return userInfo;
            } else {
                throw new IllegalArgumentException("Invalid Kakao access token");
            }
        } else {
            throw new IllegalArgumentException("Unsupported provider: " + provider);
        }
    }

    private String extractTokenFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}