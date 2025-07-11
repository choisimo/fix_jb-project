import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/reports/presentation/pages/report_list_page.dart';
import '../../features/reports/presentation/pages/report_detail_page.dart';
import '../../features/reports/presentation/pages/report_create_page_final.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../shared/widgets/authenticated_main_navigation.dart';
import '../../widgets/location_test_widget.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String reportList = '/reports';
  static const String reportCreate = '/reports/create';
  static const String reportDetail = '/reports/detail';
  static const String profile = '/profile';
  static const String locationTest = '/location-test'; // 개발자 도구

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const AuthenticatedMainNavigation());
      case reportList:
        return MaterialPageRoute(builder: (_) => const ReportListPage());
      case reportCreate:
        return MaterialPageRoute(builder: (_) => const ReportCreatePageFinal());
      case reportDetail:
        final reportId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ReportDetailPage(reportId: reportId),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case locationTest:
        return MaterialPageRoute(builder: (_) => const LocationTestWidget());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '페이지를 찾을 수 없습니다',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '요청한 경로: ${settings.name}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
