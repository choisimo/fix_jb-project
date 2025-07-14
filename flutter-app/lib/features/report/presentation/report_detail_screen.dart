import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../domain/models/report.dart';

// 임시 Provider - 실제로는 별도 controller 필요
final reportDetailProvider = FutureProvider.family<Report, String>((ref, reportId) async {
  // 시뮬레이션: 임시 데이터
  await Future.delayed(const Duration(milliseconds: 500));
  
  return Report(
    id: reportId,
    title: 'Pothole on Main Street',
    description: 'Large pothole causing damage to vehicles. This has been ongoing for several weeks and multiple residents have complained about vehicle damage. The hole is approximately 2 feet wide and 6 inches deep, making it dangerous for both cars and motorcycles.',
    type: ReportType.pothole,
    status: ReportStatus.submitted,
    authorId: 'user1',
    authorName: 'John Doe',
    authorProfileImage: null,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    priority: Priority.high,
    viewCount: 25,
    likeCount: 8,
    commentsCount: 5,
    isLiked: false,
    isBookmarked: true,
    location: const ReportLocation(
      latitude: 37.7749,
      longitude: -122.4194,
      address: '123 Main Street, San Francisco, CA',
      city: 'San Francisco',
    ),
    images: [
      const ReportImage(
        id: 'img1',
        url: 'https://via.placeholder.com/400x300/FF6B6B/FFFFFF?text=Pothole+Image+1',
        thumbnailUrl: 'https://via.placeholder.com/150x150/FF6B6B/FFFFFF?text=Thumb+1',
        filename: 'pothole_1.jpg',
        isPrimary: true,
      ),
      const ReportImage(
        id: 'img2', 
        url: 'https://via.placeholder.com/400x300/4ECDC4/FFFFFF?text=Pothole+Image+2',
        thumbnailUrl: 'https://via.placeholder.com/150x150/4ECDC4/FFFFFF?text=Thumb+2',
        filename: 'pothole_2.jpg',
      ),
    ],
    comments: [
      ReportComment(
        id: 'c1',
        reportId: reportId,
        authorId: 'user2',
        authorName: 'Jane Smith',
        content: 'I also experienced this issue yesterday. My car tire was damaged.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        likesCount: 2,
      ),
      ReportComment(
        id: 'c2',
        reportId: reportId,
        authorId: 'user3',
        authorName: 'Mike Johnson',
        content: 'This has been a problem for weeks. The city needs to fix this urgently.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        likesCount: 5,
      ),
    ],
  );
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
  final _scrollController = ScrollController();
  bool _isSubmittingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
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
          appBar: AppBar(title: const Text('Error')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load report',
                  style: TextStyle(fontSize: 18, color: Colors.red.shade700),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.invalidate(reportDetailProvider(widget.reportId)),
                  child: const Text('Retry'),
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
      controller: _scrollController,
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
              icon: Icon(
                report.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.white,
              ),
              onPressed: () => _toggleBookmark(report),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) => _handleMenuAction(value, report),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Share'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'report',
                  child: ListTile(
                    leading: Icon(Icons.flag),
                    title: Text('Report'),
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
                        'Location',
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
                    'Images',
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
                      onTap: () => _toggleLike(report),
                      child: Row(
                        children: [
                          Icon(
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
                      'Comments (${report.comments.length})',
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
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _submitComment(report),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: _isSubmittingComment
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send, color: Colors.white),
                              onPressed: () => _submitComment(report),
                            ),
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
                            comment.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            size: 14,
                            color: comment.isLiked ? Colors.blue : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            comment.likesCount.toString(),
                            style: TextStyle(
                              color: comment.isLiked ? Colors.blue : Colors.grey.shade600,
                              fontSize: 12,
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
    // TODO: Implement like toggle
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(report.isLiked ? 'Removed like' : 'Liked report'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleBookmark(Report report) {
    // TODO: Implement bookmark toggle
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(report.isBookmarked ? 'Removed bookmark' : 'Bookmarked'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleCommentLike(ReportComment comment) {
    // TODO: Implement comment like toggle
  }

  void _submitComment(Report report) async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isSubmittingComment = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isSubmittingComment = false;
    });

    _commentController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment added successfully'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showImageGallery(List<ReportImage> images, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];
              return InteractiveViewer(
                child: Image.network(
                  image.url,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action, Report report) {
    switch (action) {
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share functionality not implemented')),
        );
        break;
      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report functionality not implemented')),
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
        return 'Pothole';
      case ReportType.streetLight:
        return 'Street Light';
      case ReportType.trash:
        return 'Trash';
      case ReportType.graffiti:
        return 'Graffiti';
      case ReportType.roadDamage:
        return 'Road Damage';
      case ReportType.construction:
        return 'Construction';
      case ReportType.other:
        return 'Other';
    }
  }

  String _getStatusDisplayName(ReportStatus status) {
    switch (status) {
      case ReportStatus.draft:
        return 'Draft';
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.inProgress:
        return 'In Progress';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.rejected:
        return 'Rejected';
      case ReportStatus.closed:
        return 'Closed';
    }
  }

  String _getPriorityDisplayName(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
      case Priority.urgent:
        return 'Urgent';
    }
  }
}