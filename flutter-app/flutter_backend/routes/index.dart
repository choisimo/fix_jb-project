import 'package:dart_frog/dart_frog.dart';
import 'dart:io';

Future<Response> onRequest(RequestContext context) async {
  final file = File('/workspace/flutter-app/fix_jeonbuk/flutter-app/flutter_backend/public/index.html');
  if (await file.exists()) {
    final content = await file.readAsString();
    return Response(
      body: content,
      statusCode: HttpStatus.ok,
      headers: {'Content-Type': 'text/html'},
    );
  }
  return Response(
    statusCode: HttpStatus.notFound,
  );
}
