// routes/_middleware.dart

import 'package:dart_frog/dart_frog.dart';
import 'package:flutter_backend/src/report_repository.dart';

final _reportRepository = ReportRepository();

Handler middleware(Handler handler) {
  return (context) async {
    // Handle the request.
    final response = await handler(context);

    // Add CORS headers to the response.
    return response.copyWith(
      headers: {
        ...response.headers,
        'Access-Control-Allow-Origin': '*', // or your specific Firebase domain
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
      },
    );
  }.use(provider<ReportRepository>((_) => _reportRepository));
}