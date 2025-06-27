import 'package:flutter/material.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../app/routes/app_routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 설정 페이지로 이동
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final authService = AuthService.instance;
          final userInfo = authService.userInfo;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.person, size: 50),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userInfo?['name'] ?? '사용자',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userInfo?['email'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userInfo?['department'] ?? '부서 정보 없음',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.assignment),
                        title: const Text('내 보고서'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // 내 보고서 목록으로 이동
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text('알림 설정'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // 알림 설정으로 이동
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.help),
                        title: const Text('도움말'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // 도움말으로 이동
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.info),
                        title: const Text('앱 정보'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // 앱 정보로 이동
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      '로그아웃',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('로그아웃'),
                          content: const Text('정말 로그아웃하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('로그아웃'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await authService.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.login,
                            (route) => false,
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
