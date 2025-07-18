import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_naver_map/flutter_naver_map.dart';

import '../../../core/presentation/widgets/loading_overlay.dart';
import '../../../core/services/map_service.dart';
import '../../../core/providers/service_provider.dart' hide reportServiceProvider;
import '../../image_analysis/domain/models/image_analysis_result.dart';
import '../../image_analysis/domain/services/image_analysis_service.dart';
import '../data/models/report_dto.dart';
import '../data/providers/report_providers.dart';
import '../domain/models/report.dart';
import '../domain/services/report_service.dart';


class CreateReportScreen extends ConsumerStatefulWidget {
  const CreateReportScreen({super.key});

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _imagePicker = ImagePicker();
  
  // 신고서 상태 관리
  bool _isLoading = false;
  bool _isAnalyzing = false;
  bool _isLoadingLocation = false;
  String? _analysisError;
  ComprehensiveAnalysisResult? _analysisResult;
  
  // 선택된 이미지들
  List<XFile> _selectedImages = [];
  
  // 위치 정보
  Position? _currentLocation;
  String _currentAddress = 'No location selected';
  
  // 타입 및 우선순위 선택
  ReportType _selectedType = ReportType.roadDamage;
  Priority _selectedPriority = Priority.medium;
  
  // 분석 서비스
  late ImageAnalysisService _analysisService;
  
  // 네이버 맵 컨트롤러
  NaverMapController? _mapController;
  
  @override
  void initState() {
    super.initState();
    // 서비스 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Dio 인스턴스를 가져와서 ImageAnalysisService 생성
      final dio = ref.read(dioProvider);
      _analysisService = ImageAnalysisService(dio);
      
      // 초기 위치 정보 가져오기 시도
      _getCurrentLocation().catchError((e) {
        // 위치 가져오기 실패 시 조용히 무시
        print('위치 초기화 중 오류: $e');
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('신고서 작성'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.image), text: '이미지'),
                  Tab(icon: Icon(Icons.description), text: '정보'),
                  Tab(icon: Icon(Icons.location_on), text: '위치'),
                ],
              ),
              actions: [
                if (_selectedImages.isNotEmpty)
                  IconButton(
                    onPressed: _analyzeImages,
                    tooltip: 'AI 분석',
                    icon: const Icon(Icons.auto_fix_high),
                  )
              ],
            ),
            body: Form(
              key: _formKey,
              child: TabBarView(
                children: [
                  // 이미지 탭
                  _buildImagesTab(),
                  
                  // 정보 탭
                  _buildInfoTab(),
                  
                  // 위치 탭
                  _buildLocationTab(),
                ],
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        width: 24, 
                        height: 24, 
                        child: CircularProgressIndicator(color: Colors.white))
                    : const Text('신고서 제출', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
        ),
        // 분석 중 표시
        if (_isAnalyzing) 
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('이미지 분석중...', style: TextStyle(fontSize: 16)),
                      Text('잠시만 기다려주세요', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // 이미지 탭 구현
  Widget _buildImagesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 선택 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '이미지 추가 (${_selectedImages.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImages(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('카메라'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      backgroundColor: Colors.amber.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _pickImages(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('갤러리'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      backgroundColor: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 선택된 이미지 목록
          Expanded(
            child: _selectedImages.isEmpty
                ? _buildEmptyImagesView()
                : _buildImageGrid(),
          ),
          
          // AI 분석 결과
          if (_analysisResult != null)
            _buildAnalysisResultCard(),
          
          // 에러 표시
          if (_analysisError != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _analysisError!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
        ],
      ),
    );
  }
  
  // 정보 탭 구현
  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 필드
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: '제목',
              border: const OutlineInputBorder(),
              suffixIcon: _analysisResult != null
                  ? IconButton(
                      icon: const Icon(Icons.auto_fix_high, color: Colors.blue),
                      onPressed: _autoFillTitle,
                      tooltip: 'AI 분석에서 추천',
                    )
                  : null,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '제목을 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // 내용 필드
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: '설명',
              border: const OutlineInputBorder(),
              suffixIcon: _analysisResult != null
                  ? IconButton(
                      icon: const Icon(Icons.auto_fix_high, color: Colors.blue),
                      onPressed: _autoFillDescription,
                      tooltip: 'AI 분석에서 추천',
                    )
                  : null,
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '설명을 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // 신고 타입 선택
          const Text('신고 타입', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<ReportType>(
            value: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.category),
            ),
            items: ReportType.values.map((type) {
              return DropdownMenuItem<ReportType>(
                value: type,
                child: Text(_getTypeDisplayName(type)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedType = value);
              }
            },
          ),
          const SizedBox(height: 16),
          
          // 우선순위 선택
          const Text('우선순위', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<Priority>(
            value: _selectedPriority,
            decoration: InputDecoration(
              labelText: 'Priority',
              border: const OutlineInputBorder(),
              suffixIcon: _analysisResult != null
                  ? IconButton(
                      icon: const Icon(Icons.auto_fix_high, color: Colors.blue),
                      onPressed: _autoFillPriority,
                      tooltip: 'AI 분석에서 추천',
                    )
                  : null,
            ),
            items: Priority.values.map((priority) {
              return DropdownMenuItem<Priority>(
                value: priority,
                child: Text(_getPriorityDisplayName(priority)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedPriority = value);
              }
            },
          ),
          const SizedBox(height: 20),
          
          // AI 분석 추천 버튼
          if (_analysisResult != null)
            Center(
              child: ElevatedButton.icon(
                onPressed: _autoFillAll,
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('모든 필드 자동 채우기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // 위치 탭 구현
  Widget _buildLocationTab() {
    return Column(
      children: [
        // 현재 위치
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('현재 위치', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: '주소',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: () => _getCurrentLocation(),
                    tooltip: '현재 위치 가져오기',
                  ),
                ),
                readOnly: true,
                onTap: () => _getCurrentLocation(),
              ),
              const SizedBox(height: 8),
              Text(
                _currentAddress,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ],
          ),
        ),
        
        // 지도 표시
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    '현재 위치: $_currentAddress',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: _currentLocation != null
                      ? NaverMap(
                          options: NaverMapViewOptions(
                            indoorEnable: true,
                            locationButtonEnable: true,
                            nightModeEnable: false,
                            scaleBarEnable: true,
                            rotationGesturesEnable: true,
                            scrollGesturesEnable: true,
                            zoomGesturesEnable: true,
                            tiltGesturesEnable: true,
                            mapType: NMapType.basic,
                            initialCameraPosition: NCameraPosition(
                              target: NLatLng(
                                _currentLocation?.latitude ?? 37.5665,
                                _currentLocation?.longitude ?? 126.9780
                              ),
                              zoom: 16,
                            ),
                          ),
                          onMapReady: (controller) {
                            _mapController = controller;
                            
                            // 위치 추적 모드 설정
                            controller.setLocationTrackingMode(NLocationTrackingMode.follow);
                            
                            // 내 위치 마커 추가
                            if (_currentLocation != null) {
                              controller.addOverlay(
                                NMarker(
                                  id: 'currentLocation',
                                  position: NLatLng(
                                    _currentLocation!.latitude,
                                    _currentLocation!.longitude,
                                  ),
                                  size: const Size(30, 40),
                                  anchor: const NPoint(0.5, 1.0),
                                )
                              );
                            }
                            
                            // 지도 정상 로드 확인 메시지
                            print('네이버 지도가 정상적으로 로드되었습니다.');
                          },
                          onMapTapped: (point, latLng) {
                            print('지도를 탭했습니다: ${latLng.latitude}, ${latLng.longitude}');
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                '위치를 선택해주세요',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _getCurrentLocation,
                                icon: const Icon(Icons.my_location),
                                label: _isLoadingLocation 
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text('위치 확인 중...')
                                      ],
                                    )
                                  : const Text('현재 위치 가져오기'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // 빈 이미지 리스트 표시
  Widget _buildEmptyImagesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('신고서에 몇 개의 이미지를 추가해주세요',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImages(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('카메라'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _pickImages(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('갤러리'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 이미지 그리드 구현
  Widget _buildImageGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) {
        final image = _selectedImages[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            // 이미지 표시
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(image.path),
                fit: BoxFit.cover,
              ),
            ),
            // 삭제 버튼
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // 분석 결과 카드 구현
  Widget _buildAnalysisResultCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'AI 분석 결과',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const Spacer(),
                // 정확도 표시
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(_analysisResult!.overallConfidence),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '정확도: ${(_analysisResult!.overallConfidence * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            // 추천 정보 표시
            if (_analysisResult!.suggestedTitle != null)
              _buildSuggestionItem(
                '제목', 
                _analysisResult!.suggestedTitle!, 
                _autoFillTitle
              ),
            if (_analysisResult!.suggestedDescription != null)
              _buildSuggestionItem(
                '설명', 
                _analysisResult!.suggestedDescription!, 
                _autoFillDescription
              ),
            if (_analysisResult!.suggestedType != null)
              _buildSuggestionItem(
                '유형', 
                _analysisResult!.suggestedType!, 
                _autoFillType
              ),
            if (_analysisResult!.suggestedPriority != null)
              _buildSuggestionItem(
                '우선순위', 
                _analysisResult!.suggestedPriority!, 
                _autoFillPriority
              ),
          ],
        ),
      ),
    );
  }
  
  // 추천 항목 아이템 구현
  Widget _buildSuggestionItem(String label, String value, VoidCallback onApply) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
            onPressed: onApply,
            tooltip: '적용하기',
            constraints: const BoxConstraints(minWidth: 24),
            padding: EdgeInsets.zero,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
  
  // 신뢰도 색상 가져오기
  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.8) return Colors.green;
    if (confidence > 0.6) return Colors.orange;
    return Colors.red;
  }
  
  // 타입 표시용 이름
  String _getTypeDisplayName(ReportType type) {
    switch (type) {
      case ReportType.pothole:
        return '포트홀';
      case ReportType.streetLight:
        return '가로등';
      case ReportType.trash:
        return '쓰레기';
      case ReportType.graffiti:
        return '낭서';
      case ReportType.roadDamage:
        return '도로 파손';
      case ReportType.construction:
        return '공사장';
      case ReportType.other:
        return '기타';
    }
  }
  
  // 우선순위 표시용 이름
  String _getPriorityDisplayName(Priority priority) {
    switch (priority) {
      case Priority.low:
        return '낮음';
      case Priority.medium:
        return '중간';
      case Priority.high:
        return '높음';
      case Priority.urgent:
        return '긴급';
    }
  }
  
  // 이미지 선택하기
  Future<void> _pickImages(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        // 갤러리에서 여러 이미지 선택
        final pickedFiles = await _imagePicker.pickMultiImage(
          imageQuality: 85,  // 이미지 품질 향상
          maxWidth: 2000,     // 최대 너비 증가
        );
        
        if (pickedFiles.isNotEmpty && mounted) {
          setState(() {
            _selectedImages.addAll(pickedFiles);
            // AI 분석 결과 초기화
            _analysisResult = null;
            _analysisError = null;
          });
          
          // 이미지가 선택되면 자동으로 AI 분석 수행
          if (_selectedImages.length == pickedFiles.length) {
            // 처음 이미지를 선택한 경우에만 자동 분석
            _analyzeImages();
          }
        }
      } else {
        // 카메라로 촬영
        final pickedFile = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          maxWidth: 2000,
          preferredCameraDevice: CameraDevice.rear,
        );
        
        if (pickedFile != null && mounted) {
          setState(() {
            _selectedImages.add(pickedFile);
            // AI 분석 결과 초기화
            _analysisResult = null;
            _analysisError = null;
          });
          
          // 첫 이미지를 촬영한 경우 자동으로 AI 분석 수행
          if (_selectedImages.length == 1) {
            _analyzeImages();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 중 오류 발생: $e')),
        );
      }
    }
  }
  
  // 이미지 삭제
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      // 이미지 변경시 분석 결과 초기화
      if (_selectedImages.isEmpty) {
        _analysisResult = null;
        _analysisError = null;
      }
    });
  }
  
  // 맵 생성 완료시 콜백
  Future<void> _getCurrentLocation() async {
    try {
      // 위치 가져오기 시작 표시
      setState(() {
        _isLoadingLocation = true;
      });
      
      final mapService = ref.read(mapServiceProvider);
      
      // 위치 권한 체크 및 요청
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || 
            permission == LocationPermission.deniedForever) {
          throw Exception('위치 권한이 거부되었습니다');
        }
      }
      
      // 현재 위치 가져오기
      final position = await mapService.getCurrentLocation();
      final address = await mapService.getAddressFromCoordinates(
        position.latitude, 
        position.longitude,
      );
      
      // 위치 및 주소 업데이트
      _updateLocationAndAddress(position, address);
      
      // 네이버 맵 컨트롤러가 있을 경우 카메라 이동
      if (_mapController != null) {
        _mapController!.updateCamera(
          NCameraUpdate.withParams(
            target: NLatLng(position.latitude, position.longitude),
            zoom: 16
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('위치를 가져올 수 없습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _updateLocationAndAddress(Position position, [String? address]) async {
    final mapService = ref.read(mapServiceProvider);
    setState(() {
      _currentLocation = position;
      _currentAddress = address ?? 'Loading address...';
      _locationController.text = _currentAddress;
    });
    
    if (address == null) {
      try {
        final newAddress = await mapService.getAddressFromCoordinates(
          position.latitude, 
          position.longitude,
        );
        setState(() {
          _currentAddress = newAddress;
          _locationController.text = _currentAddress;
        });
      } catch (e) {
        print('Failed to get address: $e');
      }
    }
  }
  // 이미지 분석하기
  Future<void> _analyzeImages() async {
    if (_selectedImages.isEmpty) {
      setState(() {
        _analysisError = '이미지를 먼저 선택해주세요';
      });
      return;
    }
    
    setState(() {
      _isAnalyzing = true;
      _analysisError = null;
    });
    
    try {
      // 대표 이미지 선택 (첫 번째 이미지)
      final file = File(_selectedImages.first.path);
      
      // 파일 검증
      if (!await file.exists()) {
        throw Exception('이미지 파일을 찾을 수 없습니다');
      }
      
      // 파일 크기 체크
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) { // 10MB 이상
        throw Exception('이미지 파일이 너무 큽니다. 10MB 이하의 파일만 허용됩니다.');
      }
      
      // 이미지 분석 서비스 호출 - 올바른 메소드명 사용
      ComprehensiveAnalysisResult result = await _analysisService.analyzeImageComprehensive(file);
      
      // 결과 업데이트
      if (mounted) {
        setState(() {
          _analysisResult = result;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisError = '이미지 분석 중 오류 발생: ${e.toString()}';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 분석 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // 제목 자동 채우기
  void _autoFillTitle() {
    if (_analysisResult?.suggestedTitle != null) {
      setState(() {
        _titleController.text = _analysisResult!.suggestedTitle!;
      });
    }
  }
  
  // 설명 자동 채우기
  void _autoFillDescription() {
    if (_analysisResult?.suggestedDescription != null) {
      setState(() {
        _descriptionController.text = _analysisResult!.suggestedDescription!;
      });
    }
  }
  
  // 타입 자동 채우기
  void _autoFillType() {
    if (_analysisResult?.suggestedType != null) {
      setState(() {
        _selectedType = _stringToReportType(_analysisResult!.suggestedType!);
      });
    }
  }
  
  // 우선순위 자동 채우기
  void _autoFillPriority() {
    if (_analysisResult?.suggestedPriority != null) {
      setState(() {
        _selectedPriority = _stringToPriority(_analysisResult!.suggestedPriority!);
      });
    }
  }

  // String을 ReportType으로 변환
  ReportType _stringToReportType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'pothole':
        return ReportType.pothole;
      case 'streetlight':
        return ReportType.streetLight;
      case 'trash':
        return ReportType.trash;
      case 'graffiti':
        return ReportType.graffiti;
      case 'construction':
        return ReportType.construction;
      case 'roaddamage':
      default:
        return ReportType.roadDamage;
    }
  }

  // String을 Priority로 변환
  Priority _stringToPriority(String priorityString) {
    switch (priorityString.toLowerCase()) {
      case 'high':
        return Priority.high;
      case 'low':
        return Priority.low;
      case 'medium':
      default:
        return Priority.medium;
    }
  }
  
  // 모든 필드 자동 채우기
  void _autoFillAll() {
    _autoFillTitle();
    _autoFillDescription();
    _autoFillType();
    _autoFillPriority();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI 분석 결과로 모든 항목을 채웠습니다')),
    );
  }
  
  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      // 이미지 검증
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지를 최소한 1개 이상 추가해주세요')),
        );
        return;
      }
      
      // 위치 정보 검증
      if (_currentLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 정보를 추가해주세요. [위치] 탭에서 현재 위치를 설정하세요.')),
        );
        return;
      }
      
      setState(() {
        _isLoading = true;
      });

      try {
        final reportService = ref.read(reportServiceProvider);
        
        // 위치 정보 포맷
        final locationString = _currentLocation != null
            ? '${_currentAddress} (${_currentLocation!.latitude}, ${_currentLocation!.longitude})'
            : _currentAddress;
        
        // ReportDto 생성
        final reportDto = ReportDto(
          id: null, // 신규
          title: _titleController.text,
          description: _descriptionController.text,
          type: _selectedType.toString().split('.').last,
          priority: _selectedPriority.toString().split('.').last,
          status: 'pending',
          location: locationString,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        print('📋 Submitting report: ${reportDto.title}');
        print('📍 Location: $locationString');
        print('🖼️ Images: ${_selectedImages.length}');
        
        // 신고서 제출
        reportService.createReport(reportDto, _selectedImages).then((result) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('신고서가 성공적으로 제출되었습니다!')),
            );
            
            Navigator.pop(context);
          }
        }).catchError((error) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('신고서 제출 실패: ${error.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('신고서 생성 오류: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}