# OpenRouter API 설정 및 문제 해결 가이드

## 개요

이 가이드는 전북 신고 플랫폼에서 OpenRouter API를 사용하여 이미지 분석 및 AI 서비스를 구현하는 방법을 설명합니다.

## 주요 변경사항

### 1. 유료 모델 우선 사용
- **이전**: 무료 모델만 사용 (제한적 기능)
- **현재**: 유료 비전 모델 우선, 무료 모델 fallback

### 2. 이미지 URL 기반 분석
- **이전**: 이미지 파일 직접 전송 (지원되지 않음)
- **현재**: 파일서버 URL을 통한 이미지 분석

### 3. nginx 프록시 설정
- **이전**: 로컬 파일 경로만 지원
- **현재**: 외부 접근 가능한 이미지 URL 제공

## 설정 단계

### 1. OpenRouter API 키 설정

```bash
# .env 파일에 추가
OPENROUTER_API_KEY=sk-or-v1-your-actual-api-key-here
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
```

### 2. 크레딧 충전
- [OpenRouter 계정](https://openrouter.ai/account)에서 크레딧 충전
- 유료 모델 사용을 위해 최소 $5 권장

### 3. nginx 설정

```bash
# nginx 설정 적용
sudo nginx -t  # 설정 검증
sudo systemctl reload nginx  # 설정 적용
```

### 4. 파일서버 설정

```bash
# 환경변수 추가
PUBLIC_URL=http://localhost:8090  # 개발환경
# 또는
PUBLIC_URL=https://image.nodove.com  # 프로덕션환경
```

## 지원 모델

### 비전 모델 (이미지 분석 가능)
1. `anthropic/claude-3.5-sonnet:beta` - 최고 품질
2. `openai/gpt-4o` - 빠른 응답
3. `google/gemini-pro-vision` - 다양한 형식 지원
4. `anthropic/claude-3-opus` - 높은 정확도

### 텍스트 모델 (fallback)
1. `openai/gpt-4-turbo`
2. `anthropic/claude-3-sonnet`
3. `google/gemini-pro`

### 무료 모델 (제한적 사용)
- `google/gemma-3n-e2b-it:free`
- `tencent/hunyuan-a13b-instruct:free`
- 기타 무료 모델들

## 테스트 방법

### 1. 전체 테스트 실행
```bash
./shellscript/test-openrouter-vision.sh
```

### 2. API 키 테스트
```bash
./shellscript/test-api-keys.sh
```

### 3. 수동 테스트
```bash
curl -H "Authorization: Bearer $OPENROUTER_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model":"anthropic/claude-3.5-sonnet:beta","messages":[{"role":"user","content":"Hello"}]}' \
     https://openrouter.ai/api/v1/chat/completions
```

## 문제 해결

### 1. API 키 오류
**증상**: `401 Unauthorized` 오류
**해결책**:
- API 키 확인: [OpenRouter Keys](https://openrouter.ai/keys)
- 환경변수 재설정
- 서비스 재시작

### 2. 크레딧 부족
**증상**: `402 Payment Required` 오류
**해결책**:
- [OpenRouter 계정](https://openrouter.ai/account)에서 잔액 확인
- 크레딧 충전
- 무료 모델로 임시 전환

### 3. 이미지 URL 접근 불가
**증상**: 비전 모델이 이미지를 읽지 못함
**해결책**:
- nginx 프록시 상태 확인: `sudo systemctl status nginx`
- 파일서버 상태 확인: `curl http://localhost:8000/health`
- 방화벽 설정 확인
- URL 형식 검증

### 4. 모델 응답 없음
**증상**: API 호출 성공하지만 빈 응답
**해결책**:
- 다른 모델로 시도
- 프롬프트 단순화
- 토큰 수 증가 (max_tokens)

## 로그 확인

### 1. 애플리케이션 로그
```bash
# Spring Boot 로그
tail -f logs/application.log

# 특정 OpenRouter 로그만 확인
grep "OpenRouter" logs/application.log
```

### 2. nginx 로그
```bash
# 접근 로그
tail -f /var/log/nginx/localhost_images.access.log

# 오류 로그
tail -f /var/log/nginx/localhost_images.error.log
```

### 3. 파일서버 로그
```bash
# 파일서버 로그 (개발환경)
docker logs file-server
```

## 성능 최적화

### 1. 모델 선택 전략
- 이미지 분석: 비전 모델 우선
- 텍스트 분석: 빠른 텍스트 모델 사용
- 복잡한 분석: 고성능 모델 사용

### 2. 캐싱 전략
- nginx에서 이미지 캐싱 (1일)
- 썸네일 캐싱 (7일)
- API 응답 캐싱 (선택사항)

### 3. 에러 처리
- 모델 fallback 체인
- 재시도 로직 (3회)
- 적절한 타임아웃 설정

## 보안 고려사항

### 1. API 키 보안
- 환경변수에만 저장
- 로그에 출력하지 않음
- 정기적 교체

### 2. 이미지 URL 보안
- CORS 설정 적용
- 적절한 캐시 헤더
- 파일 타입 검증

### 3. 네트워크 보안
- HTTPS 사용 (프로덕션)
- 방화벽 설정
- 접근 로그 모니터링

## 모니터링

### 1. 주요 메트릭
- API 응답 시간
- 성공/실패 비율
- 크레딧 사용량
- 모델별 사용 통계

### 2. 알람 설정
- API 키 만료 임박
- 크레딧 잔액 부족
- 연속 실패 발생
- 응답 시간 초과

## 참고 자료

- [OpenRouter API 문서](https://openrouter.ai/docs)
- [OpenRouter 모델 목록](https://openrouter.ai/models)
- [OpenRouter 가격 정보](https://openrouter.ai/pricing)
- [Vision API 가이드](https://openrouter.ai/docs#vision)