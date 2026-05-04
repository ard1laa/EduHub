enum NewsCategory { announcement, update, event, maintenance }

extension NewsCategoryExt on NewsCategory {
  String get displayName {
    switch (this) {
      case NewsCategory.announcement:
        return 'Announcement';
      case NewsCategory.update:
        return 'Update';
      case NewsCategory.event:
        return 'Event';
      case NewsCategory.maintenance:
        return 'Maintenance';
    }
  }
}

class NewsModel {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final NewsCategory category;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPublished;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.category = NewsCategory.announcement,
    required this.createdAt,
    this.updatedAt,
    this.isPublished = true,
  });

  NewsModel copyWith({
    String? title,
    String? content,
    NewsCategory? category,
    DateTime? updatedAt,
    bool? isPublished,
  }) {
    return NewsModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId,
      authorName: authorName,
      category: category ?? this.category,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  static List<NewsModel> get mockNews => [
        NewsModel(
          id: 'news_001',
          title: 'Welcome to EduHub Platform!',
          content:
              'We are excited to launch EduHub, your personal learning management platform. '
              'Track your study sessions, manage your video library, and share quality '
              'content with the community.',
          authorId: 'admin_001',
          authorName: 'Dr. Sarah Chen',
          category: NewsCategory.announcement,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          isPublished: true,
        ),
        NewsModel(
          id: 'news_002',
          title: 'New Feature: Album Sharing',
          content:
              'You can now submit your curated video albums for community sharing. '
              'Admins will review and approve your submissions within 24 hours. '
              'Make sure your content follows community guidelines.',
          authorId: 'admin_001',
          authorName: 'Dr. Sarah Chen',
          category: NewsCategory.update,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          isPublished: true,
        ),
        NewsModel(
          id: 'news_003',
          title: 'Monthly Study Challenge – April 2026',
          content:
              'Join our April study challenge! Log at least 20 hours of study sessions '
              'this month to earn a certificate of achievement. '
              'Track your progress on the dashboard.',
          authorId: 'admin_001',
          authorName: 'Dr. Sarah Chen',
          category: NewsCategory.event,
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          isPublished: true,
        ),
        NewsModel(
          id: 'news_004',
          title: 'Scheduled Maintenance – April 20',
          content:
              'The platform will undergo scheduled maintenance on April 20 from '
              '02:00 AM to 04:00 AM UTC. During this time, the app may be temporarily unavailable.',
          authorId: 'admin_001',
          authorName: 'Dr. Sarah Chen',
          category: NewsCategory.maintenance,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          isPublished: false, // Draft – only admin sees this
        ),
      ];
}
