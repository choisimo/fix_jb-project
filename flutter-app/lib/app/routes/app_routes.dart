import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/reports/presentation/pages/report_list_page.dart';
import '../../features/reports/presentation/pages/report_create_page.dart';
import '../../features/reports/presentation/pages/report_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../shared/widgets/main_navigation.dart';

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
        return MaterialPageRoute(builder: (_) => const ReportCreatePage());
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
