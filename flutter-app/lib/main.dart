import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app/config/app_config.dart';
import 'app/theme/app_theme.dart';
import 'app/routes/app_routes.dart';
import 'core/auth/auth_service.dart';
import 'core/network/api_client.dart';
import 'core/storage/storage_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/reports/presentation/providers/report_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 서비스 초기화
  await _initializeServices();
  
  runApp(const MyApp());
}

Future<void> _initializeServices() async {
  await StorageService.instance.init();
  await AuthService.instance.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Report App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko', 'KR'),
          Locale('en', 'US'),
        ],
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
