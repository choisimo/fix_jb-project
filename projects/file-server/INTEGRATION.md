# File Server Integration Guide

이 가이드는 JB-Project의 파일 서버를 Flutter 앱 및 Spring Boot 백엔드와 통합하는 방법을 설명합니다.

## 아키텍처 개요

```
Flutter App -> Spring Boot API -> File Server
                      ^               ^
                      |               |
                      +-------+-------+
                              |
                       AI Analysis Server
```

## 1. 시스템 설정

### 환경 변수 설정

`.env` 파일에 다음 변수를 추가하세요:

```
FILE_SERVER_URL=http://file-server:12020
FILE_SERVER_API_KEY=your_secret_api_key
AI_SERVICE_URL=http://ai-analysis-server:8080
```

## 2. Spring Boot API 통합

### 의존성 추가 (pom.xml)

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webflux</artifactId>
</dependency>
```

### 파일 서비스 클래스 생성

`FileServerClient.java` 파일을 생성하여 파일 서버와 통신하는 클라이언트를 구현합니다:

```java
package com.jeonbuk.report.infrastructure.fileserver;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.client.MultipartBodyBuilder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.Map;

@Service
public class FileServerClient {
    
    private final WebClient webClient;
    private final String apiKey;
    
    public FileServerClient(
        @Value("${fileserver.url}") String fileServerUrl,
        @Value("${fileserver.apikey}") String apiKey) {
        
        this.webClient = WebClient.builder()
            .baseUrl(fileServerUrl)
            .defaultHeader("X-Auth-Token", apiKey)
            .build();
            
        this.apiKey = apiKey;
    }
    
    public Mono<FileResponse> uploadFile(MultipartFile file, boolean analyze) {
        MultipartBodyBuilder builder = new MultipartBodyBuilder();
        builder.part("file", file.getResource());
        builder.part("analyze", String.valueOf(analyze));
        
        return webClient.post()
            .uri("/upload")
            .contentType(MediaType.MULTIPART_FORM_DATA)
            .body(BodyInserters.fromMultipartData(builder.build()))
            .retrieve()
            .bodyToMono(FileResponse.class);
    }
    
    public Mono<FileDto> getFile(String fileId) {
        return webClient.get()
            .uri("/files/{fileId}", fileId)
            .retrieve()
            .bodyToMono(FileDto.class);
    }
    
    public Mono<Void> deleteFile(String fileId) {
        return webClient.delete()
            .uri("/files/{fileId}", fileId)
            .retrieve()
            .bodyToMono(Void.class);
    }
    
    public Mono<TaskStatusResponse> getTaskStatus(String taskId) {
        return webClient.get()
            .uri("/status/{taskId}", taskId)
            .retrieve()
            .bodyToMono(TaskStatusResponse.class);
    }
}
```

### 엔티티 클래스 작성

`ReportFile.java` 엔티티를 작성하여 리포트와 파일 간의 관계를 표현합니다:

```java
@Entity
@Table(name = "report_files")
public class ReportFile {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "report_id")
    private String reportId;
    
    @Column(name = "file_id")
    private String fileId;
    
    @Column(name = "file_url")
    private String fileUrl;
    
    @Column(name = "thumbnail_url")
    private String thumbnailUrl;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    // getters, setters
}
```

### Controller 구현

리포트 컨트롤러에 파일 관련 API를 추가합니다:

```java
@RestController
@RequestMapping("/api/reports")
public class ReportController {
    // 기존 코드...
    
    private final FileServerClient fileServerClient;
    private final ReportFileRepository reportFileRepository;
    
    @PostMapping("/{id}/attach-file")
    public Mono<ResponseEntity<ReportDto>> attachFileToReport(
            @PathVariable String id,
            @RequestParam String fileId,
            @RequestParam String fileUrl,
            @RequestParam(required = false) String thumbnailUrl) {
        
        ReportFile reportFile = new ReportFile();
        reportFile.setReportId(id);
        reportFile.setFileId(fileId);
        reportFile.setFileUrl(fileUrl);
        reportFile.setThumbnailUrl(thumbnailUrl);
        reportFile.setCreatedAt(LocalDateTime.now());
        
        reportFileRepository.save(reportFile);
        
        // 리포트 정보 리턴
        return getReportById(id);
    }
    
    @DeleteMapping("/{id}/detach-file/{fileId}")
    public Mono<ResponseEntity<ReportDto>> detachFileFromReport(
            @PathVariable String id,
            @PathVariable String fileId) {
        
        reportFileRepository.deleteByReportIdAndFileId(id, fileId);
        fileServerClient.deleteFile(fileId).subscribe();
        
        return getReportById(id);
    }
    
    @GetMapping("/{id}/files")
    public List<String> getReportFileIds(@PathVariable String id) {
        return reportFileRepository.findByReportId(id)
            .stream()
            .map(ReportFile::getFileId)
            .collect(Collectors.toList());
    }
}
```

### 설정 파일 수정

`application.yml`에 다음 설정을 추가합니다:

```yaml
fileserver:
  url: ${FILE_SERVER_URL:http://file-server:12020}
  apikey: ${FILE_SERVER_API_KEY:your_secret_api_key}
```

## 3. Flutter 앱 통합

Flutter 앱의 통합은 이미 완료되었습니다. 다음과 같은 기능이 구현되어 있습니다:

1. `file_api_client.dart`: 파일 서버 API와 통신하는 Retrofit 클라이언트
2. `file_providers.dart`: 파일 관리를 위한 Riverpod 프로바이더
3. `file_upload_widget.dart`: 파일 업로드 UI 위젯
4. `file_list_widget.dart`: 파일 목록 UI 위젯
5. `report_file_attachment_widget.dart`: 리포트에 파일을 첨부하는 UI 위젯

### 의존성 추가 확인

Flutter 앱의 `pubspec.yaml` 파일에 다음 의존성이 추가되었는지 확인하세요:

```yaml
dependencies:
  # 기존 의존성...
  file_picker: ^8.0.0+1
  image_picker: ^1.0.7
  url_launcher: ^6.2.4
```

코드 생성을 위해 다음 명령어를 실행하세요:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 4. 엔드투엔드 테스트

### 테스트 시나리오

1. **파일 업로드**: Flutter 앱에서 파일을 업로드하고, 파일 서버에 저장되는지 확인
2. **AI 분석**: 업로드된 파일이 AI 분석 서버에 전송되고 분석되는지 확인
3. **리포트 첨부**: 파일이 리포트에 첨부되고 Spring Boot API에 연결되는지 확인
4. **파일 조회**: 리포트 상세 페이지에서 첨부된 파일이 정상적으로 표시되는지 확인
5. **파일 삭제**: 파일 삭제 시 파일 서버와 DB에서 모두 삭제되는지 확인

## 5. 보안 고려사항

1. 파일 서버의 API 키는 환경 변수로 관리하고, 코드에 하드코딩하지 마세요.
2. 업로드 가능한 파일 유형과 크기를 제한하세요.
3. 파일 접근 권한을 적절히 설정하세요.
4. 파일 URL에 대한 인증 및 권한 부여를 구현하세요.
5. 정기적으로 임시 파일을 정리하세요.

## 6. 모니터링 및 로깅

1. 파일 서버의 로그는 `/app/data/logs` 디렉토리에 저장됩니다.
2. 파일 서버의 상태는 `/health` 엔드포인트를 통해 확인할 수 있습니다.
3. 디스크 사용량 모니터링은 서버 상태 체크에 포함되어 있습니다.

## 7. 운영 가이드

### 백업 설정

파일 서버의 데이터 디렉토리를 정기적으로 백업하세요:

```bash
# 예시 백업 스크립트
rsync -av /path/to/file-server-data /backup/location
```

### 확장성

파일 저장소가 부족하면 다음과 같이 볼륨을 확장하세요:

1. docker-compose.yml 파일에서 볼륨 설정 확인
2. 필요에 따라 외부 스토리지 솔루션 연결
3. 파일 서버는 외부 스토리지 경로를 환경 변수로 설정 가능
