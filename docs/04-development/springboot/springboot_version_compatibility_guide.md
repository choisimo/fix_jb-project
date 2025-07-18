# Spring Boot 최신 버전 및 호환성 가이드 (2025년 7월 기준)

## 1. Spring Boot 최신 버전 정보
- **Spring Boot LTS 최신 버전:** 3.3.x (2025년 7월 기준)
- [Spring Boot 공식 릴리즈 노트](https://github.com/spring-projects/spring-boot/releases)
- [Spring 공식 문서](https://docs.spring.io/spring-boot/docs/current/reference/html/)

## 2. 주요 라이브러리 및 의존성 호환성
- Spring Boot 3.x는 Java 17 이상이 필수입니다. (Java 21 LTS 권장)
- 주요 Starter(예: spring-boot-starter-data-jpa, spring-boot-starter-web 등)는 항상 Spring Boot 공식 버전과 호환되는지 확인하세요.
- JPA/Hibernate, Spring Security, Spring Cloud 등은 각 버전별 호환성 매트릭스를 반드시 확인하세요.
- Gradle/Maven 빌드 시 BOM(Bill of Materials) 사용을 권장합니다.

## 3. 버전 충돌 방지 및 관리 팁
- 의존성 관리는 반드시 BOM을 활용하고, 직접 버전 명시를 최소화하세요.
- `./gradlew dependencyUpdates` 또는 `mvn versions:display-dependency-updates`로 주기적 점검
- 의존성 충돌 발생 시, Gradle의 dependencyInsight, Maven의 dependency:tree로 원인 분석
- CI/CD에서 `./gradlew test` 또는 `mvn test` 자동화

## 4. 참고 공식 문서 및 자료
- [Spring Boot 공식 문서](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [Spring Initializr](https://start.spring.io/)
- [Spring Cloud 호환성 매트릭스](https://spring.io/projects/spring-cloud)
- [JPA/Hibernate 공식 문서](https://hibernate.org/orm/documentation/)

---
> 본 문서는 2025년 7월 기준 최신 정보를 반영하였으며, Spring Boot 및 주요 라이브러리의 업데이트 주기를 고려해 주기적으로 갱신할 것을 권장합니다.
