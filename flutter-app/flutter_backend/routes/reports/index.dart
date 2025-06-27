
// routes/reports/index.dart

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:flutter_backend/src/report_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final reportRepo = context.read<ReportRepository>();

  switch (context.request.method) {
    case HttpMethod.get:
      final reports = await reportRepo.getAllReports();
      return Response.json(body: reports.map((r) => r.toJson()).toList());
    case HttpMethod.post:
      final body = await context.request.json() as Map<String, dynamic>;
      final newReport = await reportRepo.createReport(
        title: body['title'] as String,
        content: body['content'] as String,
        authorName: '임시 작성자', // TODO: Get user from auth token
      );
      return Response.json(statusCode: HttpStatus.created, body: newReport.toJson());
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}
