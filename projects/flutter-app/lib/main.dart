import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/config/app_config.dart';
import 'core/config/env_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_initializer.dart';

// 공통 앱 실행 함수
Future<void> mainCommon(Environment env) async {
  // Flutter 바인딩 초기화 (필수)
  WidgetsFlutterBinding.ensureInitialized();
  
  // 환경 변수 초기화 (env-manager에서 불러오기)
  await EnvConfig.initialize(env);
  
  // 앱 초기화
  await AppInitializer.initialize();
  
  runApp(
    const ProviderScope(
      child: JBReportApp(),
    ),
  );
}

// 기본 진입점 - 프로덕션 환경으로 실행
void main() async {
  await mainCommon(Environment.production);
}

class JBReportApp extends ConsumerWidget {
  const JBReportApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'JB Report Platform',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}