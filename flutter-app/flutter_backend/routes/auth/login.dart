import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_backend/src/user_repository.dart';

// A secret key for signing the JWT. In a real app, load this from a secure
// configuration.
const _jwtSecret = 'your-super-secret-key';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final body = await context.request.json() as Map<String, dynamic>;
  final email = body['email'] as String?;
  final password = body['password'] as String?;

  if (email == null || password == null) {
    return Response(statusCode: HttpStatus.badRequest);
  }

  final userRepo = context.read<UserRepository>();

  final passwordMatches = await userRepo.verifyPassword(email, password);

  if (!passwordMatches) {
    return Response(statusCode: HttpStatus.unauthorized, body: 'Invalid credentials');
  }

  final user = await userRepo.findUserByEmail(email);

  // Create a JWT
  final jwt = JWT(
    {
      'id': user!['id'],
      'email': user['email'],
      'iat': DateTime.now().millisecondsSinceEpoch,
    },
    issuer: 'https://github.com/jonasroussel/dart_jsonwebtoken',
  );

  // Sign it
  final token = jwt.sign(SecretKey(_jwtSecret));

  return Response.json(body: {'token': token});
}