# 1. 프론트엔드 (Flutter) 기능 분석 및 API 정의

| 화면 (Screen) | 구현된 기능 | 필요한 백엔드 API | HTTP Method & 경로 |
| :--- | :--- | :--- | :--- |
| Splash 스크린 | 앱 실행 시, 저장된 토큰으로 자동 로그인 시도 | 토큰 유효성 검사 및 내 정보 조회 | GET /auth/me |
| 로그인 페이지 | 이메일/비밀번호로 로그인 | 이메일/비밀번호로 로그인 요청 | POST /auth/login |
| 회원가입 페이지 | (UI만 존재) 이메일/비밀번호로 가입 | 신규 사용자 등록 | POST /auth/register |
| 보고서 목록 | 보고서 목록 조회, 검색, 무한 스크롤, 새로고침 | 보고서 목록 가져오기 (검색/필터링 포함) | GET /reports |
| 보고서 상세 | 특정 보고서의 상세 정보 조회 및 삭제 | 특정 보고서 조회<br>특정 보고서 삭제 | GET /reports/{id}<br>DELETE /reports/{id} |
| 보고서 생성 | (UI만 존재) 신규 보고서 작성 | 신규 보고서 생성 | POST /reports |
| 프로필 페이지 | 내 정보 조회 및 로그아웃 | 내 정보 조회<br>로그아웃 요청 | GET /auth/me<br>POST /auth/logout |
