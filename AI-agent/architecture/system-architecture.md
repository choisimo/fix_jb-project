# 전체 시스템 아키텍처

## 🏗️ 시스템 아키텍처 개요

전북 신고 플랫폼은 **마이크로서비스 아키텍처**를 기반으로 설계되었으며, **클라이언트-서버 모델**과 **이벤트 기반 아키텍처**를 결합하여 확장성과 유지보수성을 확보했습니다.

## 📊 전체 아키텍처 다이어그램

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Client Layer                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐              │
│  │   Flutter App   │  │  Admin Web UI   │  │   Mobile Web    │              │
│  │   (iOS/Android) │  │   (React/Vue)   │  │   (PWA)         │              │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                 HTTPS/WSS
                                    │
┌─────────────────────────────────────────────────────────────────────────────┐
│                              API Gateway                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │              Load Balancer & Reverse Proxy                             ││
│  │                        (Nginx/HAProxy)                                 ││
│  └─────────────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                         ┌──────────┴──────────┐
                         │                     │
┌─────────────────────────────────────────────────────────────────────────────┐
│                            Service Layer                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────┐                ┌──────────────────────┐             │
│  │   Main API Server   │◄──────────────►│  AI Analysis Server  │             │
│  │   (Spring Boot)     │   Service Call │   (Spring Boot)      │             │
│  │                     │                │                      │             │
│  │ • 사용자 관리        │                │ • 이미지 분석         │             │
│  │ • 신고 CRUD         │                │ • AI 모델 라우팅      │             │
│  │ • 인증/권한         │                │ • 객체 감지          │             │
│  │ • 알림 서비스        │                │ • 자동 분류          │             │
│  │ • 파일 관리         │                │ • 우선순위 결정       │             │
│  │ • WebSocket         │                │ • 배치 처리          │             │
│  └─────────────────────┘                └──────────────────────┘             │
│          │                                        │                        │
│          │                                        │                        │
│  ┌───────▼────────┐                       ┌───────▼────────┐               │
│  │  Message Queue │                       │   Cache Layer  │               │
│  │    (Kafka)     │                       │    (Redis)     │               │
│  └────────────────┘                       └────────────────┘               │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
┌─────────────────────────────────────────────────────────────────────────────┐
│                            Data Layer                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐  │
│  │    PostgreSQL       │  │   File Storage      │  │   Configuration     │  │
│  │   (Main Database)   │  │     (Local/S3)      │  │     (Database)      │  │
│  │                     │  │                     │  │                     │  │
│  │ • 사용자 데이터      │  │ • 신고 이미지        │  │ • API 키            │  │
│  │ • 신고 데이터        │  │ • 처리 사진         │  │ • 시스템 설정        │  │
│  │ • 카테고리          │  │ • 썸네일            │  │ • 환경 변수         │  │
│  │ • 알림 데이터        │  │ • 첨부 파일         │  │                     │  │
│  │ • 감사 로그         │  │                     │  │                     │  │
│  └─────────────────────┘  └─────────────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
┌─────────────────────────────────────────────────────────────────────────────┐
│                          External Services                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐              │
│  │   Roboflow API  │  │ OpenRouter API  │  │  OAuth Providers│              │
│  │                 │  │                 │  │                 │              │
│  │ • 객체 감지      │  │ • LLM 분석       │  │ • Google OAuth  │              │
│  │ • 이미지 분류    │  │ • 텍스트 분석    │  │ • Kakao Login   │              │
│  │ • 신뢰도 평가    │  │ • 의미 추출      │  │ • Naver Login   │              │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🔧 아키텍처 패턴

### 1. **마이크로서비스 아키텍처**
```
Service Boundaries:
├── Main API Service (Business Logic)
├── AI Analysis Service (ML/AI Processing)
├── File Storage Service (Media Handling)
└── Notification Service (Real-time Communications)
```

**장점:**
- 독립적 배포 및 확장
- 기술 스택 다양성
- 장애 격리
- 팀별 개발 가능

### 2. **레이어드 아키텍처 (각 서비스 내부)**
```
┌─────────────────────┐
│ Presentation Layer  │ ← Controllers, DTOs, Validation
├─────────────────────┤
│ Application Layer   │ ← Services, Use Cases, Orchestration
├─────────────────────┤
│ Domain Layer        │ ← Entities, Business Rules, Domain Services
├─────────────────────┤
│ Infrastructure Layer│ ← Repositories, External APIs, Persistence
└─────────────────────┘
```

### 3. **이벤트 기반 아키텍처**
```
Event Flow:
신고 생성 → Kafka → AI 분석 시작
AI 분석 완료 → Kafka → 담당자 알림
상태 변경 → Kafka → 실시간 업데이트
```

## 🌐 네트워크 및 통신

### API 통신 패턴
```
Client ←→ Main API Server
   │
   └─→ WebSocket (실시간 알림)
   
Main API Server ←→ AI Analysis Server
   │
   ├─→ REST API (동기 호출)
   ├─→ Kafka (비동기 이벤트)
   └─→ Database (공유 데이터)
```

### 프로토콜 및 포트
```
Service                Port    Protocol    Purpose
Flutter App           -       HTTPS       Client Communication
Main API Server       8080    HTTP/HTTPS  REST API
AI Analysis Server    8081    HTTP/HTTPS  AI Processing API
PostgreSQL            5432    TCP         Database
Redis                 6379    TCP         Cache & Sessions
Kafka                 9092    TCP         Message Queue
WebSocket             8080    WSS         Real-time Updates
```

## 🔒 보안 아키텍처

### 인증 및 권한 체계
```
┌─────────────────────┐
│   Authentication    │
├─────────────────────┤
│ • JWT Token         │
│ • OAuth 2.0         │
│ • Session Management│
└─────────────────────┘
           │
┌─────────────────────┐
│   Authorization     │
├─────────────────────┤
│ • Role-Based (RBAC) │
│ • Method-Level      │
│ • Resource-Level    │
└─────────────────────┘
           │
┌─────────────────────┐
│   Data Protection   │
├─────────────────────┤
│ • HTTPS/TLS         │
│ • API Key Encryption│
│ • PII Anonymization │
└─────────────────────┘
```

### 보안 레이어
1. **네트워크 보안**: HTTPS, WSS, VPN
2. **애플리케이션 보안**: JWT, OAuth, RBAC
3. **데이터 보안**: 암호화, 해시, 마스킹
4. **인프라 보안**: 방화벽, 침입탐지, 모니터링

## 📊 데이터 아키텍처

### 데이터 플로우
```
1. 사용자 입력 (Flutter)
   ↓
2. API 검증 (Main Server)
   ↓
3. 비즈니스 로직 처리
   ↓
4. 데이터 저장 (PostgreSQL)
   ↓
5. AI 분석 이벤트 (Kafka)
   ↓
6. AI 처리 (AI Server)
   ↓
7. 결과 저장 및 알림
   ↓
8. 실시간 업데이트 (WebSocket)
```

### 데이터 저장 전략
```
PostgreSQL (OLTP):
├── 실시간 트랜잭션 데이터
├── 사용자 및 권한 정보
├── 신고 및 댓글 데이터
└── 시스템 설정 및 로그

Redis (Cache):
├── 세션 데이터
├── API 응답 캐시
├── 실시간 상태 정보
└── 임시 데이터

File Storage:
├── 신고 이미지/동영상
├── 처리 결과 사진
├── 썸네일 이미지
└── 사용자 업로드 파일
```

## 🚀 확장성 고려사항

### 수평 확장 (Horizontal Scaling)
```
Load Balancer
├── Main API Server #1
├── Main API Server #2
└── Main API Server #N

Database Cluster
├── Master (Write)
└── Slave (Read Replicas)

Cache Cluster
├── Redis Node #1
├── Redis Node #2
└── Redis Node #N
```

### 수직 확장 (Vertical Scaling)
- CPU 집약적: AI Analysis Server
- Memory 집약적: Database, Cache
- I/O 집약적: File Storage, Message Queue

## 🔄 장애 복구 전략

### High Availability (HA)
```
Component           Strategy
API Servers        Multiple instances + Load Balancer
Database           Master-Slave + Automatic Failover
Cache              Redis Cluster + Sentinel
Message Queue      Kafka Cluster + Replication
File Storage       Redundant Storage + Backup
```

### Disaster Recovery (DR)
- **백업**: 일일 자동 백업 + 주기적 복구 테스트
- **복제**: 지리적 분산 백업 센터
- **모니터링**: 실시간 헬스체크 + 자동 알림

## 📈 성능 최적화

### 캐싱 전략
```
Level 1: Application Cache (In-Memory)
Level 2: Distributed Cache (Redis)
Level 3: CDN Cache (Static Assets)
Level 4: Database Query Cache
```

### 비동기 처리
```
Synchronous:
├── 사용자 인증
├── 신고 생성/조회
└── 실시간 알림

Asynchronous:
├── AI 이미지 분석
├── 이메일/SMS 발송
├── 파일 처리
└── 통계 집계
```

## 🔧 개발 및 배포 아키텍처

### 환경별 구성
```
Development Environment:
├── Local Docker Compose
├── In-Memory Database
├── Mock External APIs
└── Hot Reload

Staging Environment:
├── Container Orchestration
├── Staging Database
├── Real External APIs
└── Performance Testing

Production Environment:
├── Kubernetes Cluster
├── Production Database
├── Monitoring & Logging
└── Auto-scaling
```

---

*문서 버전: 1.0*  
*최종 업데이트: 2025년 7월 12일*  
*작성자: 시스템 아키텍트 팀*