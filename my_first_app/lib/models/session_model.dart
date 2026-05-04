class SessionModel {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<String> videoIdsWatched;
  final int totalMinutes;
  final String? notes;
  final bool isActive;

  SessionModel({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.videoIdsWatched = const [],
    this.totalMinutes = 0,
    this.notes,
    this.isActive = false,
  });

  String get durationLabel {
    if (totalMinutes < 60) return '${totalMinutes}m';
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  String get dateLabel {
    final now = DateTime.now();
    final diff = now.difference(startTime).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${startTime.day}/${startTime.month}/${startTime.year}';
  }

  SessionModel copyWith({
    DateTime? endTime,
    List<String>? videoIdsWatched,
    int? totalMinutes,
    String? notes,
    bool? isActive,
  }) {
    return SessionModel(
      id: id,
      userId: userId,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      videoIdsWatched: videoIdsWatched ?? this.videoIdsWatched,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }

  static List<SessionModel> get mockSessions => [
        SessionModel(
          id: 's001',
          userId: 'user_001',
          startTime: DateTime.now().subtract(const Duration(hours: 2)),
          endTime: DateTime.now().subtract(const Duration(hours: 1)),
          videoIdsWatched: ['v001', 'v003'],
          totalMinutes: 60,
          notes: 'Focused on Flutter basics',
        ),
        SessionModel(
          id: 's002',
          userId: 'user_001',
          startTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          endTime:
              DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 30)),
          videoIdsWatched: ['v002'],
          totalMinutes: 90,
          notes: 'Calculus revision',
        ),
        SessionModel(
          id: 's003',
          userId: 'user_001',
          startTime: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
          endTime: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
          videoIdsWatched: ['v004', 'v006'],
          totalMinutes: 120,
        ),
        SessionModel(
          id: 's004',
          userId: 'user_001',
          startTime: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
          endTime:
              DateTime.now().subtract(const Duration(days: 3, hours: 3, minutes: 15)),
          videoIdsWatched: ['v005'],
          totalMinutes: 45,
          notes: 'Machine Learning intro',
        ),
        SessionModel(
          id: 's005',
          userId: 'user_001',
          startTime: DateTime.now().subtract(const Duration(days: 5, hours: 2)),
          endTime:
              DateTime.now().subtract(const Duration(days: 5, hours: 1, minutes: 30)),
          videoIdsWatched: ['v001'],
          totalMinutes: 30,
        ),
        SessionModel(
          id: 's006',
          userId: 'user_001',
          startTime: DateTime.now().subtract(const Duration(days: 6, hours: 6)),
          endTime:
              DateTime.now().subtract(const Duration(days: 6, hours: 4, minutes: 30)),
          videoIdsWatched: ['v002', 'v003', 'v004'],
          totalMinutes: 90,
          notes: 'Long study session',
        ),
      ];
}
