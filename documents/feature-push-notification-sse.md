## 📢 실시간 알림 시스템 고도화 제안서

**현황 분석:**

현재 시스템은 `flutter_local_notifications`를 통해 앱 내 로컬 알림은 가능하지만, 서버에서 직접 클라이언트로 푸시 알림을 보내는 기능과 관리자 웹 대시보드를 위한 실시간 알림 기능이 부재합니다. 이로 인해 사용자는 앱을 실행해야만 상태 변경을 인지할 수 있고, 관리자는 새로고침을 통해 변경사항을 확인해야 하는 불편함이 있습니다.

**제안 내용:**

사용자 경험을 극대화하고 실시간 상호작용을 강화하기 위해 다음 두 가지 기술을 도입할 것을 제안합니다.

1.  **Firebase Cloud Messaging (FCM) 기반 앱 푸시 알림 도입**
2.  **SSE (Server-Sent Events) 프로토콜을 이용한 서버-클라이언트 실시간 통신 적용**

### 1. Firebase Cloud Messaging (FCM) 도입

**목표:** 사용자가 앱을 사용하지 않을 때도 보고서 상태 변경(승인, 반려) 등 중요 업데이트를 즉시 수신할 수 있도록 합니다.

**기대 효과:**

*   **신속한 정보 전달:** 사용자는 앱을 열지 않아도 중요 알림을 즉시 인지할 수 있습니다.
*   **사용자 참여 증대:** 푸시 알림을 통해 사용자의 재방문 및 앱 참여를 유도합니다.
*   **안정적인 메시지 전송:** Google의 안정적인 인프라를 통해 높은 메시지 전송률을 보장합니다.

### 2. SSE (Server-Sent Events) 프로토콜 적용

**목표:** 관리자 웹 대시보드와 모바일 앱에서 새로운 보고서 접수, 댓글 등 실시간 업데이트가 필요한 정보를 즉시 반영합니다.

**기대 효과:**

*   **실시간 대시보드 구현:** 관리자는 페이지를 새로고침하지 않아도 새로운 보고서 접수 현황을 실시간으로 확인할 수 있습니다.
*   **향상된 사용자 경험:** 앱 사용자는 보고서 상태 변경이나 새로운 댓글을 실시간으로 확인하여 즉각적인 상호작용이 가능합니다.
*   **효율적인 리소스 사용:** WebSocket에 비해 가볍고 구현이 간단하며, 단방향 통신에 최적화되어 서버 부하를 줄일 수 있습니다.

### 3. 제안 시스템 아키텍처

```mermaid
graph TD
    subgraph "Client Applications"
        A[📱 Flutter Mobile App]
        B[💻 Flutter Web App]
    end

    subgraph "Real-time Communication"
        C[🔥 Firebase Cloud Messaging (FCM)]
        D[🌐 SSE Endpoint (Spring Boot)]
    end

    subgraph "Backend Services"
        E[🍃 Notification Service (Spring Boot)]
        F[🍃 Report Service (Spring Boot)]
    end

    subgraph "Data & Message Layer"
        G[📨 Apache Kafka]
    end

    A --"FCM Token 등록"--> E
    B --"SSE 연결 요청"--> D

    F --"보고서 상태 변경 이벤트"--> G
    G --"이벤트 수신"--> E

    E --"푸시 알림 요청"--> C
    E --"SSE 이벤트 발행"--> D

    C --"푸시 알림"--> A
    D --"실시간 데이터"--> B
    D --"실시간 데이터"--> A
```

**구현 계획:**

1.  **Backend (Spring Boot):**
    *   `NotificationService`에 FCM 및 SSE 지원 로직 추가
    *   보고서 상태 변경 등 Kafka 이벤트를 수신하여 FCM 푸시 알림 및 SSE 메시지 발송
    *   SSE 연결을 위한 `/api/v1/notifications/subscribe` 엔드포인트 구현
2.  **Frontend (Flutter):**
    *   `firebase_messaging` 패키지 활성화 및 설정
    *   앱 시작 시 FCM 토큰을 서버에 등록하는 로직 추가
    *   SSE 클라이언트를 구현하여 서버로부터 실시간 이벤트 수신 및 UI 업데이트
3.  **인프라:**
    *   Firebase 프로젝트 설정 및 앱 등록
    *   필요시 Nginx 등 프록시 서버에 SSE 지원 설정 추가

**결론:**

FCM과 SSE 기술을 도입함으로써, 사용자와 관리자 모두에게 **신속하고 원활한 실시간 정보 전달**이 가능해집니다. 이는 전북 현장 보고 및 관리 플랫폼의 핵심 가치인 **신속성**과 **실시간성**을 크게 향상시킬 것입니다.
