// routes/reports/[id].dart

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:flutter_backend/src/report_repository.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final reportRepo = context.read<ReportRepository>();

  switch (context.request.method) {
    case HttpMethod.get:
      final report = await reportRepo.getReportById(id);
      if (report == null) {
        return Response(statusCode: HttpStatus.notFound, body: 'Report not found');
      }
      return Response.json(body: report.toJson());
    case HttpMethod.delete:
      await reportRepo.deleteReport(id);
      return Response(statusCode: HttpStatus.noContent);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}