// routes/_middleware.dart

import 'package:dart_frog/dart_frog.dart';
import 'package:flutter_backend/src/report_repository.dart';

final _reportRepository = ReportRepository();

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(
        provider<ReportRepository>((_) => _reportRepository),
      )
      .use(
        (handler) => (context) async {
          final response = await handler(context);
          return response.copyWith(
            headers: {
              ...response.headers,
              'Access-Control-Allow-Origin': '*', // or your specific Firebase domain
              'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
              'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
            },
          );
        },
      );
}