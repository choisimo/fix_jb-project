# Flutter 지도 및 위치 기반 서비스 PRD

## 1. 개요
**목적**: 위치 기반 신고서 시각화 및 지역별 이슈 파악  
**대상**: 신고자, 관리자, 지역 주민  
**우선순위**: 중간 (Medium)

## 2. 현재 상태
- **기존 구현**: `LocationService` 기본 구조만 존재
- **구현률**: 5% (GPS 획득 코드만)
- **누락 기능**: 지도 UI, 마커 표시, 검색, 필터링, 클러스터링

## 3. 상세 요구사항

### 3.1 메인 지도 화면 (`MapScreen`)
```yaml
지도 표시:
  - Google Maps 기본 연동
  - 현재 위치 중심으로 시작
  - 확대/축소 제스처 지원
  - 지도 회전 및 기울기 조절
  - 위성/일반/하이브리드 뷰

신고서 마커:
  - 카테고리별 아이콘 (도로/환경/안전/기타)
  - 상태별 색상 코딩 (접수/처리중/완료)
  - 우선순위별 크기 조절
  - 최근 신고 펄스 효과
  - 클러스터링 (줌아웃 시)

인터랙션:
  - 마커 탭으로 미리보기 표시
  - 롱 프레스로 신규 신고 작성
  - 핀치 줌으로 상세 레벨 조절
  - 드래그로 지역 이동
  - 더블 탭으로 빠른 확대

레이어 관리:
  - 신고서 레이어 ON/OFF
  - 히트맵 레이어 (밀도 표시)
  - 행정구역 경계 표시
  - 대중교통 정보 레이어
  - 관심 지점 (POI) 표시
```

### 3.2 지도 검색 기능 (`MapSearchWidget`)
```yaml
위치 검색:
  - 주소 검색 (도로명/지번)
  - 건물명/상호명 검색
  - 랜드마크 검색
  - GPS 좌표 검색
  - 최근 검색어 저장

자동완성:
  - 실시간 검색 제안
  - 인기 검색어 표시
  - 주변 지역 추천
  - 오타 수정 제안
  - 검색 히스토리 관리

검색 결과:
  - 지도에 결과 마커 표시
  - 목록 형태로 결과 나열
  - 거리 및 방향 정보
  - 관련 신고서 개수 표시
  - 즐겨찾기 저장 기능

필터 통합:
  - 검색 + 필터 동시 적용
  - 범위 내 검색 (반경 설정)
  - 카테고리별 검색
  - 기간별 검색 결과
```

### 3.3 마커 클러스터링 (`MarkerClusteringService`)
```yaml
클러스터 로직:
  - 줌 레벨별 그룹화
  - 거리 기반 클러스터링
  - 최대 마커 수 제한 (화면당 100개)
  - 동적 클러스터 업데이트
  - 성능 최적화 (뷰포트 기반)

클러스터 표시:
  - 숫자 배지로 개수 표시
  - 카테고리 비율 파이 차트
  - 중요도별 색상 그라데이션
  - 클러스터 크기 동적 조절
  - 애니메이션 효과

클러스터 상호작용:
  - 탭으로 확대 (스마트 줌)
  - 롱 프레스로 목록 표시
  - 피치 줌으로 클러스터 해제
  - 상세 정보 팝업 표시
  - 개별 마커로 분산

성능 최적화:
  - 백그라운드 클러스터링
  - 메모리 효율적 마커 관리
  - 화면 밖 마커 언로드
  - 점진적 로딩 (LOD)
```

### 3.4 신고서 상세 팝업 (`ReportMapPopup`)
```yaml
기본 정보:
  - 신고서 제목 (1줄)
  - 카테고리 및 우선순위
  - 작성일 및 상태
  - 작성자 (익명화 옵션)
  - 처리 진행률 표시

미리보기 이미지:
  - 대표 이미지 1장 표시
  - 이미지 스와이프 뷰어
  - 확대 보기 지원
  - 이미지 없을 시 기본 아이콘
  - 로딩 상태 표시

빠른 액션:
  - 상세 보기 버튼
  - 좋아요/공감 버튼
  - 공유 버튼
  - 북마크 저장
  - 길찾기 버튼

위치 정보:
  - 정확한 주소 표시
  - 현재 위치로부터 거리
  - 주변 관련 신고 개수
  - 대중교통 접근성
  - 지역 안전도 표시
```

### 3.5 히트맵 시각화 (`HeatmapLayer`)
```yaml
데이터 표시:
  - 신고 밀도 히트맵
  - 카테고리별 히트맵
  - 시간대별 히트맵
  - 해결률 히트맵
  - 위험도 히트맵

색상 스키마:
  - 차가운 색 → 뜨거운 색
  - 투명도 조절 가능
  - 색상 범례 표시
  - 사용자 정의 색상
  - 색맹 친화적 옵션

인터랙션:
  - 히트맵 영역 탭으로 상세 정보
  - 강도별 필터링
  - 실시간 업데이트
  - 애니메이션 효과
  - 3D 표면 지도 (옵션)

설정 옵션:
  - 반지름 크기 조절
  - 최소/최대 임계값 설정
  - 업데이트 주기 설정
  - 데이터 소스 선택
  - 성능 모드 (저사양 기기)
```

### 3.6 길찾기 및 내비게이션 (`NavigationService`)
```yaml
경로 계산:
  - 최단 거리 경로
  - 최단 시간 경로
  - 대중교통 경로
  - 도보/자전거 경로
  - 실시간 교통 정보 반영

경로 표시:
  - 지도에 경로 오버레이
  - 단계별 방향 안내
  - 예상 소요 시간
  - 교통 상황 색상 표시
  - 대안 경로 제안

내비게이션 모드:
  - 실시간 음성 안내
  - 턴-바이-턴 방향 지시
  - 재경로 자동 계산
  - 목적지 도착 알림
  - GPS 정확도 표시

외부 앱 연동:
  - Google Maps 앱 열기
  - 네이버 지도 연동
  - 카카오맵 연동
  - 공유하기 기능
  - 즐겨찾기 저장
```

## 4. 지도 필터링 시스템

### 4.1 카테고리 필터 (`CategoryFilterWidget`)
```yaml
카테고리 목록:
  - 도로/교통 (빨간색 마커)
  - 환경/청소 (초록색 마커)
  - 안전/보안 (파란색 마커)
  - 시설물/기타 (회색 마커)
  - 전체 선택/해제 토글

시각적 표현:
  - 체크박스 형태 필터
  - 색상별 아이콘 표시
  - 각 카테고리별 개수 표시
  - 활성 필터 하이라이트
  - 빠른 선택 프리셋

동적 업데이트:
  - 필터 변경 시 즉시 반영
  - 애니메이션 마커 추가/제거
  - 개수 실시간 업데이트
  - 필터 상태 저장
  - 초기화 버튼
```

### 4.2 상태 필터 (`StatusFilterWidget`)
```yaml
상태 옵션:
  - 접수됨 (주황색)
  - 처리중 (노란색)
  - 완료됨 (초록색)
  - 반려됨 (회색)
  - 보류중 (보라색)

진행률 표시:
  - 상태별 신고 개수
  - 백분율 표시
  - 프로그레스 바
  - 트렌드 화살표 (증가/감소)
  - 평균 처리 시간

고급 필터:
  - 처리 기간별 필터
  - 담당자별 필터
  - 우선순위별 필터
  - 지연 신고 하이라이트
  - 긴급 신고 우선 표시
```

### 4.3 시간 필터 (`TimeFilterWidget`)
```yaml
기간 설정:
  - 오늘 (기본)
  - 최근 일주일
  - 최근 한 달
  - 최근 3개월
  - 사용자 정의 기간

시간대 분석:
  - 시간별 신고 분포
  - 요일별 패턴
  - 계절별 트렌드
  - 실시간 vs 과거 비교
  - 예측 알고리즘 적용

달력 인터페이스:
  - 날짜 선택 달력
  - 범위 선택 지원
  - 공휴일 표시
  - 특별 이벤트 마킹
  - 빠른 선택 버튼
```

## 5. 위치 서비스 구현

### 5.1 GPS 정확도 관리
```yaml
정확도 레벨:
  - 높음: 3m 이내 (배터리 많이 소모)
  - 보통: 10m 이내 (균형)
  - 낮음: 100m 이내 (배터리 절약)
  - 자동: 상황에 따라 조절
  - 사용자 선택 가능

위치 보정:
  - WiFi 기반 보정
  - 네트워크 기반 위치
  - 센서 융합 (가속도계, 나침반)
  - 이전 위치 기반 예측
  - 지도 매칭 (도로 위 보정)

오차 처리:
  - 정확도 원 표시
  - 신뢰도 점수 계산
  - 연속 측정으로 보정
  - 이상치 필터링
  - 사용자 수동 보정 허용
```

### 5.2 배터리 최적화
```yaml
스마트 위치 추적:
  - 움직임 감지 시만 업데이트
  - 정지 상태 시 업데이트 중단
  - 배터리 잔량에 따른 조절
  - 백그라운드 업데이트 제한
  - 충전 중일 때 고정밀도 사용

효율적 API 사용:
  - 위치 업데이트 간격 조절
  - 필요 시에만 정밀 위치 요청
  - 캐시된 위치 우선 사용
  - 네트워크 기반 위치 활용
  - 센서 데이터 최소 사용

사용자 제어:
  - 위치 서비스 ON/OFF
  - 정확도 레벨 선택
  - 배터리 모드 설정
  - 백그라운드 추적 허용
  - 데이터 사용량 제한
```

## 6. 지도 데이터 모델

### 6.1 MapReport 모델
```dart
@freezed
class MapReport with _$MapReport {
  const factory MapReport({
    required String id,
    required String title,
    required ReportCategory category,
    required ReportStatus status,
    required ReportPriority priority,
    required LatLng location,
    required String address,
    String? thumbnailUrl,
    required DateTime createdAt,
    @Default(0) int likeCount,
    @Default(false) bool isBookmarked,
    double? distanceFromUser,
  }) = _MapReport;
}
```

### 6.2 MapFilter 모델
```dart
@freezed
class MapFilter with _$MapFilter {
  const factory MapFilter({
    @Default([]) List<ReportCategory> categories,
    @Default([]) List<ReportStatus> statuses,
    DateTimeRange? dateRange,
    double? radiusKm,
    ReportPriority? minPriority,
    @Default(false) bool showHeatmap,
    @Default(false) bool showClusters,
  }) = _MapFilter;
}
```

### 6.3 MapViewState 모델
```dart
@freezed
class MapViewState with _$MapViewState {
  const factory MapViewState({
    required LatLng center,
    @Default(15.0) double zoom,
    @Default(0.0) double bearing,
    @Default(0.0) double tilt,
    @Default(MapType.normal) MapType mapType,
    @Default(true) bool showMyLocation,
    @Default(true) bool showCompass,
  }) = _MapViewState;
}
```

## 7. 상태 관리 구조

### 7.1 MapState
```dart
@freezed
class MapState with _$MapState {
  const factory MapState({
    @Default([]) List<MapReport> reports,
    @Default([]) List<MapReport> visibleReports,
    MapFilter? activeFilter,
    MapViewState? viewState,
    @Default(false) bool isLoading,
    @Default(false) bool isLocationPermissionGranted,
    LatLng? currentLocation,
    String? error,
  }) = _MapState;
}
```

### 7.2 MapNotifier
```dart
class MapNotifier extends StateNotifier<MapState> {
  Future<void> loadReportsInBounds(LatLngBounds bounds);
  Future<void> applyFilter(MapFilter filter);
  Future<void> updateMapView(MapViewState viewState);
  Future<void> getCurrentLocation();
  Future<void> searchLocation(String query);
  void toggleReportVisibility(String reportId);
}
```

## 8. 성능 최적화

### 8.1 지도 렌더링 최적화
```yaml
마커 관리:
  - 화면 영역 내 마커만 표시
  - LOD (Level of Detail) 적용
  - 마커 풀링으로 메모리 절약
  - 비트맵 캐싱으로 렌더링 속도 향상
  - 클러스터링으로 마커 수 제한

타일 캐싱:
  - 지도 타일 로컬 캐싱
  - 자주 방문하는 지역 사전 캐싱
  - 오프라인 지도 지원
  - 캐시 크기 제한 및 관리
  - 네트워크 상태에 따른 품질 조절

애니메이션:
  - 하드웨어 가속 활용
  - 60fps 부드러운 애니메이션
  - 불필요한 애니메이션 제거
  - 배터리 상태에 따른 조절
  - 접근성 설정 반영
```

### 8.2 데이터 로딩 최적화
```yaml
지연 로딩:
  - 뷰포트 진입 시 데이터 로드
  - 줌 레벨에 따른 상세도 조절
  - 백그라운드 사전 로딩
  - 우선순위 기반 로딩
  - 사용자 패턴 학습

캐싱 전략:
  - 메모리 캐시 (최근 데이터)
  - 디스크 캐시 (자주 사용 데이터)
  - 네트워크 캐시 (API 응답)
  - 이미지 캐시 (썸네일)
  - 캐시 무효화 정책

압축 및 최적화:
  - JSON 데이터 압축
  - 이미지 WebP 형식 사용
  - 점진적 이미지 로딩
  - 델타 업데이트 (변경분만)
  - CDN 활용
```

## 9. 접근성 및 사용성

### 9.1 접근성 지원
```yaml
시각 장애인:
  - 지도 요소 음성 설명
  - 터치 탐색 지원
  - 고대비 지도 테마
  - 큰 마커 및 텍스트
  - 음성 안내 내비게이션

거동 불편:
  - 한 손 조작 모드
  - 음성 명령 지원
  - 제스처 단순화
  - 터치 영역 확대
  - 자동 줌 기능

인지 장애:
  - 단순화된 인터페이스
  - 명확한 아이콘 및 라벨
  - 도움말 항상 표시
  - 진행 상황 명확히 표시
  - 오류 상황 쉬운 설명
```

### 9.2 다양한 화면 크기 지원
```yaml
반응형 디자인:
  - 폰/태블릿 최적화
  - 가로/세로 모드 지원
  - 다양한 해상도 대응
  - 접이식 폰 지원
  - 노치/펀치홀 대응

UI 적응:
  - 화면 크기에 따른 레이아웃
  - 터치 영역 자동 조절
  - 글꼴 크기 스케일링
  - 아이콘 크기 조절
  - 여백 및 간격 최적화
```

## 10. 오프라인 지원

### 10.1 오프라인 지도
```yaml
지도 다운로드:
  - 관심 지역 사전 다운로드
  - 자동 다운로드 (WiFi 환경)
  - 다운로드 용량 관리
  - 지도 업데이트 알림
  - 저장소 공간 모니터링

오프라인 기능:
  - 캐시된 지도 표시
  - 저장된 신고서 보기
  - GPS 위치 추적 유지
  - 오프라인 검색 (캐시 기반)
  - 네트워크 복구 시 동기화

데이터 관리:
  - 캐시 크기 제한 (최대 2GB)
  - 오래된 데이터 자동 삭제
  - 수동 캐시 정리 옵션
  - 사용량 통계 제공
  - 셀룰러 데이터 절약 모드
```

## 11. 보안 및 개인정보

### 11.1 위치 개인정보 보호
```yaml
위치 정보 처리:
  - 정확한 위치 대신 대략적 영역 표시
  - 사용자 선택에 따른 위치 정밀도
  - 위치 정보 암호화 저장
  - 접근 로그 기록 및 모니터링
  - 제3자 공유 금지

익명화:
  - 개인 식별 정보 제거
  - 위치 데이터 집계화
  - 시간 지연 적용 (실시간 추적 방지)
  - 패턴 분석 제한
  - 사용자 동의 기반 수집
```

### 11.2 데이터 보안
```yaml
통신 보안:
  - HTTPS 강제 사용
  - API 키 보호
  - 요청 서명 검증
  - 트래픽 암호화
  - 중간자 공격 방지

저장소 보안:
  - 로컬 데이터 암호화
  - 보안 키체인 사용
  - 임시 파일 자동 삭제
  - 루팅/탈옥 감지
  - 앱 데이터 백업 제한
```

## 12. 테스트 전략

### 12.1 기능 테스트
- 지도 표시 및 인터랙션
- 마커 표시 및 클러스터링
- 검색 및 필터링 기능
- 위치 서비스 정확도

### 12.2 성능 테스트
- 대량 마커 렌더링 성능
- 메모리 사용량 측정
- 배터리 소모량 테스트
- 네트워크 효율성

### 12.3 사용성 테스트
- 지도 조작 용이성
- 검색 결과 정확성
- 필터링 직관성
- 접근성 기능 동작

## 13. 구현 일정

### 주차별 계획
```yaml
1-2주차:
  - Google Maps 기본 연동
  - 마커 표시 시스템
  - 기본 지도 인터랙션
  - 현재 위치 획득

3-4주차:
  - 검색 기능 구현
  - 필터링 시스템
  - 마커 클러스터링
  - 신고서 팝업

5-6주차:
  - 히트맵 시각화
  - 길찾기 기능
  - 오프라인 지원
  - 성능 최적화

7-8주차:
  - 접근성 구현
  - 보안 강화
  - 테스트 작성
  - 문서화
```

**총 구현 기간**: 8주  
**개발자 소요**: 1-2명 (지도 전문성 필요)  
**우선순위**: Medium (데이터 시각화 및 사용자 편의)