1. 핵심 백엔드 서비스 공통 Starter

프로젝트 요구사항에 따르면 백엔드는 마이크로서비스 아키텍처로 구성되며, auth-service, report-service, file-service, notification-service 등으로 분리됩니다. 대부분의 서비스에 공통적으로 필요한 스타터는 다음과 같습니다.

    spring-boot-starter-web: RESTful API 개발을 위한 필수 스타터입니다. 내장 톰캣(Tomcat)을 포함하고 있어 별도의 웹 서버 설정 없이 애플리케이션을 실행할 수 있게 해줍니다.

    spring-boot-starter-data-jpa: JPA(Java Persistence API)를 사용하여 데이터베이스와 상호작용하기 위한 스타터입니다. report-service, auth-service 등 데이터 영속성이 필요한 서비스에 사용됩니다.

    spring-boot-starter-security: Spring Security를 통해 인증(Authentication) 및 권한 부여(Authorization) 기능을 구현하기 위한 스타터입니다. auth-service에서 핵심적으로 사용되며, 다른 서비스들도 리소스 서버로서 JWT 유효성 검증에 사용합니다.

    spring-boot-starter-oauth2-resource-server: OAuth2 리소스 서버 기능을 제공하여 JWT(JSON Web Token) 기반의 인증을 처리하는 데 필수적입니다. auth-service와 다른 모든 API 서비스에서 JWT 유효성 검증을 위해 필요합니다.

    org.springdoc:springdoc-openapi-starter-webmvc-ui: API 문서를 자동으로 생성하고 Swagger UI를 제공하여 API 테스트 및 협업에 용이합니다. 모든 API 서비스에 추가하는 것이 좋습니다.

    org.springframework.boot:spring-boot-starter-validation: 데이터 유효성 검사를 위한 jakarta.validation (JSR-380) API를 지원합니다. 요청 데이터 유효성 검증에 유용합니다.

    org.springframework.boot:spring-boot-starter-actuator: 애플리케이션 모니터링 및 관리를 위한 기능을 제공합니다. 헬스 체크, 메트릭 수집 등에 활용됩니다.

    org.postgresql:postgresql (runtimeOnly): PostgreSQL 데이터베이스 드라이버입니다. JDBC를 통해 PostgreSQL과 연결합니다.

    org.springframework.boot:spring-boot-starter-data-redis: Redis 캐시 및 세션 관리를 위해 사용됩니다. 요구사항에 Redis가 명시되어 있으며, 특히 auth-service에서 JWT 리프레시 토큰 관리 등에 활용될 수 있습니다.

    com.querydsl:querydsl-jpa:5.0.0:jakarta 및 com.querydsl:querydsl-apt:5.0.0:jakarta: QueryDSL을 사용하여 타입-세이프한 쿼리를 작성할 수 있게 합니다. 복잡한 검색 조건이 필요한 report-service 등에서 유용합니다.

2. 서비스별 특화 Starter 및 라이브러리

2.1. auth-service

인증 및 권한 관리를 담당하는 핵심 서비스입니다.

    spring-boot-starter-security: 위에서 언급된 필수 스타터로, OAuth2 및 JWT 기반 인증의 핵심입니다.

    spring-boot-starter-oauth2-resource-server: JWT 토큰 유효성 검증 및 파싱에 사용됩니다.

    io.jsonwebtoken:jjwt-api, io.jsonwebtoken:jjwt-impl, io.jsonwebtoken:jjwt-jackson: JWT 생성, 서명, 파싱을 위한 라이브러리입니다.

    spring-boot-starter-data-redis: JWT 리프레시 토큰 또는 블랙리스트 관리 등 Redis 활용을 위해 필요합니다.

    org.springframework.boot:spring-boot-starter-data-jpa: 사용자 정보 저장을 위한 JPA 관련 스타터입니다.

    org.postgresql:postgresql: 사용자 정보를 저장할 PostgreSQL 드라이버입니다.

2.2. report-service

보고서 생성, 조회, 수정, 삭제를 담당합니다.

    spring-boot-starter-data-jpa: 보고서 데이터 영속성을 위해 필수입니다.

    com.querydsl:querydsl-jpa: 복잡한 보고서 검색 및 필터링 쿼리 작성을 위해 강력히 권장됩니다.

    org.springframework.kafka:spring-kafka: notification-service와의 비동기 통신 (예: 보고서 제출 시 알림 메시지 발행)을 위해 필요합니다.

    org.postgresql:postgresql: 보고서 데이터를 저장할 PostgreSQL 드라이버입니다.

    spring-boot-starter-data-redis: 캐싱 목적으로 사용될 수 있습니다 (예: 인기 보고서 캐싱).

2.3. file-service

파일 업로드/다운로드 및 MinIO 연동을 담당합니다.

    MinIO Client SDK: MinIO와의 상호작용을 위한 SDK입니다. (Maven Central에서 io.minio:minio 검색)

    spring-boot-starter-web: 파일 업로드/다운로드를 위한 REST API를 제공해야 합니다.

    org.springframework.kafka:spring-kafka: 파일 업로드 완료 시 다른 서비스(예: notification-service 또는 report-service)로 메시지를 발행할 수 있습니다.

2.4. notification-service

알림 및 커뮤니케이션 기능을 담당합니다.

    org.springframework.kafka:spring-kafka: Kafka 메시지를 소비하여 알림을 처리하는 데 필수입니다.

    Firebase Admin SDK (선택 사항): 모바일 푸시 알림(FCM)을 구현한다면 필요합니다. (Maven Central에서 com.google.firebase:firebase-admin 검색)

    spring-boot-starter-data-redis: 알림 상태 관리 또는 알림 전송률 제한(rate limiting)에 Redis를 사용할 수 있습니다.

3. 개발 생산성 및 품질 향상 도구

    org.projectlombok:lombok (annotationProcessor): @Data, @NoArgsConstructor, @AllArgsConstructor 등 어노테이션을 사용하여 boilerplate 코드를 줄여 개발 생산성을 크게 향상시킵니다.

        주의: IDE에 Lombok 플러그인을 설치해야 합니다.

    org.springframework.boot:spring-boot-devtools: 개발 중 애플리케이션 재시작 없이 코드 변경 사항을 자동으로 반영해주는 도구입니다. 개발 환경에서만 사용합니다.

    테스트 관련 스타터:

        spring-boot-starter-test: JUnit, Mockito, Spring Test 등 테스트를 위한 기본 도구들을 포함합니다.

        org.springframework.security:spring-security-test: Spring Security 관련 테스트를 위한 유틸리티를 제공합니다.

        org.springframework.kafka:spring-kafka-test: Kafka consumer/producer 테스트를 위한 임베디드 Kafka를 제공합니다.

        org.testcontainers:junit-jupiter, org.testcontainers:postgresql: 테스트 환경에서 Docker 컨테이너를 사용하여 실제 데이터베이스나 다른 서비스와 통합 테스트를 할 때 유용합니다.

4. build.gradle (Multi-module 프로젝트 예시)

build.gradle (Root) 에 공통 의존성을 정의하고, 각 서브 모듈의 build.gradle 파일에서 해당 서비스에 필요한 추가적인 의존성을 정의하는 방식으로 구성할 수 있습니다.
Gradle

// build.gradle (Root)
plugins {
    id 'org.springframework.boot' version '3.2.0'
    id 'io.spring.dependency-management' version '1.1.4'
    id 'java'
}

allprojects {
    group = 'com.flutterreport'
    version = '1.0.0'
    sourceCompatibility = '17'

    repositories {
        mavenCentral()
    }
}

subprojects {
    apply plugin: 'java'
    apply plugin: 'org.springframework.boot'
    apply plugin: 'io.spring.dependency-management'

    dependencies {
        // Spring Boot Starters (공통)
        implementation 'org.springframework.boot:spring-boot-starter-web'
        implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
        implementation 'org.springframework.boot:spring-boot-starter-security'
        implementation 'org.springframework.boot:spring-boot-starter-oauth2-resource-server'
        implementation 'org.springframework.boot:spring-boot-starter-validation'
        implementation 'org.springframework.boot:spring-boot-starter-actuator' // 모니터링
        implementation 'org.springframework.boot:spring-boot-starter-data-redis' // Redis

        // Lombok (개발 생산성)
        compileOnly 'org.projectlombok:lombok'
        annotationProcessor 'org.projectlombok:lombok'

        // QueryDSL
        implementation 'com.querydsl:querydsl-jpa:5.0.0:jakarta'
        annotationProcessor 'com.querydsl:querydsl-apt:5.0.0:jakarta'

        // JWT
        implementation 'io.jsonwebtoken:jjwt-api:0.11.5'
        runtimeOnly 'io.jsonwebtoken:jjwt-impl:0.11.5'
        runtimeOnly 'io.jsonwebtoken:jjwt-jackson:0.11.5'

        // API Documentation
        implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:2.2.0'

        // Kafka
        implementation 'org.springframework.kafka:spring-kafka'

        // Database Driver
        runtimeOnly 'org.postgresql:postgresql'

        // Test
        testImplementation 'org.springframework.boot:spring-boot-starter-test'
        testImplementation 'org.springframework.security:spring-security-test'
        testImplementation 'org.springframework.kafka:spring-kafka-test'
        testImplementation 'org.testcontainers:junit-jupiter'
        testImplementation 'org.testcontainers:postgresql'

        // 개발 중 유용 (개발 환경에서만 사용 권장)
        developmentOnly 'org.springframework.boot:spring-boot-devtools'
    }
}

// 각 서브 모듈의 build.gradle (예: auth-service/build.gradle)
// 이 파일에서는 별도의 추가 의존성이 필요할 경우만 작성합니다.
// 예: MinIO Client SDK 등 (file-service에서)
