# DTO/응답/요청 미구현 항목 (2025-07-12)

## main-api-server

- AuthResponse.java
  - Line 21: private String tempToken; // 임시 토큰
- OpenRouterDto.java
  - Line 90: return null; // 외부 API 응답 미구현
- RoboflowDto.java
  - Line 99, 104: // TODO: Roboflow DTO 미구현
- UserRegistrationRequest.java, RegisterRequest.java, LoginRequest.java
  - password 관련 임시값/더미값

## ai-analysis-server

- UserResponse.java
  - Line 58, 100: return null; // 사용자 응답 미구현
- UserRegistrationRequest.java, UserCreateRequest.java, LoginRequest.java
  - password 관련 임시값/더미값
