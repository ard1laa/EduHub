enum ShareStatus { pending, approved, rejected }

class ShareRequestModel {
  final String id;
  final String videoId;
  final String videoTitle;
  final String videoThumbnail;
  final String requesterId;
  final String requesterName;
  final String message;
  final ShareStatus status;
  final DateTime requestedAt;
  final DateTime? reviewedAt;
  final String? reviewerNote;

  ShareRequestModel({
    required this.id,
    required this.videoId,
    required this.videoTitle,
    required this.videoThumbnail,
    required this.requesterId,
    required this.requesterName,
    required this.message,
    this.status = ShareStatus.pending,
    required this.requestedAt,
    this.reviewedAt,
    this.reviewerNote,
  });

  bool get isPending => status == ShareStatus.pending;
  bool get isApproved => status == ShareStatus.approved;
  bool get isRejected => status == ShareStatus.rejected;

  ShareRequestModel copyWith({
    ShareStatus? status,
    DateTime? reviewedAt,
    String? reviewerNote,
  }) {
    return ShareRequestModel(
      id: id,
      videoId: videoId,
      videoTitle: videoTitle,
      videoThumbnail: videoThumbnail,
      requesterId: requesterId,
      requesterName: requesterName,
      message: message,
      status: status ?? this.status,
      requestedAt: requestedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewerNote: reviewerNote ?? this.reviewerNote,
    );
  }

  static List<ShareRequestModel> get mockRequests => [
        ShareRequestModel(
          id: 'sr001',
          videoId: 'v003',
          videoTitle: 'Python for Data Science – Full Course',
          videoThumbnail:
              'https://img.youtube.com/vi/LHBE6Q9XlzI/maxresdefault.jpg',
          requesterId: 'user_001',
          requesterName: 'Alex Johnson',
          message:
              'This is a great resource for all CS students. Please approve!',
          status: ShareStatus.pending,
          requestedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        ShareRequestModel(
          id: 'sr002',
          videoId: 'v001',
          videoTitle: 'Introduction to Flutter Development',
          videoThumbnail:
              'https://img.youtube.com/vi/VPvVD8t02U8/maxresdefault.jpg',
          requesterId: 'user_001',
          requesterName: 'Alex Johnson',
          message: 'Flutter basics for all mobile dev students.',
          status: ShareStatus.approved,
          requestedAt: DateTime.now().subtract(const Duration(days: 7)),
          reviewedAt: DateTime.now().subtract(const Duration(days: 5)),
          reviewerNote: 'Great content! Approved for community sharing.',
        ),
        ShareRequestModel(
          id: 'sr003',
          videoId: 'v006',
          videoTitle: 'English Grammar – Advanced Level',
          videoThumbnail:
              'https://img.youtube.com/vi/4UWVG5oN1rc/maxresdefault.jpg',
          requesterId: 'user_001',
          requesterName: 'Alex Johnson',
          message: 'Helpful for language arts students.',
          status: ShareStatus.approved,
          requestedAt: DateTime.now().subtract(const Duration(days: 10)),
          reviewedAt: DateTime.now().subtract(const Duration(days: 8)),
          reviewerNote: 'Approved.',
        ),
      ];
}

class DownloadItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String fileType;
  final double fileSizeMB;
  final String downloadUrl;
  final bool isDownloaded;
  final DateTime? downloadedAt;
  final DateTime uploadedAt;

  DownloadItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.fileType,
    required this.fileSizeMB,
    required this.downloadUrl,
    this.isDownloaded = false,
    this.downloadedAt,
    required this.uploadedAt,
  });

  String get sizeLabel {
    if (fileSizeMB < 1) return '${(fileSizeMB * 1024).toStringAsFixed(0)} KB';
    return '${fileSizeMB.toStringAsFixed(1)} MB';
  }

  DownloadItem copyWith({bool? isDownloaded, DateTime? downloadedAt}) {
    return DownloadItem(
      id: id,
      title: title,
      description: description,
      category: category,
      fileType: fileType,
      fileSizeMB: fileSizeMB,
      downloadUrl: downloadUrl,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      uploadedAt: uploadedAt,
    );
  }

  static List<DownloadItem> get mockItems => [
        DownloadItem(
          id: 'd001',
          title: 'Flutter Development Cheat Sheet',
          description:
              'A comprehensive quick reference for Flutter widgets, layouts, and best practices.',
          category: 'Programming',
          fileType: 'PDF',
          fileSizeMB: 2.4,
          downloadUrl: 'https://flutter.dev/docs',
          uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
          isDownloaded: true,
          downloadedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        DownloadItem(
          id: 'd002',
          title: 'Calculus Formula Reference',
          description:
              'All essential calculus formulas – derivatives, integrals, and theorems.',
          category: 'Mathematics',
          fileType: 'PDF',
          fileSizeMB: 1.8,
          downloadUrl: 'https://mathworld.wolfram.com',
          uploadedAt: DateTime.now().subtract(const Duration(days: 10)),
          isDownloaded: true,
          downloadedAt: DateTime.now().subtract(const Duration(days: 9)),
        ),
        DownloadItem(
          id: 'd003',
          title: 'Python Quick Reference Guide',
          description:
              'Python 3.x syntax, data structures, and standard library overview.',
          category: 'Programming',
          fileType: 'PDF',
          fileSizeMB: 3.2,
          downloadUrl: 'https://docs.python.org',
          uploadedAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        DownloadItem(
          id: 'd004',
          title: 'World History Timeline',
          description:
              'Key events from ancient civilizations to the modern era in a visual timeline.',
          category: 'History',
          fileType: 'PDF',
          fileSizeMB: 5.6,
          downloadUrl: 'https://history.com',
          uploadedAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
        DownloadItem(
          id: 'd005',
          title: 'Machine Learning Algorithms Overview',
          description:
              'A visual guide to popular ML algorithms with use cases and performance comparisons.',
          category: 'Technology',
          fileType: 'PDF',
          fileSizeMB: 4.1,
          downloadUrl: 'https://ml-overview.com',
          uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        DownloadItem(
          id: 'd006',
          title: 'English Grammar Practice Exercises',
          description:
              '50 exercises covering advanced English grammar topics with answer keys.',
          category: 'Language',
          fileType: 'DOCX',
          fileSizeMB: 0.8,
          downloadUrl: 'https://english-grammar.com',
          uploadedAt: DateTime.now().subtract(const Duration(days: 7)),
          isDownloaded: true,
          downloadedAt: DateTime.now().subtract(const Duration(days: 6)),
        ),
      ];
}
