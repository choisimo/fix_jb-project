enum ReportStatus {
  draft,
  submitted,
  approved,
  rejected,
}

enum ReportCategory {
  safety,
  quality,
  progress,
  maintenance,
  other,
}

enum ReportPriority {
  low,
  normal,
  high,
  urgent,
}

class Report {
  final String id;
  final String title;
  final String content;
  final ReportCategory category;
  final ReportPriority priority;
  final ReportStatus status;
  final List<String> imageUrls;
  final ReportLocation? location;
  final String? signature;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ReportComment> comments;

  Report({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.priority,
    required this.status,
    required this.imageUrls,
    this.location,
    this.signature,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
    required this.comments,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: ReportCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ReportCategory.other,
      ),
      priority: ReportPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => ReportPriority.normal,
      ),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.draft,
      ),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      location: json['location'] != null 
          ? ReportLocation.fromJson(json['location']) 
          : null,
      signature: json['signature'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      comments: (json['comments'] as List?)
          ?.map((e) => ReportComment.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category.name,
      'priority': priority.name,
      'status': status.name,
      'imageUrls': imageUrls,
      'location': location?.toJson(),
      'signature': signature,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'comments': comments.map((e) => e.toJson()).toList(),
    };
  }
}

class ReportLocation {
  final double latitude;
  final double longitude;
  final String address;
  final double accuracy;

  ReportLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.accuracy,
  });

  factory ReportLocation.fromJson(Map<String, dynamic> json) {
    return ReportLocation(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
      accuracy: json['accuracy'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'accuracy': accuracy,
    };
  }
}

class ReportComment {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;

  ReportComment({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
  });

  factory ReportComment.fromJson(Map<String, dynamic> json) {
    return ReportComment(
      id: json['id'],
      content: json['content'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
