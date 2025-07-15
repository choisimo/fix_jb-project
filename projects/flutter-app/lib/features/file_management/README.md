# File Management Feature

이 기능은 파일 서버와 Flutter 앱 간의 연동을 위한 것입니다.

## 초기 설정

코드 생성을 위해 다음 명령어를 실행하세요:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

이 명령어는 다음 파일들을 생성합니다:
- `file_api_client.g.dart`
- `file_dto.g.dart`

## 기능

- 파일 업로드 (이미지, 문서 등)
- 파일 목록 조회
- 파일 삭제
- 파일 분석 상태 확인
- 이미지 썸네일 생성

## 사용 방법

### 1. 파일 업로드 위젯 사용하기

```dart
FileUploadWidget(
  allowMultiple: true,  // 다중 파일 업로드 허용
  analyzeFiles: true,   // 파일 분석 요청
  tags: ['report', 'evidence'],  // 태그 추가
  onUploadSuccess: (files) {
    // 성공 시 처리
  },
  onUploadError: (error) {
    // 오류 시 처리
  },
)
```

### 2. 파일 목록 위젯 사용하기

```dart
FileListWidget(
  showAnalysisStatus: true,  // 분석 상태 표시
  allowDelete: true,         // 삭제 버튼 표시
  onFileTap: (file) {
    // 파일 탭 시 처리
  },
)
```

### 3. 리포트 기능과 통합

리포트에 파일 첨부 시 다음과 같이 사용:

```dart
// 리포트에 파일 첨부
final fileService = ref.read(fileServiceProvider);
final uploadResponse = await fileService.uploadFile(
  file,
  analyze: true,
  tags: ['report', reportId],
);

// 파일 ID를 리포트에 저장
final reportRepository = ref.read(reportRepositoryProvider);
await reportRepository.attachFileToReport(reportId, uploadResponse.fileId);
```
