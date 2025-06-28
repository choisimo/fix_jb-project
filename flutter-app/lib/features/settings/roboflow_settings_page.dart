import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/ai/roboflow_config.dart';
import '../../core/ai/roboflow_service.dart';

class RoboflowSettingsPage extends StatefulWidget {
  const RoboflowSettingsPage({super.key});

  @override
  State<RoboflowSettingsPage> createState() => _RoboflowSettingsPageState();
}

class _RoboflowSettingsPageState extends State<RoboflowSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final RoboflowConfig _config = RoboflowConfig.instance;
  
  // 컨트롤러들
  final _apiKeyController = TextEditingController();
  final _workspaceController = TextEditingController();
  final _projectController = TextEditingController();
  final _versionController = TextEditingController();
  final _confidenceController = TextEditingController();
  final _overlapController = TextEditingController();
  final _backendUrlController = TextEditingController();
  
  bool _useBackend = false;
  bool _isLoading = false;
  bool _isTestingConnection = false;
  String? _connectionTestResult;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _workspaceController.dispose();
    _projectController.dispose();
    _versionController.dispose();
    _confidenceController.dispose();
    _overlapController.dispose();
    _backendUrlController.dispose();
    super.dispose();
  }

  /// 현재 설정 로드
  Future<void> _loadCurrentSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final settings = await _config.getCurrentSettings();
      
      setState(() {
        _apiKeyController.text = settings['api_key'] ?? '';
        _workspaceController.text = settings['workspace'] ?? '';
        _projectController.text = settings['project'] ?? '';
        _versionController.text = settings['version'].toString();
        _confidenceController.text = settings['confidence_threshold'].toString();
        _overlapController.text = settings['overlap_threshold'].toString();
        _backendUrlController.text = settings['backend_url'] ?? '';
        _useBackend = settings['use_backend'] ?? false;
      });
    } catch (e) {
      _showError('설정 로드 실패: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 설정 저장 (개선된 버전)
  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // RoboflowService의 saveAllSettings 메서드 사용
      final success = await RoboflowService.saveAllSettings(
        apiKey: _apiKeyController.text.trim(),
        workspace: _workspaceController.text.trim(),
        project: _projectController.text.trim(),
      );
      
      if (success) {
        // 추가 설정들 저장
        await _config.setVersion(int.parse(_versionController.text));
        await _config.setConfidenceThreshold(int.parse(_confidenceController.text));
        await _config.setOverlapThreshold(int.parse(_overlapController.text));
        await _config.setUseBackend(_useBackend);
        await _config.setBackendUrl(_backendUrlController.text.trim());
        
        _showSuccess('✅ 모든 설정이 성공적으로 저장되었습니다');
        
        // 설정 저장 후 검증
        final isValid = await _config.validateSettings();
        if (!isValid) {
          _showWarning('⚠️ 설정이 저장되었지만 일부 값이 유효하지 않을 수 있습니다');
        }
      } else {
        _showError('❌ 필수 설정(API Key, Workspace, Project) 저장에 실패했습니다');
      }
      
    } catch (e) {
      _showError('❌ 설정 저장 중 오류 발생: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// API 연결 테스트
  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionTestResult = null;
    });
    
    try {
      // 임시로 현재 입력값들을 저장
      await _saveSettings();
      
      // 연결 테스트
      final isConnected = await RoboflowService.instance.testConnection();
      
      setState(() {
        _connectionTestResult = isConnected 
          ? '✅ 연결 성공! API가 정상적으로 작동합니다.'
          : '❌ 연결 실패. API 키와 프로젝트 설정을 확인해주세요.';
      });
      
    } catch (e) {
      setState(() {
        _connectionTestResult = '❌ 연결 테스트 실패: $e';
      });
    } finally {
      setState(() => _isTestingConnection = false);
    }
  }

  /// 설정 초기화
  Future<void> _resetSettings() async {
    final confirm = await _showConfirmDialog(
      '설정 초기화',
      '모든 설정을 초기화하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
    );
    
    if (!confirm) return;
    
    setState(() => _isLoading = true);
    
    try {
      await _config.resetAllSettings();
      await _loadCurrentSettings();
      _showSuccess('설정이 초기화되었습니다');
    } catch (e) {
      _showError('설정 초기화 실패: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roboflow AI 설정'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showSetupGuide,
            tooltip: '설정 가이드',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCurrentSettings,
            tooltip: '설정 새로고침',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'reset':
                  _resetSettings();
                  break;
                case 'test':
                  _testConnection();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'test',
                child: Row(
                  children: [
                    Icon(Icons.wifi_protected_setup),
                    SizedBox(width: 8),
                    Text('연결 테스트'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restore, color: Colors.red),
                    SizedBox(width: 8),
                    Text('설정 초기화'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildConnectionStatusCard(),
                    const SizedBox(height: 16),
                    _buildApiSettingsCard(),
                    const SizedBox(height: 16),
                    _buildModelSettingsCard(),
                    const SizedBox(height: 16),
                    _buildBackendSettingsCard(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  /// 연결 상태 카드
  Widget _buildConnectionStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.wifi_protected_setup, color: Colors.blue),
                SizedBox(width: 8),
                Text('연결 상태', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (_connectionTestResult != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _connectionTestResult!.startsWith('✅') 
                    ? Colors.green.shade50 
                    : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _connectionTestResult!.startsWith('✅') 
                      ? Colors.green.shade200 
                      : Colors.red.shade200,
                  ),
                ),
                child: Text(
                  _connectionTestResult!,
                  style: TextStyle(
                    color: _connectionTestResult!.startsWith('✅') 
                      ? Colors.green.shade800 
                      : Colors.red.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTestingConnection ? null : _testConnection,
                icon: _isTestingConnection 
                  ? const SizedBox(
                      width: 16, 
                      height: 16, 
                      child: CircularProgressIndicator(strokeWidth: 2)
                    )
                  : const Icon(Icons.play_arrow),
                label: Text(_isTestingConnection ? '테스트 중...' : 'API 연결 테스트'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// API 설정 카드
  Widget _buildApiSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.key, color: Colors.orange),
                SizedBox(width: 8),
                Text('API 설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Roboflow API 키',
                hintText: 'your-private-api-key',
                prefixIcon: Icon(Icons.vpn_key),
                border: OutlineInputBorder(),
                helperText: 'Roboflow 대시보드에서 Private API Key를 복사해주세요',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'API 키를 입력해주세요';
                }
                if (value.trim().length < 10) {
                  return 'API 키가 너무 짧습니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _workspaceController,
                    decoration: const InputDecoration(
                      labelText: '워크스페이스 ID',
                      hintText: 'jeonbuk-reports',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '워크스페이스 ID를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _projectController,
                    decoration: const InputDecoration(
                      labelText: '프로젝트 ID',
                      hintText: 'integrated-detection',
                      prefixIcon: Icon(Icons.folder),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '프로젝트 ID를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 프로젝트 이름 가이드 및 빠른 설정
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '프로젝트 이름 가이드',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• 실제 Roboflow 대시보드의 프로젝트 이름과 정확히 일치해야 합니다\n'
                    '• 일반적인 프로젝트 이름 예시: field-reports, damage-detection, infrastructure-monitoring\n'
                    '• 테스트용으로는 공개 데이터셋 "coco"를 사용할 수 있습니다',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildQuickSetupButton('현장 보고서', 'field-reports', 'jeonbuk-reports'),
                      _buildQuickSetupButton('손상 감지', 'damage-detection', 'infrastructure'),
                      _buildQuickSetupButton('COCO 테스트', 'coco', 'roboflow-100'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 모델 설정 카드
  Widget _buildModelSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.tune, color: Colors.purple),
                SizedBox(width: 8),
                Text('모델 설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _versionController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: '모델 버전',
                      hintText: '1',
                      prefixIcon: Icon(Icons.history),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '버전을 입력해주세요';
                      }
                      final version = int.tryParse(value);
                      if (version == null || version < 1) {
                        return '유효한 버전 번호를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _confidenceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: '신뢰도 임계값 (%)',
                      hintText: '50',
                      prefixIcon: Icon(Icons.track_changes),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '신뢰도를 입력해주세요';
                      }
                      final confidence = int.tryParse(value);
                      if (confidence == null || confidence < 0 || confidence > 100) {
                        return '0-100 사이의 값을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _overlapController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: '겹침 임계값 (%)',
                      hintText: '30',
                      prefixIcon: Icon(Icons.call_merge),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '겹침 임계값을 입력해주세요';
                      }
                      final overlap = int.tryParse(value);
                      if (overlap == null || overlap < 0 || overlap > 100) {
                        return '0-100 사이의 값을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 백엔드 설정 카드
  Widget _buildBackendSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.cloud, color: Colors.green),
                SizedBox(width: 8),
                Text('백엔드 설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('백엔드 서버 사용'),
              subtitle: const Text('서버를 통해 AI 분석을 수행합니다'),
              value: _useBackend,
              onChanged: (value) {
                setState(() => _useBackend = value);
              },
            ),
            if (_useBackend) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _backendUrlController,
                decoration: const InputDecoration(
                  labelText: '백엔드 서버 URL',
                  hintText: 'http://localhost:8080',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                  helperText: 'Spring Boot 백엔드 서버의 기본 URL',
                ),
                validator: _useBackend ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '백엔드 URL을 입력해주세요';
                  }
                  if (!value.startsWith('http')) {
                    return 'http:// 또는 https://로 시작해야 합니다';
                  }
                  return null;
                } : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 액션 버튼들
  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveSettings,
            icon: const Icon(Icons.save),
            label: const Text('설정 저장'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _resetSettings,
          icon: const Icon(Icons.restore, color: Colors.red),
          label: const Text('설정 초기화', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  /// 빠른 설정 버튼
  Widget _buildQuickSetupButton(String label, String project, String workspace) {
    return ElevatedButton(
      onPressed: () => _setQuickPreset(project, workspace),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade100,
        foregroundColor: Colors.blue.shade800,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: Text(label),
    );
  }

  /// 빠른 프리셋 설정
  void _setQuickPreset(String project, String workspace) {
    setState(() {
      _projectController.text = project;
      _workspaceController.text = workspace;
    });
    
    // 사용자에게 피드백 제공
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚀 "$project" 프리셋이 적용되었습니다'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// API 키 유효성 실시간 확인
  Future<void> _validateApiKeyRealTime() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isNotEmpty && apiKey.length > 10) {
      // 실시간으로 API 키 형식 검증
      final isValid = await RoboflowService.instance.validateApiKeyFormat(apiKey);
      if (!isValid) {
        _showWarning('⚠️ API 키 형식이 올바르지 않을 수 있습니다');
      }
    }
  }

  /// 설정 가이드 다이얼로그
  void _showSetupGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Roboflow 설정 가이드'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Roboflow 대시보드 접속',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• app.roboflow.com에 로그인\n• 프로젝트를 선택하거나 새로 생성'),
              SizedBox(height: 12),
              Text(
                '2. API 키 확인',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Settings > API Keys 메뉴\n• Private API Key 복사'),
              SizedBox(height: 12),
              Text(
                '3. 프로젝트 정보 확인',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• 프로젝트 URL에서 workspace와 project 이름 확인\n• 예: app.roboflow.com/workspace-name/project-name'),
              SizedBox(height: 12),
              Text(
                '4. 테스트 방법',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• 설정 저장 후 "연결 테스트" 버튼 클릭\n• 실제 이미지로 분석 테스트'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 에러 메시지 표시
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 성공 메시지 표시
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 경고 메시지 표시
  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 확인 다이얼로그
  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('확인'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
