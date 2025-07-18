import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../domain/models/report.dart';
import '../data/providers/report_providers.dart';
import '../domain/services/report_service.dart';
import 'dart:developer' as developer;

// 신고서 상세 정보를 가져오는 Provider
final reportDetailProvider = FutureProvider.family<Report, String>((ref, reportId) async {
  try {
    developer.log('Fetching report details for ID: $reportId', name: 'REPORT_DETAIL');
    final reportService = ref.read(reportServiceProvider);
    final report = await reportService.getReportById(reportId);
    developer.log('Report details fetched successfully', name: 'REPORT_DETAIL');
    return report;
  } catch (e) {
    developer.log('Error fetching report details: $e', name: 'REPORT_DETAIL', error: true);
    throw Exception('신고서를 불러오는 중 오류가 발생했습니다: $e');
  }
});

class ReportDetailScreen extends ConsumerStatefulWidget {
  final String reportId;

  const ReportDetailScreen({
    super.key,
    required this.reportId,
  });

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  final _commentController = TextEditingController();
  bool _isLiking = false;
  bool _isBookmarking = false;
  bool _isSubmittingComment = false;
  bool _isLoadingImages = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 라우터 파라미터가 변경되면 데이터 새로고침
    final reportId = widget.reportId;
    if (reportId.isNotEmpty) {
      ref.invalidate(reportDetailProvider(reportId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(reportDetailProvider(widget.reportId));

    return Scaffold(
      body: reportAsync.when(
        data: (report) => _buildReportDetail(report),
        loading: () => const Scaffold(
          appBar: null,
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('오류')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  '신고서를 불러오는데 실패했습니다',
                  style: TextStyle(fontSize: 18, color: Colors.red.shade700),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(fontSize: 14, color: Colors.red.shade500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(reportDetailProvider(widget.reportId)),
                  child: const Text('다시 시도'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('뒤로 가기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportDetail(Report report) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: report.images.isNotEmpty ? 250 : 120,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              report.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            background: report.images.isNotEmpty
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        report.images.first.url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getTypeColor(report.type),
                          _getTypeColor(report.type).withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
          ),
          actions: [
            IconButton(
              icon: _isBookmarking
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(
                      report.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: report.isBookmarked ? Colors.blue : null,
                    ),
              onPressed: _isBookmarking ? null : () => _toggleBookmark(report),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) => _handleMenuAction(value, report),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share),
                    title: Text('공유하기'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'report',
                  child: ListTile(
                    leading: Icon(Icons.flag),
                    title: Text('신고하기'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('수정하기'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and Priority Row
                Row(
                  children: [
                    _buildStatusChip(report.status),
                    const SizedBox(width: 8),
                    _buildPriorityChip(report.priority),
                    const Spacer(),
                    _buildTypeChip(report.type),
                  ],
                ),
                const SizedBox(height: 16),

                // Author and Date
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: report.authorProfileImage != null
                          ? NetworkImage(report.authorProfileImage!)
                          : null,
                      child: report.authorProfileImage == null
                          ? Text(
                              report.authorName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            timeago.format(report.createdAt),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  report.description,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Location
                if (report.location != null) ...[
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      const Text(
                        '위치 정보',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.location!.address ?? 'Address not available',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lat: ${report.location!.latitude.toStringAsFixed(6)}, '
                          'Lng: ${report.location!.longitude.toStringAsFixed(6)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Images Gallery
                if (report.images.length > 1) ...[
                  const Text(
                    '이미지',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: report.images.length,
                      itemBuilder: (context, index) {
                        final image = report.images[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _showImageGallery(report.images, index),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                image.thumbnailUrl ?? image.url,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Stats and Actions
                Row(
                  children: [
                    _buildStatItem(Icons.visibility, report.viewCount.toString()),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: _isLiking ? null : () => _toggleLike(report),
                      child: Row(
                        children: [
                          _isLiking
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : Icon(
                                  report.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                  size: 16,
                                  color: report.isLiked ? Colors.blue : Colors.grey.shade600,
                                ),
                          const SizedBox(width: 4),
                          Text(
                            report.likeCount.toString(),
                            style: TextStyle(
                              color: report.isLiked ? Colors.blue : Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(Icons.comment_outlined, report.commentsCount.toString()),
                  ],
                ),
                const SizedBox(height: 24),

                // Comments Section
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.comment),
                    const SizedBox(width: 8),
                    Text(
                      '댓글 (${report.comments.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Add Comment
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: '댓글 작성...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: _isSubmittingComment ? null : (_) => _submitComment(report),
                          enabled: !_isSubmittingComment,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: _isSubmittingComment
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.send),
                      onPressed: _isSubmittingComment ? null : () => _submitComment(report),
                      color: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Comments List
                ...report.comments.map((comment) => _buildComment(comment)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComment(ReportComment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: comment.authorProfileImage != null
                ? NetworkImage(comment.authorProfileImage!)
                : null,
            child: comment.authorProfileImage == null
                ? Text(
                    comment.authorName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(comment.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleCommentLike(comment),
                      child: Row(
                        children: [
                          Icon(
                            comment.isLiked ?? false
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                            size: 14,
                            color: comment.isLiked ?? false
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${comment.likesCount}',
                            style: TextStyle(
                              fontSize: 12,
                              color: comment.isLiked ?? false ? Colors.blue : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatusChip(ReportStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _getStatusDisplayName(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(Priority priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _getPriorityDisplayName(priority),
        style: TextStyle(
          color: _getPriorityColor(priority),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTypeChip(ReportType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getTypeColor(type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getTypeIcon(type), size: 14, color: _getTypeColor(type)),
          const SizedBox(width: 4),
          Text(
            _getTypeDisplayName(type),
            style: TextStyle(
              color: _getTypeColor(type),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleLike(Report report) {
    setState(() {
      _isLiking = true;
    });
    
    // TODO: API 연동 - 현재는 시뮬레이션
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
        
        final message = report.isLiked ? '신고서 좋아요가 취소되었습니다' : '신고서에 좋아요를 표시했습니다';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });
  }

  void _toggleBookmark(Report report) {
    // TODO: API 연동 - 현재는 시뮬레이션
    setState(() {
      _isBookmarking = true;
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isBookmarking = false;
        });
        
        final message = report.isBookmarked ? '신고서 북마크가 취소되었습니다' : '신고서에 북마크를 표시했습니다';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });
  }

  void _toggleCommentLike(ReportComment comment) {
    // TODO: API 연동 - 댓글 좋아요 토글 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('댓글 좋아요 기능은 아직 구현되지 않았습니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _submitComment(Report report) {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;
    
    setState(() {
      _isSubmittingComment = true;
    });
    
    // TODO: API 연동
    // 실제 구현시 ReportService를 통해 신고서 댓글 저장 API 호출
    // final reportService = ref.read(reportServiceProvider);
    // try {
    //   await reportService.createComment(report.id!, comment);
    // }
    
    // 임시 구현
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
          _commentController.clear();
        });
        
        // 성공 시 UI 업데이트를 위해 provider 새로고침
        ref.invalidate(reportDetailProvider(report.id!));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('댓글이 성공적으로 등록되었습니다'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _showImageGallery(List<ReportImage> images, int initialIndex) {
    setState(() {
      _isLoadingImages = true;
    });
    
    try {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.black,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return Stack(
                  children: [
                    Center(
                      child: InteractiveViewer(
                        child: Image.network(
                          image.url,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / 
                                      loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => 
                              Center(child: Text('이미지 로딩 실패: ${error.toString()}', 
                                  style: const TextStyle(color: Colors.white))),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          '${index + 1} / ${images.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    } catch (e) {
      print('Error showing image gallery: $e');
    } finally {
      setState(() {
        _isLoadingImages = false;
      });
    }
  }

  void _handleMenuAction(String action, Report report) {
    switch (action) {
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공유 기능이 구현되지 않았습니다')),
        );
        break;
      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('신고 기능이 구현되지 않았습니다')),
        );
        break;
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수정 기능이 구현되지 않았습니다')),
        );
        break;
    }
  }

  // Helper methods (같은 코드이므로 생략 가능)
  Color _getTypeColor(ReportType type) {
    switch (type) {
      case ReportType.pothole:
        return Colors.orange;
      case ReportType.streetLight:
        return Colors.yellow.shade700;
      case ReportType.trash:
        return Colors.green;
      case ReportType.graffiti:
        return Colors.purple;
      case ReportType.roadDamage:
        return Colors.red;
      case ReportType.construction:
        return Colors.blue;
      case ReportType.other:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.pothole:
        return Icons.warning;
      case ReportType.streetLight:
        return Icons.lightbulb_outline;
      case ReportType.trash:
        return Icons.delete_outline;
      case ReportType.graffiti:
        return Icons.brush;
      case ReportType.roadDamage:
        return Icons.build;
      case ReportType.construction:
        return Icons.construction;
      case ReportType.other:
        return Icons.report_problem_outlined;
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.draft:
        return Colors.grey;
      case ReportStatus.submitted:
        return Colors.blue;
      case ReportStatus.inProgress:
        return Colors.orange;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
      case ReportStatus.closed:
        return Colors.grey.shade600;
    }
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
      case Priority.urgent:
        return Colors.purple;
    }
  }

  String _getTypeDisplayName(ReportType type) {
    switch (type) {
      case ReportType.pothole:
        return '포트홀';
      case ReportType.streetLight:
        return '가로등';
      case ReportType.trash:
        return '쓰레기';
      case ReportType.graffiti:
        return '낭서';
      case ReportType.roadDamage:
        return '도로 파손';
      case ReportType.construction:
        return '공사 지역';
      case ReportType.other:
        return '기타';
    }
  }

  String _getStatusDisplayName(ReportStatus status) {
    switch (status) {
      case ReportStatus.draft:
        return '임시저장';
      case ReportStatus.submitted:
        return '접수됨';
      case ReportStatus.inProgress:
        return '처리중';
      case ReportStatus.resolved:
        return '해결됨';
      case ReportStatus.rejected:
        return '거부됨';
      case ReportStatus.closed:
        return '종료됨';
    }
  }

  String _getPriorityDisplayName(Priority priority) {
    switch (priority) {
      case Priority.low:
        return '낮음';
      case Priority.medium:
        return '중간';
      case Priority.high:
        return '높음';
      case Priority.urgent:
        return '긴급';
    }
  }
}