import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/reports/presentation/pages/report_list_page.dart';
import '../../features/reports/presentation/pages/report_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../shared/widgets/main_navigation.dart';

// Lazy import for ReportCreatePage to avoid circular dependency
class _LazyReportCreatePage {
  static Widget create() {
    // TODO: 실제 ReportCreatePage로 교체 필요
    return Scaffold(
      appBar: AppBar(title: const Text('신고서 작성')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'ReportCreatePage 구현 중...',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              '실제 페이지는 별도로 구현되어 있습니다.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String reportList = '/reports';
  static const String reportCreate = '/reports/create';
  static const String reportDetail = '/reports/detail';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavigation());
      case reportList:
        return MaterialPageRoute(builder: (_) => const ReportListPage());
      case reportCreate:
        return MaterialPageRoute(
          builder: (_) => _LazyReportCreatePage.create(),
        );
      case reportDetail:
        final reportId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ReportDetailPage(reportId: reportId),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
