// routes/auth/me.dart

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

// This should be the same secret as in the login route.
const _jwtSecret = 'your-super-secret-key';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final authHeader = context.request.headers['Authorization'];
  if (authHeader == null || !authHeader.startsWith('Bearer ')) {
    return Response(
        statusCode: HttpStatus.unauthorized, body: 'Missing or invalid token');
  }

  final token = authHeader.substring(7);

  try {
    // Verify the token
    final jwt = JWT.verify(token, SecretKey(_jwtSecret));
    final payload = jwt.payload as Map<String, dynamic>;

    // In a real app, you might want to re-fetch user from DB
    // to ensure they still exist and have the right permissions.
    return Response.json(
      body: {
        'id': payload['id'],
        'email': payload['email'],
        'name': '임시 사용자', // You can add more user info to the JWT payload
        'department': '개발팀',
      },
    );
  } on JWTExpiredException {
    return Response(statusCode: HttpStatus.unauthorized, body: 'Token expired');
  } on JWTException catch (err) {
    return Response(
        statusCode: HttpStatus.unauthorized,
        body: 'Invalid token: ${err.message}');
  }
}
