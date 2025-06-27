import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:flutter_backend/src/user_repository.dart';

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

  final existingUser = await userRepo.findUserByEmail(email);
  if (existingUser != null) {
    return Response(statusCode: HttpStatus.conflict, body: 'User already exists');
  }

  await userRepo.createUser(email, password);

  return Response(statusCode: HttpStatus.created);
}