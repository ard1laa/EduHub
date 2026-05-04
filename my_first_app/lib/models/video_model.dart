enum VideoCategory {
  mathematics,
  science,
  programming,
  history,
  language,
  arts,
  business,
  technology,
  health,
  other;

  String get displayName {
    switch (this) {
      case VideoCategory.mathematics: return 'Mathematics';
      case VideoCategory.science: return 'Science';
      case VideoCategory.programming: return 'Programming';
      case VideoCategory.history: return 'History';
      case VideoCategory.language: return 'Language';
      case VideoCategory.arts: return 'Arts';
      case VideoCategory.business: return 'Business';
      case VideoCategory.technology: return 'Technology';
      case VideoCategory.health: return 'Health';
      case VideoCategory.other: return 'Other';
    }
  }
}

class VideoModel {
  final String id;
  final String title;
  final String description;
  final String youtubeUrl;
  final String youtubeId;
  final VideoCategory category;
  final String ownerId;
  final String ownerName;
  final List<String> tags;
  final List<String> albumIds;
  final bool isPublic;
  final bool isDownloaded;
  final bool isShared;
  final bool shareApproved;
  final DateTime savedAt;
  final DateTime? lastViewedAt;
  final int viewCount;
  final int durationMinutes;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.youtubeUrl,
    required this.youtubeId,
    required this.category,
    required this.ownerId,
    required this.ownerName,
    this.tags = const [],
    this.albumIds = const [],
    this.isPublic = false,
    this.isDownloaded = false,
    this.isShared = false,
    this.shareApproved = false,
    required this.savedAt,
    this.lastViewedAt,
    this.viewCount = 0,
    this.durationMinutes = 0,
  });

  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg';

  String get watchUrl => 'https://www.youtube.com/watch?v=$youtubeId';

  String get durationLabel {
    if (durationMinutes < 60) return '${durationMinutes}m';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  VideoModel copyWith({
    String? title,
    String? description,
    VideoCategory? category,
    List<String>? tags,
    List<String>? albumIds,
    bool? isPublic,
    bool? isDownloaded,
    bool? isShared,
    bool? shareApproved,
    DateTime? lastViewedAt,
    int? viewCount,
  }) {
    return VideoModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      youtubeUrl: youtubeUrl,
      youtubeId: youtubeId,
      category: category ?? this.category,
      ownerId: ownerId,
      ownerName: ownerName,
      tags: tags ?? this.tags,
      albumIds: albumIds ?? this.albumIds,
      isPublic: isPublic ?? this.isPublic,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isShared: isShared ?? this.isShared,
      shareApproved: shareApproved ?? this.shareApproved,
      savedAt: savedAt,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      viewCount: viewCount ?? this.viewCount,
      durationMinutes: durationMinutes,
    );
  }

  static String extractYoutubeId(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtu.be')) return uri.pathSegments.first;
      if (uri.host.contains('youtube.com')) {
        return uri.queryParameters['v'] ?? '';
      }
    } catch (_) {}
    return '';
  }

  static List<VideoModel> get mockVideos => [
        VideoModel(
          id: 'v001',
          title: 'Introduction to Flutter Development',
          description:
              'Learn the basics of Flutter and Dart programming to build stunning cross-platform apps.',
          youtubeUrl: 'https://www.youtube.com/watch?v=VPvVD8t02U8',
          youtubeId: 'VPvVD8t02U8',
          category: VideoCategory.programming,
          ownerId: 'user_001',
          ownerName: 'Alex Johnson',
          tags: ['flutter', 'dart', 'mobile'],
          savedAt: DateTime.now().subtract(const Duration(days: 5)),
          lastViewedAt: DateTime.now().subtract(const Duration(days: 1)),
          viewCount: 12,
          durationMinutes: 45,
          isPublic: true,
          isShared: true,
          shareApproved: true,
        ),
        VideoModel(
          id: 'v002',
          title: 'Calculus Made Easy – Limits & Derivatives',
          description:
              'A comprehensive guide to understanding limits and derivatives with visual examples.',
          youtubeUrl: 'https://www.youtube.com/watch?v=WUvTyaaNkzM',
          youtubeId: 'WUvTyaaNkzM',
          category: VideoCategory.mathematics,
          ownerId: 'user_001',
          ownerName: 'Alex Johnson',
          tags: ['calculus', 'math', 'derivatives'],
          savedAt: DateTime.now().subtract(const Duration(days: 10)),
          lastViewedAt: DateTime.now().subtract(const Duration(days: 3)),
          viewCount: 8,
          durationMinutes: 62,
          isDownloaded: true,
        ),
        VideoModel(
          id: 'v003',
          title: 'Python for Data Science – Full Course',
          description:
              'Master Python programming for data analysis, visualization, and machine learning.',
          youtubeUrl: 'https://www.youtube.com/watch?v=LHBE6Q9XlzI',
          youtubeId: 'LHBE6Q9XlzI',
          category: VideoCategory.programming,
          ownerId: 'user_001',
          ownerName: 'Alex Johnson',
          tags: ['python', 'data science', 'ML'],
          savedAt: DateTime.now().subtract(const Duration(days: 15)),
          viewCount: 20,
          durationMinutes: 180,
          isPublic: true,
          isShared: true,
          shareApproved: false,
        ),
        VideoModel(
          id: 'v004',
          title: 'World War II – Complete History',
          description:
              'A detailed account of World War II covering key events, battles, and their impact.',
          youtubeUrl: 'https://www.youtube.com/watch?v=fo2Rb9h788s',
          youtubeId: 'fo2Rb9h788s',
          category: VideoCategory.history,
          ownerId: 'user_001',
          ownerName: 'Alex Johnson',
          tags: ['history', 'WWII', 'war'],
          savedAt: DateTime.now().subtract(const Duration(days: 20)),
          viewCount: 5,
          durationMinutes: 120,
          isDownloaded: true,
        ),
        VideoModel(
          id: 'v005',
          title: 'Machine Learning Crash Course',
          description:
              'From neural networks to deep learning – your complete AI introduction.',
          youtubeUrl: 'https://www.youtube.com/watch?v=NWONeJKn6kc',
          youtubeId: 'NWONeJKn6kc',
          category: VideoCategory.technology,
          ownerId: 'user_001',
          ownerName: 'Alex Johnson',
          tags: ['AI', 'ML', 'neural networks'],
          savedAt: DateTime.now().subtract(const Duration(days: 2)),
          viewCount: 3,
          durationMinutes: 90,
        ),
        VideoModel(
          id: 'v006',
          title: 'English Grammar – Advanced Level',
          description:
              'Perfect your English grammar with advanced exercises and explanations.',
          youtubeUrl: 'https://www.youtube.com/watch?v=4UWVG5oN1rc',
          youtubeId: '4UWVG5oN1rc',
          category: VideoCategory.language,
          ownerId: 'user_001',
          ownerName: 'Alex Johnson',
          tags: ['english', 'grammar', 'language'],
          savedAt: DateTime.now().subtract(const Duration(days: 7)),
          lastViewedAt: DateTime.now().subtract(const Duration(hours: 6)),
          viewCount: 15,
          durationMinutes: 55,
          isPublic: true,
          isShared: true,
          shareApproved: true,
        ),
      ];
}
