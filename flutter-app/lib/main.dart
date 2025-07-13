import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jb_report_app/core/router/app_router.dart';
import 'package:jb_report_app/core/theme/app_theme.dart';
import 'package:jb_report_app/core/utils/app_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize app
  await AppInitializer.initialize();
  
  runApp(
    const ProviderScope(
      child: JBReportApp(),
    ),
  );
}

class JBReportApp extends ConsumerWidget {
  const JBReportApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'JB Report',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}