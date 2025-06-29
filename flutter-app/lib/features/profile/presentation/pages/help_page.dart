import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('도움말'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection('앱 사용법', [
            _buildFAQItem(
              '신고서는 어떻게 작성하나요?',
              '하단의 파란색 + 버튼을 눌러서 신고서 작성 페이지로 이동할 수 있습니다.\n'
                  '1. 이미지를 추가하세요\n'
                  '2. AI 분석을 실행하세요\n'
                  '3. 제목, 카테고리, 내용을 입력하세요\n'
                  '4. 현재 위치를 확인하세요\n'
                  '5. 제출 버튼을 눌러 완료하세요',
            ),
            _buildFAQItem(
              'AI 분석은 어떻게 사용하나요?',
              '이미지를 추가한 후 "AI 분석 시작" 버튼을 누르면 자동으로 이미지를 분석하여 '
                  '발견된 문제점을 식별하고 폼에 자동으로 내용을 채워줍니다.',
            ),
            _buildFAQItem(
              '내 보고서 상태는 어떻게 확인하나요?',
              '프로필 > 내 보고서에서 제출한 모든 보고서의 상태를 확인할 수 있습니다.\n'
                  '상태: 대기 → 처리중 → 완료',
            ),
          ]),
          _buildSection('문제 해결', [
            _buildFAQItem(
              '위치 정보를 가져올 수 없어요',
              '1. 설정 > 앱 권한에서 위치 권한을 허용해주세요\n'
                  '2. GPS가 켜져 있는지 확인해주세요\n'
                  '3. 실내에서는 위치 정확도가 떨어질 수 있습니다',
            ),
            _buildFAQItem(
              '이미지를 추가할 수 없어요',
              '1. 설정 > 앱 권한에서 카메라 및 저장소 권한을 허용해주세요\n'
                  '2. 저장공간이 부족하지 않은지 확인해주세요\n'
                  '3. 앱을 다시 시작해보세요',
            ),
            _buildFAQItem(
              '알림이 오지 않아요',
              '1. 설정 > 알림에서 앱 알림이 허용되어 있는지 확인해주세요\n'
                  '2. 프로필 > 알림 설정에서 원하는 알림이 활성화되어 있는지 확인하세요\n'
                  '3. 배터리 최적화에서 앱을 제외시켜주세요',
            ),
          ]),
          _buildSection('기능 안내', [
            _buildFAQItem(
              '신고할 수 있는 항목이 무엇인가요?',
              '• 안전: 위험 요소, 손상된 시설물 등\n'
                  '• 품질: 쓰레기, 환경 오염 등\n'
                  '• 진행상황: 공사 현장, 작업 상태 등\n'
                  '• 유지보수: 시설물 점검, 수리 필요 등\n'
                  '• 기타: 위 항목에 해당하지 않는 사항',
            ),
            _buildFAQItem(
              'AI 분석의 정확도는 어느 정도인가요?',
              'AI 분석은 참고용으로 제공되며, 실제 상황과 다를 수 있습니다.\n'
                  '분석 결과를 확인하고 필요시 수정하여 사용하세요.',
            ),
          ]),
          _buildSection('연락처', [
            _buildContactItem(
              Icons.phone,
              '고객센터',
              '063-123-4567',
              '평일 09:00 - 18:00',
            ),
            _buildContactItem(
              Icons.email,
              '이메일 문의',
              'support@jeonbuk-report.kr',
              '24시간 접수 가능',
            ),
            _buildContactItem(
              Icons.location_on,
              '방문 상담',
              '전북 전주시 덕진구 백제대로 567',
              '평일 09:00 - 17:00 (점심시간 12:00-13:00)',
            ),
          ]),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                const Icon(Icons.help_center, size: 48, color: Colors.blue),
                const SizedBox(height: 8),
                const Text(
                  '더 자세한 도움이 필요하세요?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '언제든 고객센터로 연락주세요',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _showContactDialog(context),
                  icon: const Icon(Icons.contact_support),
                  label: const Text('문의하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
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
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        Card(child: Column(children: children)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String title,
    String content,
    String subtitle,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      onTap: () {
        // 실제로는 전화, 이메일, 지도 등의 기능 구현
      },
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('문의 방법 선택'),
        content: const Text('어떤 방법으로 문의하시겠습니까?'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // 전화 걸기 기능
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('전화 앱으로 연결됩니다 (시뮬레이션)')),
              );
            },
            icon: const Icon(Icons.phone),
            label: const Text('전화'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // 이메일 앱 열기
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('이메일 앱으로 연결됩니다 (시뮬레이션)')),
              );
            },
            icon: const Icon(Icons.email),
            label: const Text('이메일'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }
}
