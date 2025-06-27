import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(body: 'Welcome to Dart Frog!');
}

Future<Response> onError(RequestContext context, Object error) async {
  // Log the error (you can use a logging package here)
  print('Error occurred: $error');

  // Return a generic error response
  return Response(
    statusCode: 500,
    body: 'Internal Server Error',
  );
}

Future<Response> onTimeout(RequestContext context) async {
  // Log the timeout
  print('Request timed out');

  // Return a timeout response
  return Response(
    statusCode: 408,
    body: 'Request Timeout',
  );
}

Future<Response> onNotFound(RequestContext context) async {
  // Log the not found error
  print('Route not found: ${context.request.url}');

  // Return a 404 response
  return Response(
    statusCode: 404,
    body: 'Not Found',
  );
}

Future<Response> onMethodNotAllowed(RequestContext context) async {
  // Log the method not allowed error
  print(
      'Method not allowed: ${context.request.method} for ${context.request.url}');

  // Return a 405 response
  return Response(
    statusCode: 405,
    body: 'Method Not Allowed',
  );
}

Future<Response> onUnsupportedMediaType(RequestContext context) async {
  // Log the unsupported media type error
  print('Unsupported media type for ${context.request.url}');

  // Return a 415 response
  return Response(
    statusCode: 415,
    body: 'Unsupported Media Type',
  );
}
