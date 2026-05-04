enum NotificationType { session, video, share, download, system, announcement }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime time;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        time: time,
        isRead: isRead ?? this.isRead,
      );

  static List<AppNotification> get mockNotifications => [
        AppNotification(
          id: 'n001',
          type: NotificationType.share,
          title: 'Share Request Approved',
          body: 'Your share request for "Flutter Beginner" was approved.',
          time: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        AppNotification(
          id: 'n002',
          type: NotificationType.session,
          title: 'Study Goal Reached',
          body: 'Congrats! You logged 2 hours of study today.',
          time: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        AppNotification(
          id: 'n003',
          type: NotificationType.video,
          title: 'New Video Saved',
          body: 'You added "Calculus Crash Course" to your library.',
          time: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        AppNotification(
          id: 'n004',
          type: NotificationType.download,
          title: 'Download Complete',
          body: '"Introduction to Algorithms" is ready offline.',
          time: DateTime.now().subtract(const Duration(hours: 5)),
          isRead: true,
        ),
        AppNotification(
          id: 'n005',
          type: NotificationType.share,
          title: 'Share Request Rejected',
          body: 'Admin rejected your request for "Advanced SQL". See note.',
          time: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
        AppNotification(
          id: 'n006',
          type: NotificationType.system,
          title: 'Welcome to EduHub!',
          body: 'Start adding videos and tracking your learning journey.',
          time: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
        ),
        AppNotification(
          id: 'n007',
          type: NotificationType.video,
          title: 'Trending in Programming',
          body: '"Clean Code Principles" is popular among students this week.',
          time: DateTime.now().subtract(const Duration(days: 3)),
          isRead: true,
        ),
      ];
}
