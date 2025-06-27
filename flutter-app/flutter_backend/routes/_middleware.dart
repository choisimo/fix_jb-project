// routes/_middleware.dart

import 'package:dart_frog/dart_frog.dart';
import 'package:flutter_backend/src/report_repository.dart';

final _reportRepository = ReportRepository();

Handler middleware(Handler handler) {
<<<<<<< HEAD
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
=======
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
>>>>>>> 3b3204f097a5895627b3fc0bdfcd1b20e5546d51
}