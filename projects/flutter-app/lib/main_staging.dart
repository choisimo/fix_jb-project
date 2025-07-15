import 'package:flutter/material.dart';
import 'core/config/env_config.dart';
import 'main.dart';

Future<void> main() async {
  // 스테이징 환경으로 앱 실행
  await mainCommon(Environment.staging);
}
