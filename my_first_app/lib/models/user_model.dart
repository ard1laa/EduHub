enum UserRole { student, admin }

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final String? avatarUrl;
  final DateTime joinedAt;
  final int videosCount;
  final int albumsCount;
  final int downloadCount;
  final int totalSessionMinutes;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.role = UserRole.student,
    this.avatarUrl,
    required this.joinedAt,
    this.videosCount = 0,
    this.albumsCount = 0,
    this.downloadCount = 0,
    this.totalSessionMinutes = 0,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
  }

  bool get isAdmin => role == UserRole.admin;

  UserModel copyWith({
    String? fullName,
    String? email,
    String? avatarUrl,
    int? videosCount,
    int? albumsCount,
    int? downloadCount,
    int? totalSessionMinutes,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      joinedAt: joinedAt,
      videosCount: videosCount ?? this.videosCount,
      albumsCount: albumsCount ?? this.albumsCount,
      downloadCount: downloadCount ?? this.downloadCount,
      totalSessionMinutes: totalSessionMinutes ?? this.totalSessionMinutes,
    );
  }

  // ─── JSON serialization ───────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'role': role.name,
        'avatarUrl': avatarUrl,
        'joinedAt': joinedAt.toIso8601String(),
        'videosCount': videosCount,
        'albumsCount': albumsCount,
        'downloadCount': downloadCount,
        'totalSessionMinutes': totalSessionMinutes,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        role: (json['role'] as String) == 'admin'
            ? UserRole.admin
            : UserRole.student,
        avatarUrl: json['avatarUrl'] as String?,
        joinedAt: DateTime.parse(json['joinedAt'] as String),
        videosCount: (json['videosCount'] as num?)?.toInt() ?? 0,
        albumsCount: (json['albumsCount'] as num?)?.toInt() ?? 0,
        downloadCount: (json['downloadCount'] as num?)?.toInt() ?? 0,
        totalSessionMinutes:
            (json['totalSessionMinutes'] as num?)?.toInt() ?? 0,
      );

  static UserModel get mockStudent => UserModel(
        id: 'user_001',
        fullName: 'Alex Johnson',
        email: 'alex.johnson@student.edu',
        role: UserRole.student,
        joinedAt: DateTime(2025, 9, 1),
        videosCount: 24,
        albumsCount: 6,
        downloadCount: 18,
        totalSessionMinutes: 1340,
      );

  static UserModel get mockAdmin => UserModel(
        id: 'admin_001',
        fullName: 'Dr. Sarah Chen',
        email: 'sarah.chen@educator.edu',
        role: UserRole.admin,
        joinedAt: DateTime(2024, 1, 15),
        videosCount: 45,
        albumsCount: 12,
        downloadCount: 60,
        totalSessionMinutes: 4200,
      );
}
