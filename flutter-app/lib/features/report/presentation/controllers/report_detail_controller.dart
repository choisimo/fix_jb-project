import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/report_repository.dart';
import '../../domain/models/report.dart';
import '../../domain/models/report_models.dart';
import '../../domain/models/report_state.dart';

part 'report_detail_controller.g.dart';

@riverpod
class ReportDetailController extends _$ReportDetailController {
  @override
  ReportDetailState build(String reportId) {
    loadReport();
    loadComments();
    return const ReportDetailState();
  }

  Future<void> loadReport() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(reportRepositoryProvider);
      final report = await repository.getReport(reportId);
      
      state = state.copyWith(
        report: report,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadComments() async {
    state = state.copyWith(isLoadingComments: true, commentError: null);

    try {
      final repository = ref.read(reportRepositoryProvider);
      final comments = await repository.getReportComments(reportId);
      
      state = state.copyWith(
        comments: comments,
        isLoadingComments: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingComments: false,
        commentError: e.toString(),
      );
    }
  }

  Future<void> refreshReport() async {
    await Future.wait([
      loadReport(),
      loadComments(),
    ]);
  }

  Future<void> toggleLike() async {
    if (state.report == null || state.isLiking) return;

    state = state.copyWith(isLiking: true);

    try {
      final repository = ref.read(reportRepositoryProvider);
      final report = state.report!;
      
      if (report.isLiked) {
        await repository.unlikeReport(reportId);
        state = state.copyWith(
          report: report.copyWith(
            isLiked: false,
            likeCount: report.likeCount - 1,
          ),
          isLiking: false,
        );
      } else {
        await repository.likeReport(reportId);
        state = state.copyWith(
          report: report.copyWith(
            isLiked: true,
            likeCount: report.likeCount + 1,
          ),
          isLiking: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLiking: false,
        error: e.toString(),
      );
    }
  }

  Future<void> toggleBookmark() async {
    if (state.report == null || state.isBookmarking) return;

    state = state.copyWith(isBookmarking: true);

    try {
      final repository = ref.read(reportRepositoryProvider);
      final report = state.report!;
      
      if (report.isBookmarked) {
        await repository.unbookmarkReport(reportId);
        state = state.copyWith(
          report: report.copyWith(isBookmarked: false),
          isBookmarking: false,
        );
      } else {
        await repository.bookmarkReport(reportId);
        state = state.copyWith(
          report: report.copyWith(isBookmarked: true),
          isBookmarking: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isBookmarking: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addComment(String content) async {
    if (content.trim().isEmpty || state.isSubmittingComment) return;

    state = state.copyWith(isSubmittingComment: true, commentError: null);

    try {
      final repository = ref.read(reportRepositoryProvider);
      final request = AddCommentRequest(content: content.trim());
      
      final newComment = await repository.addComment(reportId, request);
      
      final updatedComments = [newComment, ...state.comments];
      
      state = state.copyWith(
        comments: updatedComments,
        isSubmittingComment: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSubmittingComment: false,
        commentError: e.toString(),
      );
    }
  }

  Future<void> updateComment(String commentId, String content) async {
    if (content.trim().isEmpty) return;

    try {
      final repository = ref.read(reportRepositoryProvider);
      final request = UpdateCommentRequest(content: content.trim());
      
      final updatedComment = await repository.updateComment(commentId, request);
      
      final updatedComments = state.comments.map((comment) {
        if (comment.id == commentId) {
          return updatedComment;
        }
        return comment;
      }).toList();
      
      state = state.copyWith(comments: updatedComments);
    } catch (e) {
      state = state.copyWith(commentError: e.toString());
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      final repository = ref.read(reportRepositoryProvider);
      await repository.deleteComment(commentId);
      
      final updatedComments = state.comments
          .where((comment) => comment.id != commentId)
          .toList();
      
      state = state.copyWith(comments: updatedComments);
    } catch (e) {
      state = state.copyWith(commentError: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearCommentError() {
    state = state.copyWith(commentError: null);
  }
}