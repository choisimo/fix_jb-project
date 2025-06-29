import 'package:flutter/material.dart';
import '../../features/reports/presentation/pages/report_list_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../app/routes/app_routes.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _shouldRefreshReports = false;

  final List<Widget> _pages = [const ReportListPage(), const ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // 보고서 목록 페이지를 새로고침이 필요할 때 재빌드
          _shouldRefreshReports
              ? ReportListPage(
                  key: ValueKey(DateTime.now().millisecondsSinceEpoch),
                )
              : _pages[0],
          _pages[1],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).pushNamed(AppRoutes.reportCreate);

          // 신고서 제출이 성공했다면 목록 새로고침
          if (result == true) {
            setState(() {
              _shouldRefreshReports = true;
              _currentIndex = 0; // 보고서 탭으로 이동
            });

            // 새로고침 플래그 리셋
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                setState(() {
                  _shouldRefreshReports = false;
                });
              }
            });

            // 성공 메시지 표시
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('새로운 신고서가 목록에 추가되었습니다!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        },
        heroTag: "report_create",
        tooltip: '신고서 작성',
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: '보고서'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
      ),
    );
  }
}
