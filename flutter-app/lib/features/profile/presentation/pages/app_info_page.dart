import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('앱 정보'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 앱 로고 및 기본 정보
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.assignment_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '전북 신고 앱',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Jeonbuk Report App',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '버전 1.0.0',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 앱 설명
          _buildSection('앱 소개', [
            const ListTile(
              title: Text(
                '전북 지역의 안전, 환경, 시설물 관련 문제를 신속하게 신고하고 '
                '처리 현황을 확인할 수 있는 스마트 신고 시스템입니다.',
                style: TextStyle(height: 1.5),
              ),
            ),
          ]),

          // 주요 기능
          _buildSection('주요 기능', [
            _buildFeatureItem(
              Icons.camera_alt,
              '이미지 기반 신고',
              '사진을 찍어서 쉽고 빠르게 신고할 수 있습니다',
            ),
            _buildFeatureItem(
              Icons.psychology,
              'AI 자동 분석',
              '인공지능이 이미지를 분석하여 문제점을 자동으로 식별합니다',
            ),
            _buildFeatureItem(
              Icons.location_on,
              '위치 기반 서비스',
              'GPS를 활용한 정확한 위치 정보 제공',
            ),
            _buildFeatureItem(
              Icons.track_changes,
              '실시간 처리 현황',
              '신고한 내용의 처리 상태를 실시간으로 확인할 수 있습니다',
            ),
          ]),

          // 앱 정보
          _buildSection('앱 정보', [
            _buildInfoItem('개발자', '전북특별자치도'),
            _buildInfoItem('버전', '1.0.0 (Build 1)'),
            _buildInfoItem('최신 업데이트', '2024년 6월 29일'),
            _buildInfoItem('지원 OS', 'Android 7.0+, iOS 12.0+'),
            _buildInfoItem('언어', '한국어'),
            _buildInfoItem('카테고리', '유틸리티'),
          ]),

          // 개발팀 정보
          _buildSection('개발팀', [
            _buildInfoItem('기획', '전북특별자치도 디지털혁신과'),
            _buildInfoItem('개발', 'Flutter Development Team'),
            _buildInfoItem('디자인', 'UI/UX Design Team'),
            _buildInfoItem('AI 개발', 'AI Research Team'),
          ]),

          // 법적 정보
          _buildSection('법적 정보', [
            ListTile(
              title: const Text('개인정보 처리방침'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showPrivacyPolicy(context),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('서비스 이용약관'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showTermsOfService(context),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('오픈소스 라이선스'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showOpenSourceLicenses(context),
            ),
          ]),

          // 기타
          _buildSection('기타', [
            ListTile(
              title: const Text('앱 스토어에서 평가하기'),
              trailing: const Icon(Icons.star),
              onTap: () => _showRatingDialog(context),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('앱 정보 공유'),
              trailing: const Icon(Icons.share),
              onTap: () => _shareAppInfo(context),
            ),
          ]),

          const SizedBox(height: 32),

          // 저작권 정보
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '© 2024 전북특별자치도',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'All rights reserved.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
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
        Card(
          child: Column(
            children: children.map((child) {
              final index = children.indexOf(child);
              return Column(
                children: [
                  child,
                  if (index < children.length - 1) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개인정보 처리방침'),
        content: const SingleChildScrollView(
          child: Text(
            '전북 신고 앱 개인정보 처리방침\n\n'
            '1. 개인정보의 처리목적\n'
            '본 앱은 신고 접수 및 처리를 위해 최소한의 개인정보를 처리합니다.\n\n'
            '2. 처리하는 개인정보 항목\n'
            '- 필수항목: 이름, 연락처\n'
            '- 선택항목: 이메일, 소속\n\n'
            '3. 개인정보의 처리 및 보유기간\n'
            '신고 처리 완료 후 3년간 보관됩니다.\n\n'
            '4. 개인정보의 제3자 제공\n'
            '법령에 의한 경우를 제외하고는 제3자에게 제공하지 않습니다.\n\n'
            '자세한 내용은 홈페이지를 참고하세요.',
            style: TextStyle(height: 1.5),
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

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('서비스 이용약관'),
        content: const SingleChildScrollView(
          child: Text(
            '전북 신고 앱 서비스 이용약관\n\n'
            '제1조 (목적)\n'
            '본 약관은 전북특별자치도에서 제공하는 신고 서비스 이용에 관한 조건과 절차를 규정함을 목적으로 합니다.\n\n'
            '제2조 (서비스 내용)\n'
            '1. 안전, 환경, 시설물 관련 신고 접수\n'
            '2. 신고 처리 현황 제공\n'
            '3. 관련 정보 및 알림 서비스\n\n'
            '제3조 (이용자의 의무)\n'
            '1. 허위 신고 금지\n'
            '2. 개인정보 보호\n'
            '3. 서비스 부정 이용 금지\n\n'
            '자세한 내용은 홈페이지를 참고하세요.',
            style: TextStyle(height: 1.5),
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

  void _showOpenSourceLicenses(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오픈소스 라이선스'),
        content: const SingleChildScrollView(
          child: Text(
            '본 앱에서 사용된 오픈소스 라이브러리:\n\n'
            '• Flutter (BSD 3-Clause License)\n'
            '• Geolocator (MIT License)\n'
            '• Image Picker (Apache License 2.0)\n'
            '• Permission Handler (MIT License)\n'
            '• Shared Preferences (BSD 3-Clause License)\n'
            '• HTTP (BSD 3-Clause License)\n'
            '• UUID (MIT License)\n'
            '• Intl (BSD 3-Clause License)\n\n'
            '각 라이브러리의 자세한 라이선스 정보는 해당 패키지 문서를 참고하세요.',
            style: TextStyle(height: 1.5),
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

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 평가'),
        content: const Text('앱 스토어에서 별점과 리뷰를 남겨주시면 앱 개선에 큰 도움이 됩니다!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('나중에'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('앱 스토어로 이동합니다 (시뮬레이션)'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('평가하기'),
          ),
        ],
      ),
    );
  }

  void _shareAppInfo(BuildContext context) {
    const appInfo =
        '전북 신고 앱 - 스마트 신고 시스템\n'
        '안전하고 편리한 신고 서비스를 이용해보세요!\n'
        '다운로드: Play Store / App Store';

    Clipboard.setData(const ClipboardData(text: appInfo));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('앱 정보가 클립보드에 복사되었습니다'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
