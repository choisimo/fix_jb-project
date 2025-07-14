# 전북 리포트 플랫폼 문서 인덱스

마지막 업데이트: 2025-07-13 17:17:03

## 최근 문서 디렉토리

- [2025-07-13](./2025-07-13/) - 2025년 07월 13일
- [2025-07-12](./2025-07-12/) - 2025년 07월 12일
- [2025-07-11](./2025-07-11/) - 2025년 07월 11일

## 카테고리별 분류

### 📊 분석 (Analysis)
최근 분석 문서들

### 🔧 서비스 (Service)  
API 명세 및 서비스 설계 문서들

### 🏗️ 인프라 (Infrastructure)
시스템 구성 및 배포 관련 문서들

### 📋 회의 (Meeting)
프로젝트 회의록 및 의사결정 기록

### 📈 기획 (Planning)
제품 기획 및 요구사항 문서들

### 🧪 테스트 (Testing)
테스트 계획 및 결과 문서들

## 문서 작성 가이드

### 파일명 규칙
`{카테고리}-{주제}-{버전}.md`

예시:
- `service-user-auth-v1.md`
- `analysis-error-report-v2.md`
- `meeting-sprint-planning-v1.md`

### 메타데이터 헤더
모든 문서는 다음 헤더를 포함해야 합니다:

```markdown
---
title: 문서 제목
category: service|infrastructure|analysis|meeting|planning|testing
date: YYYY-MM-DD
version: 1.0
author: 작성자명
last_modified: YYYY-MM-DD
tags: [tag1, tag2, tag3]
status: draft|review|approved|archived
---
```

## 템플릿 사용법

1. 템플릿 복사: `cp templates/{템플릿}.md {날짜}/{카테고리}/{문서명}.md`
2. 메타데이터 수정
3. 내용 작성
4. 검토 및 승인

