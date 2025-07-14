#!/bin/bash

set -e

echo "=========================================="
echo "JB Report Platform - 의존성 수정"
echo "=========================================="
echo ""

# Fix main-api-server dependencies
echo "=== main-api-server 의존성 수정 ==="
cat > main-api-server/build.gradle << 'EOF'
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.2.0'
    id 'io.spring.dependency-management' version '1.1.4'
}

group = 'com.jeonbuk.report'
version = '1.0.0'
sourceCompatibility = '17'

configurations {
    compileOnly {
        extendsFrom annotationProcessor
    }
}

repositories {
    mavenCentral()
}

dependencies {
    // Spring Boot
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    implementation 'org.springframework.boot:spring-boot-starter-websocket'
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
    
    // Database
    implementation 'org.postgresql:postgresql'
    implementation 'jakarta.persistence:jakarta.persistence-api:3.1.0'
    implementation 'jakarta.validation:jakarta.validation-api:3.0.2'
    
    // Redis
    implementation 'org.springframework.boot:spring-boot-starter-data-redis'
    implementation 'org.springframework.session:spring-session-data-redis'
    
    // Kafka
    implementation 'org.springframework.kafka:spring-kafka'
    
    // Security
    implementation 'io.jsonwebtoken:jjwt-api:0.11.5'
    runtimeOnly 'io.jsonwebtoken:jjwt-impl:0.11.5'
    runtimeOnly 'io.jsonwebtoken:jjwt-jackson:0.11.5'
    
    // OAuth2
    implementation 'org.springframework.boot:spring-boot-starter-oauth2-client'
    
    // Swagger
    implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:2.2.0'
    
    // Lombok
    compileOnly 'org.projectlombok:lombok'
    annotationProcessor 'org.projectlombok:lombok'
    
    // Test
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.springframework.security:spring-security-test'
}

tasks.named('test') {
    useJUnitPlatform()
}
EOF

# Fix ai-analysis-server dependencies
echo ""
echo "=== ai-analysis-server 의존성 수정 ==="
cat > ai-analysis-server/build.gradle << 'EOF'
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.2.0'
    id 'io.spring.dependency-management' version '1.1.4'
}

group = 'com.jeonbuk.report'
version = '1.0.0'
sourceCompatibility = '17'

configurations {
    compileOnly {
        extendsFrom annotationProcessor
    }
}

repositories {
    mavenCentral()
}

dependencies {
    // Spring Boot
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
    
    // Database
    implementation 'org.postgresql:postgresql'
    implementation 'jakarta.persistence:jakarta.persistence-api:3.1.0'
    implementation 'jakarta.validation:jakarta.validation-api:3.0.2'
    
    // Redis
    implementation 'org.springframework.boot:spring-boot-starter-data-redis'
    
    // Kafka
    implementation 'org.springframework.kafka:spring-kafka'
    
    // RestTemplate
    implementation 'org.apache.httpcomponents.client5:httpclient5'
    
    // JSON Processing
    implementation 'com.fasterxml.jackson.core:jackson-databind'
    
    // Lombok
    compileOnly 'org.projectlombok:lombok'
    annotationProcessor 'org.projectlombok:lombok'
    
    // Test
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

tasks.named('test') {
    useJUnitPlatform()
}
EOF

echo ""
echo "=== 의존성 수정 완료 ==="
echo ""
echo "다음 단계: ./scripts/create-missing-entities.sh 실행"
