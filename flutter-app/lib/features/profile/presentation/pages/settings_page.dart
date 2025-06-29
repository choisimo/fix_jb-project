import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/theme_manager.dart';
import 'notification_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoLocation = true;
  bool _saveImageToGallery = false;
  bool _highQualityImages = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoLocation = prefs.getBool('auto_location') ?? true;
      _saveImageToGallery = prefs.getBool('save_image_to_gallery') ?? false;
      _highQualityImages = prefs.getBool('high_quality_images') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_location', _autoLocation);
    await prefs.setBool('save_image_to_gallery', _saveImageToGallery);
    await prefs.setBool('high_quality_images', _highQualityImages);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('설정이 저장되었습니다'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveSettings),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection('화면 설정', [
            AnimatedBuilder(
              animation: ThemeManager.instance,
              builder: (context, child) {
                return SwitchListTile(
                  title: const Text('다크 모드'),
                  subtitle: const Text('어두운 테마를 사용합니다'),
                  value: ThemeManager.instance.isDarkMode,
                  onChanged: (value) {
                    ThemeManager.instance.toggleDarkMode(value);
                  },
                );
              },
            ),
            const Divider(height: 1),
            AnimatedBuilder(
              animation: ThemeManager.instance,
              builder: (context, child) {
                return ListTile(
                  title: const Text('언어'),
                  subtitle: Text(ThemeManager.instance.language),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showLanguageDialog(),
                );
              },
            ),
            const Divider(height: 1),
            AnimatedBuilder(
              animation: ThemeManager.instance,
              builder: (context, child) {
                return ListTile(
                  title: const Text('글꼴 크기'),
                  subtitle: Text('${ThemeManager.instance.fontSize.toInt()}px'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showFontSizeDialog(),
                );
              },
            ),
          ]),

          _buildSection('위치 설정', [
            SwitchListTile(
              title: const Text('자동 위치 가져오기'),
              subtitle: const Text('신고서 작성 시 자동으로 현재 위치를 가져옵니다'),
              value: _autoLocation,
              onChanged: (value) {
                setState(() {
                  _autoLocation = value;
                });
              },
            ),
          ]),

          _buildSection('카메라 및 이미지', [
            SwitchListTile(
              title: const Text('갤러리에 이미지 저장'),
              subtitle: const Text('촬영한 이미지를 갤러리에도 저장합니다'),
              value: _saveImageToGallery,
              onChanged: (value) {
                setState(() {
                  _saveImageToGallery = value;
                });
              },
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('고화질 이미지'),
              subtitle: const Text('더 좋은 품질의 이미지를 사용합니다 (용량 증가)'),
              value: _highQualityImages,
              onChanged: (value) {
                setState(() {
                  _highQualityImages = value;
                });
              },
            ),
          ]),

          _buildSection('알림', [
            ListTile(
              title: const Text('알림 설정'),
              subtitle: const Text('푸시 알림 및 알림 유형 설정'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsPage(),
                  ),
                );
              },
            ),
          ]),

          _buildSection('데이터 및 저장소', [
            ListTile(
              title: const Text('캐시 정리'),
              subtitle: const Text('임시 파일 및 캐시를 정리합니다'),
              trailing: const Icon(Icons.cleaning_services),
              onTap: () => _clearCache(),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('저장소 사용량'),
              subtitle: const Text('앱이 사용하는 저장공간을 확인합니다'),
              trailing: const Icon(Icons.storage),
              onTap: () => _showStorageInfo(),
            ),
          ]),

          _buildSection('보안', [
            ListTile(
              title: const Text('앱 잠금'),
              subtitle: const Text('앱 실행 시 생체 인증 또는 PIN 입력'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('앱 잠금 기능은 준비 중입니다'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
              ),
            ),
          ]),

          _buildSection('기타', [
            ListTile(
              title: const Text('개발자 모드'),
              subtitle: const Text('개발자용 고급 기능 (일반 사용자는 사용하지 마세요)'),
              trailing: const Icon(Icons.developer_mode),
              onTap: () => _showDeveloperOptions(),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('설정 초기화'),
              subtitle: const Text('모든 설정을 기본값으로 되돌립니다'),
              trailing: const Icon(Icons.restore, color: Colors.red),
              onTap: () => _resetSettings(),
            ),
          ]),

          _buildSection('테스트', [
            ListTile(
              title: const Text('설정 테스트'),
              subtitle: const Text('현재 설정값들을 확인하고 테스트합니다'),
              trailing: const Icon(Icons.quiz),
              onTap: () => _testCurrentSettings(),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('다크모드 즉시 테스트'),
              subtitle: const Text('다크모드 전환을 즉시 테스트해봅니다'),
              trailing: const Icon(Icons.brightness_6),
              onTap: () => _testDarkModeToggle(),
            ),
          ]),

          const SizedBox(height: 32),
          Text(
            '설정을 변경한 후 저장 버튼을 눌러 적용하세요.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        Card(child: Column(children: children)),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showLanguageDialog() {
    final languages = ['한국어', 'English'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('언어 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages
              .map(
                (lang) => RadioListTile<String>(
                  title: Text(lang),
                  value: lang,
                  groupValue: ThemeManager.instance.language,
                  onChanged: (value) {
                    ThemeManager.instance.setLanguage(value!);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('글꼴 크기'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('현재 크기: ${ThemeManager.instance.fontSize.toInt()}px'),
                Slider(
                  value: ThemeManager.instance.fontSize,
                  min: 12.0,
                  max: 24.0,
                  divisions: 6,
                  label: '${ThemeManager.instance.fontSize.toInt()}px',
                  onChanged: (value) {
                    ThemeManager.instance.setFontSize(value);
                    setDialogState(() {}); // 다이얼로그 내부 상태 업데이트
                  },
                ),
                const Text('미리보기'),
                Text(
                  '이것은 샘플 텍스트입니다.',
                  style: TextStyle(fontSize: ThemeManager.instance.fontSize),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('캐시 정리'),
        content: const Text('임시 파일과 캐시를 정리하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('캐시가 정리되었습니다 (시뮬레이션)'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('정리'),
          ),
        ],
      ),
    );
  }

  void _showStorageInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('저장소 사용량'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('앱 크기: 25.3 MB'),
            Text('사용자 데이터: 12.8 MB'),
            Text('캐시: 8.5 MB'),
            Text('이미지: 15.2 MB'),
            Divider(),
            Text(
              '총 사용량: 61.8 MB',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showDeveloperOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개발자 모드'),
        content: const Text('개발자용 기능입니다.\n일반 사용자는 사용하지 마세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('개발자 모드가 활성화되었습니다'),
                  backgroundColor: Colors.amber,
                ),
              );
            },
            child: const Text('활성화'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('설정 초기화'),
        content: const Text('모든 설정이 기본값으로 되돌아갑니다.\n계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // 설정 초기화
              setState(() {
                _autoLocation = true;
                _saveImageToGallery = false;
                _highQualityImages = true;
              });

              // ThemeManager 설정 초기화
              await ThemeManager.instance.saveAllSettings(
                darkMode: false,
                fontSize: 16.0,
                language: '한국어',
              );

              await _saveSettings();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('설정이 초기화되었습니다'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }

  /// 현재 설정값들을 테스트하는 기능
  void _testCurrentSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('현재 설정 상태'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '다크모드: ${ThemeManager.instance.isDarkMode ? "활성화" : "비활성화"}',
              ),
              Text('폰트 크기: ${ThemeManager.instance.fontSize.toInt()}px'),
              Text('언어: ${ThemeManager.instance.language}'),
              const SizedBox(height: 12),
              Text('자동 위치: ${_autoLocation ? "활성화" : "비활성화"}'),
              Text('갤러리 저장: ${_saveImageToGallery ? "활성화" : "비활성화"}'),
              Text('고화질 이미지: ${_highQualityImages ? "활성화" : "비활성화"}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 다크모드 토글 테스트
  void _testDarkModeToggle() {
    final currentMode = ThemeManager.instance.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('다크모드 테스트'),
        content: Text(
          '현재 다크모드가 ${currentMode ? "활성화" : "비활성화"}되어 있습니다.\n'
          '${currentMode ? "라이트" : "다크"}모드로 전환하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ThemeManager.instance.toggleDarkMode(!currentMode);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${!currentMode ? "다크" : "라이트"}모드로 전환되었습니다'),
                  backgroundColor: Colors.green,
                  action: SnackBarAction(
                    label: '되돌리기',
                    onPressed: () {
                      ThemeManager.instance.toggleDarkMode(currentMode);
                    },
                  ),
                ),
              );
            },
            child: const Text('전환'),
          ),
        ],
      ),
    );
  }
}
