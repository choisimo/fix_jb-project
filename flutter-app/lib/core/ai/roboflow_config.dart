import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Roboflow API 설정 관리자
class RoboflowConfig {
  static final RoboflowConfig _instance = RoboflowConfig._internal();
  static RoboflowConfig get instance => _instance;
  RoboflowConfig._internal();

  // 기본 설정값
  static const String _defaultApiUrl = 'https://detect.roboflow.com';
  static const String _defaultWorkspace = 'jeonbuk-reports';
  static const String _defaultProject = 'integrated-detection';
  static const int _defaultVersion = 1;
  static const int _defaultConfidence = 50;
  static const int _defaultOverlap = 30;
  
  // 설정 키
  static const String _keyApiKey = 'roboflow_api_key';
  static const String _keyWorkspace = 'roboflow_workspace';
  static const String _keyProject = 'roboflow_project';
  static const String _keyVersion = 'roboflow_version';
  static const String _keyConfidence = 'roboflow_confidence';
  static const String _keyOverlap = 'roboflow_overlap';
  static const String _keyUseBackend = 'roboflow_use_backend';
  static const String _keyBackendUrl = 'roboflow_backend_url';

  SharedPreferences? _prefs;

  /// 초기화
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      debugPrint('✅ Roboflow 설정 관리자 초기화 완료');
    } catch (e) {
      debugPrint('❌ 설정 관리자 초기화 실패: $e');
    }
  }

  /// API 키 설정
  Future<bool> setApiKey(String apiKey) async {
    try {
      if (_prefs == null) await initialize();
      final success = await _prefs!.setString(_keyApiKey, apiKey.trim());
      if (success) {
        debugPrint('🔑 API 키 저장 완료: ${_maskApiKey(apiKey)}');
      }
      return success;
    } catch (e) {
      debugPrint('❌ API 키 저장 실패: $e');
      return false;
    }
  }

  /// API 키 가져오기
  Future<String?> getApiKey() async {
    try {
      if (_prefs == null) await initialize();
      final apiKey = _prefs!.getString(_keyApiKey);
      if (apiKey != null && apiKey.isNotEmpty) {
        debugPrint('🔑 API 키 로드: ${_maskApiKey(apiKey)}');
      }
      return apiKey;
    } catch (e) {
      debugPrint('❌ API 키 로드 실패: $e');
      return null;
    }
  }

  /// 워크스페이스 설정
  Future<bool> setWorkspace(String workspace) async {
    try {
      if (_prefs == null) await initialize();
      return await _prefs!.setString(_keyWorkspace, workspace.trim());
    } catch (e) {
      debugPrint('❌ 워크스페이스 저장 실패: $e');
      return false;
    }
  }

  /// 워크스페이스 가져오기
  Future<String> getWorkspace() async {
    try {
      if (_prefs == null) await initialize();
      return _prefs!.getString(_keyWorkspace) ?? _defaultWorkspace;
    } catch (e) {
      debugPrint('❌ 워크스페이스 로드 실패: $e');
      return _defaultWorkspace;
    }
  }

  /// 프로젝트 설정
  Future<bool> setProject(String project) async {
    try {
      if (_prefs == null) await initialize();
      return await _prefs!.setString(_keyProject, project.trim());
    } catch (e) {
      debugPrint('❌ 프로젝트 저장 실패: $e');
      return false;
    }
  }

  /// 프로젝트 가져오기
  Future<String> getProject() async {
    try {
      if (_prefs == null) await initialize();
      return _prefs!.getString(_keyProject) ?? _defaultProject;
    } catch (e) {
      debugPrint('❌ 프로젝트 로드 실패: $e');
      return _defaultProject;
    }
  }

  /// 모델 버전 설정
  Future<bool> setVersion(int version) async {
    try {
      if (_prefs == null) await initialize();
      return await _prefs!.setInt(_keyVersion, version);
    } catch (e) {
      debugPrint('❌ 버전 저장 실패: $e');
      return false;
    }
  }

  /// 모델 버전 가져오기
  Future<int> getVersion() async {
    try {
      if (_prefs == null) await initialize();
      return _prefs!.getInt(_keyVersion) ?? _defaultVersion;
    } catch (e) {
      debugPrint('❌ 버전 로드 실패: $e');
      return _defaultVersion;
    }
  }

  /// 신뢰도 임계값 설정
  Future<bool> setConfidenceThreshold(int confidence) async {
    try {
      if (_prefs == null) await initialize();
      if (confidence < 0 || confidence > 100) {
        debugPrint('⚠️ 잘못된 신뢰도 값: $confidence (0-100 범위)');
        return false;
      }
      return await _prefs!.setInt(_keyConfidence, confidence);
    } catch (e) {
      debugPrint('❌ 신뢰도 저장 실패: $e');
      return false;
    }
  }

  /// 신뢰도 임계값 가져오기
  Future<int> getConfidenceThreshold() async {
    try {
      if (_prefs == null) await initialize();
      return _prefs!.getInt(_keyConfidence) ?? _defaultConfidence;
    } catch (e) {
      debugPrint('❌ 신뢰도 로드 실패: $e');
      return _defaultConfidence;
    }
  }

  /// 겹침 임계값 설정
  Future<bool> setOverlapThreshold(int overlap) async {
    try {
      if (_prefs == null) await initialize();
      if (overlap < 0 || overlap > 100) {
        debugPrint('⚠️ 잘못된 겹침 값: $overlap (0-100 범위)');
        return false;
      }
      return await _prefs!.setInt(_keyOverlap, overlap);
    } catch (e) {
      debugPrint('❌ 겹침 저장 실패: $e');
      return false;
    }
  }

  /// 겹침 임계값 가져오기
  Future<int> getOverlapThreshold() async {
    try {
      if (_prefs == null) await initialize();
      return _prefs!.getInt(_keyOverlap) ?? _defaultOverlap;
    } catch (e) {
      debugPrint('❌ 겹침 로드 실패: $e');
      return _defaultOverlap;
    }
  }

  /// 백엔드 사용 여부 설정
  Future<bool> setUseBackend(bool useBackend) async {
    try {
      if (_prefs == null) await initialize();
      return await _prefs!.setBool(_keyUseBackend, useBackend);
    } catch (e) {
      debugPrint('❌ 백엔드 설정 저장 실패: $e');
      return false;
    }
  }

  /// 백엔드 사용 여부 가져오기
  Future<bool> getUseBackend() async {
    try {
      if (_prefs == null) await initialize();
      return _prefs!.getBool(_keyUseBackend) ?? false;
    } catch (e) {
      debugPrint('❌ 백엔드 설정 로드 실패: $e');
      return false;
    }
  }

  /// 백엔드 URL 설정
  Future<bool> setBackendUrl(String url) async {
    try {
      if (_prefs == null) await initialize();
      return await _prefs!.setString(_keyBackendUrl, url.trim());
    } catch (e) {
      debugPrint('❌ 백엔드 URL 저장 실패: $e');
      return false;
    }
  }

  /// 백엔드 URL 가져오기
  Future<String> getBackendUrl() async {
    try {
      if (_prefs == null) await initialize();
      return _prefs!.getString(_keyBackendUrl) ?? 'http://localhost:8080';
    } catch (e) {
      debugPrint('❌ 백엔드 URL 로드 실패: $e');
      return 'http://localhost:8080';
    }
  }

  /// 현재 모든 설정 가져오기
  Future<Map<String, dynamic>> getCurrentSettings() async {
    try {
      if (_prefs == null) await initialize();
      
      return {
        'api_key': await getApiKey() ?? '',
        'workspace': await getWorkspace(),
        'project': await getProject(),
        'version': await getVersion(),
        'confidence_threshold': await getConfidenceThreshold(),
        'overlap_threshold': await getOverlapThreshold(),
        'use_backend': await getUseBackend(),
        'backend_url': await getBackendUrl(),
      };
    } catch (e) {
      debugPrint('❌ 설정 로드 오류: $e');
      return {
        'api_key': '',
        'workspace': _defaultWorkspace,
        'project': _defaultProject,
        'version': _defaultVersion,
        'confidence_threshold': _defaultConfidence,
        'overlap_threshold': _defaultOverlap,
        'use_backend': false,
        'backend_url': '',
      };
    }
  }

  /// 설정 유효성 검증
  Future<bool> validateSettings() async {
    try {
      final settings = await getCurrentSettings();
      
      // 필수 설정 검증
      final apiKey = settings['api_key'] as String;
      final workspace = settings['workspace'] as String;
      final project = settings['project'] as String;
      
      if (apiKey.isEmpty || apiKey.length < 10) {
        debugPrint('❌ 유효하지 않은 API 키');
        return false;
      }
      
      if (workspace.isEmpty || workspace.length < 3) {
        debugPrint('❌ 유효하지 않은 워크스페이스');
        return false;
      }
      
      if (project.isEmpty || project.length < 3) {
        debugPrint('❌ 유효하지 않은 프로젝트');
        return false;
      }
      
      // 숫자 값 검증
      final confidence = settings['confidence_threshold'] as int;
      final overlap = settings['overlap_threshold'] as int;
      final version = settings['version'] as int;
      
      if (confidence < 0 || confidence > 100) {
        debugPrint('❌ 잘못된 신뢰도 값: $confidence');
        return false;
      }
      
      if (overlap < 0 || overlap > 100) {
        debugPrint('❌ 잘못된 겹침 값: $overlap');
        return false;
      }
      
      if (version < 1) {
        debugPrint('❌ 잘못된 버전 값: $version');
        return false;
      }
      
      debugPrint('✅ 모든 설정이 유효합니다');
      return true;
      
    } catch (e) {
      debugPrint('❌ 설정 검증 오류: $e');
      return false;
    }
  }

  /// 전체 설정 초기화
  Future<bool> resetAllSettings() async {
    try {
      if (_prefs == null) await initialize();
      
      final keys = [
        _keyApiKey, _keyWorkspace, _keyProject, _keyVersion,
        _keyConfidence, _keyOverlap, _keyUseBackend, _keyBackendUrl
      ];
      
      for (final key in keys) {
        await _prefs!.remove(key);
      }
      
      debugPrint('✅ 모든 설정 초기화 완료');
      return true;
      
    } catch (e) {
      debugPrint('❌ 설정 초기화 실패: $e');
      return false;
    }
  }

  /// 설정 상태 출력
  Future<void> printCurrentSettings() async {
    final settings = await getCurrentSettings();
    debugPrint('🔧 현재 Roboflow 설정:');
    debugPrint('  API 키: ${_maskApiKey(settings['api_key'])}');
    debugPrint('  워크스페이스: ${settings['workspace']}');
    debugPrint('  프로젝트: ${settings['project']}');
    debugPrint('  버전: ${settings['version']}');
    debugPrint('  신뢰도: ${settings['confidence_threshold']}%');
    debugPrint('  겹침: ${settings['overlap_threshold']}%');
    debugPrint('  백엔드 사용: ${settings['use_backend']}');
    debugPrint('  백엔드 URL: ${settings['backend_url']}');
  }

  /// API 키 마스킹
  String _maskApiKey(String? apiKey) {
    if (apiKey == null || apiKey.isEmpty) return '❌ 미설정';
    if (apiKey.length < 8) return '⚠️ 너무 짧음';
    return '✅ ${apiKey.substring(0, 8)}...';
  }

  /// API 키 유효성 확인
  Future<bool> hasValidApiKey() async {
    final apiKey = await getApiKey();
    return apiKey != null && 
           apiKey.isNotEmpty && 
           apiKey.length > 10 &&
           apiKey != 'your-roboflow-api-key';
  }

  /// 모델 엔드포인트 URL 생성
  Future<String> getModelEndpointUrl() async {
    final workspace = await getWorkspace();
    final project = await getProject();
    final version = await getVersion();
    return '$_defaultApiUrl/$workspace/$project/$version';
  }
}
