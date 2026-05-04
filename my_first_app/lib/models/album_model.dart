class AlbumModel {
  final String id;
  final String title;
  final String description;
  final String ownerId;
  final String ownerName;
  final List<String> videoIds;
  final String? coverVideoId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;
  final String colorHex;

  AlbumModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.ownerName,
    this.videoIds = const [],
    this.coverVideoId,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = false,
    this.colorHex = '#4361EE',
  });

  int get videoCount => videoIds.length;

  String get coverThumbnail {
    if (coverVideoId != null) {
      return 'https://img.youtube.com/vi/$coverVideoId/maxresdefault.jpg';
    }
    return '';
  }

  AlbumModel copyWith({
    String? title,
    String? description,
    List<String>? videoIds,
    String? coverVideoId,
    bool? isPublic,
    String? colorHex,
  }) {
    return AlbumModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      ownerId: ownerId,
      ownerName: ownerName,
      videoIds: videoIds ?? this.videoIds,
      coverVideoId: coverVideoId ?? this.coverVideoId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isPublic: isPublic ?? this.isPublic,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  static List<AlbumModel> get mockAlbums => [
        AlbumModel(
          id: 'a001',
          title: 'Programming Essentials',
          description: 'All my programming tutorials and coding resources.',
          ownerId: 'user_001',
          ownerName: 'Alex Johnson',
          videoIds: ['v001', 'v003', 'v005'],
          coverVideoId: 'VPvVD8t02U8',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          isPublic: true,
          colorHex: '#4361EE',
        ),
        AlbumModel(
          id: 'a002',
          title: 'Math Mastery',
          description: 'Mathematics from basics to advanced calculus.',
          ownerId: 'user_001',
          ownerName: 'Alex Johnson',
          videoIds: ['v002'],
          coverVideoId: 'WUvTyaaNkzM',
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
          updatedAt: DateTime.now().subtract(const Duration(days: 10)),
          colorHex: '#7209B7',
        ),
        AlbumModel(
          id: 'a003',
          title: 'History & Social Studies',
          description: 'World history and social science resources.',
          ownerId: 'user_001',
          ownerName: 'Alex Johnson',
          videoIds: ['v004'],
          coverVideoId: 'fo2Rb9h788s',
          createdAt: DateTime.now().subtract(const Duration(days: 18)),
          updatedAt: DateTime.now().subtract(const Duration(days: 18)),
          colorHex: '#F77F00',
        ),
        AlbumModel(
          id: 'a004',
          title: 'Language Learning',
          description: 'English language improvement series.',
          ownerId: 'user_001',
          ownerName: 'Alex Johnson',
          videoIds: ['v006'],
          coverVideoId: '4UWVG5oN1rc',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          updatedAt: DateTime.now().subtract(const Duration(days: 7)),
          colorHex: '#06D6A0',
        ),
      ];
}
