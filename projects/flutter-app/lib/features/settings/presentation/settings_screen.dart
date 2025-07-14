import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotificationsEnabled = true;
  bool _reportNotificationsEnabled = true;
  bool _commentNotificationsEnabled = true;
  bool _locationServicesEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoAnalysisEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // 알림 설정
          _buildSectionHeader('알림 설정'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: Column(
              children: [
                _buildSwitchTile(
                  '푸시 알림',
                  '앱 푸시 알림을 받습니다',
                  _pushNotificationsEnabled,
                  (value) => setState(() => _pushNotificationsEnabled = value),
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  '신고 관련 알림',
                  '내 신고에 대한 업데이트를 받습니다',
                  _reportNotificationsEnabled,
                  (value) => setState(() => _reportNotificationsEnabled = value),
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  '댓글 알림',
                  '내 신고에 댓글이 달렸을 때 알림을 받습니다',
                  _commentNotificationsEnabled,
                  (value) => setState(() => _commentNotificationsEnabled = value),
                ),
              ],
            ),
          ),

          // 개인정보 및 위치
          _buildSectionHeader('개인정보 및 위치'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: Column(
              children: [
                _buildSwitchTile(
                  '위치 서비스',
                  '현재 위치를 자동으로 감지합니다',
                  _locationServicesEnabled,
                  (value) => setState(() => _locationServicesEnabled = value),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('위치 정확도'),
                  subtitle: const Text('높음 (GPS 사용)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showLocationAccuracyDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('개인정보 설정'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showPrivacyDialog(),
                ),
              ],
            ),
          ),

          // AI 및 자동화
          _buildSectionHeader('AI 및 자동화'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: Column(
              children: [
                _buildSwitchTile(
                  '자동 분석',
                  '이미지 촬영 시 자동으로 분석을 수행합니다',
                  _autoAnalysisEnabled,
                  (value) => setState(() => _autoAnalysisEnabled = value),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.smart_toy),
                  title: const Text('AI 모델 설정'),
                  subtitle: const Text('현재: 통합 모델'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showAIModelDialog(),
                ),
              ],
            ),
          ),

          // 앱 설정
          _buildSectionHeader('앱 설정'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: Column(
              children: [
                _buildSwitchTile(
                  '다크 모드',
                  '어두운 테마를 사용합니다',
                  _darkModeEnabled,
                  (value) => setState(() => _darkModeEnabled = value),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('언어'),
                  subtitle: const Text('한국어'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showLanguageDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: const Text('캐시 지우기'),
                  subtitle: const Text('임시 파일을 삭제합니다'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showClearCacheDialog(),
                ),
              ],
            ),
          ),

          // 정보
          _buildSectionHeader('정보'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('앱 버전'),
                  subtitle: const Text('1.0.0'),
                  onTap: () => _showVersionDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('이용약관'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showTermsDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('개인정보처리방침'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showPrivacyPolicyDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.support),
                  title: const Text('고객지원'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showSupportDialog(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue,
    );
  }

  void _showLocationAccuracyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위치 정확도'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('높음 (GPS)'),
              subtitle: const Text('가장 정확하지만 배터리 소모가 많음'),
              value: 'high',
              groupValue: 'high',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('중간 (네트워크)'),
              subtitle: const Text('적당한 정확도와 배터리 효율'),
              value: 'medium',
              groupValue: 'high',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('낮음 (수동)'),
              subtitle: const Text('수동으로 위치를 입력'),
              value: 'low',
              groupValue: 'high',
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개인정보 설정'),
        content: const Text('개인정보 수집 및 이용에 대한 설정을 관리할 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showAIModelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI 모델 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('통합 모델'),
              subtitle: const Text('모든 종류의 문제를 감지'),
              value: 'integrated',
              groupValue: 'integrated',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('도로 전용'),
              subtitle: const Text('도로 관련 문제만 감지'),
              value: 'road',
              groupValue: 'integrated',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('환경 전용'),
              subtitle: const Text('환경 관련 문제만 감지'),
              value: 'environment',
              groupValue: 'integrated',
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('언어 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('한국어'),
              value: 'ko',
              groupValue: 'ko',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: 'ko',
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('캐시 지우기'),
        content: const Text('임시 파일과 캐시를 모두 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('캐시가 삭제되었습니다.')),
              );
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _showVersionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 정보'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('JB 신고 플랫폼'),
            SizedBox(height: 8),
            Text('버전: 1.0.0'),
            SizedBox(height: 8),
            Text('빌드: 2025.01.01'),
            SizedBox(height: 8),
            Text('개발: JB 플랫폼팀'),
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

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이용약관'),
        content: const SingleChildScrollView(
          child: Text(
            '이용약관 내용이 여기에 표시됩니다...\n\n'
            '1. 서비스 이용\n'
            '2. 개인정보 보호\n'
            '3. 책임의 한계\n'
            '4. 서비스 변경 및 중단\n'
            '5. 기타 사항',
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

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개인정보처리방침'),
        content: const SingleChildScrollView(
          child: Text(
            '개인정보처리방침 내용이 여기에 표시됩니다...\n\n'
            '1. 수집하는 개인정보\n'
            '2. 개인정보의 이용목적\n'
            '3. 개인정보의 보관기간\n'
            '4. 개인정보의 파기\n'
            '5. 이용자의 권리',
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

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('고객지원'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('문의사항이 있으시면 아래로 연락해주세요:'),
            SizedBox(height: 16),
            Text('📧 이메일: support@jbplatform.kr'),
            SizedBox(height: 8),
            Text('📞 전화: 063-123-4567'),
            SizedBox(height: 8),
            Text('🕒 운영시간: 평일 9:00 - 18:00'),
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
}