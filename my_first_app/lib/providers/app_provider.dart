import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/video_model.dart';
import '../models/album_model.dart';
import '../models/session_model.dart';
import '../models/share_download_model.dart';
import '../models/notification_model.dart';
import '../models/news_model.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

enum AuthState { unauthenticated, loading, authenticated }

class AppProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  // ─── Auth State ───────────────────────────────────────────────────────────
  AuthState _authState = AuthState.unauthenticated;
  UserModel? _currentUser;
  String? _authError;

  AuthState get authState => _authState;
  UserModel? get currentUser => _currentUser;
  String? get authError => _authError;
  bool get isLoggedIn => _authState == AuthState.authenticated;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  // ─── Onboarding ───────────────────────────────────────────────────────────
  bool _hasSeenOnboarding = false;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  void completeOnboarding() {
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  // ─── Videos State ─────────────────────────────────────────────────────────
  List<VideoModel> _videos = [];
  String _videoSearchQuery = '';
  VideoCategory? _selectedCategory;

  List<VideoModel> get videos => _videos;
  String get videoSearchQuery => _videoSearchQuery;
  VideoCategory? get selectedCategory => _selectedCategory;

  List<VideoModel> get filteredVideos {
    var result = _videos.where((v) => v.ownerId == _currentUser?.id).toList();
    if (_selectedCategory != null) {
      result = result.where((v) => v.category == _selectedCategory).toList();
    }
    if (_videoSearchQuery.isNotEmpty) {
      final q = _videoSearchQuery.toLowerCase();
      result = result
          .where((v) =>
              v.title.toLowerCase().contains(q) ||
              v.description.toLowerCase().contains(q) ||
              v.tags.any((t) => t.toLowerCase().contains(q)))
          .toList();
    }
    return result..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  List<VideoModel> get recentVideos {
    return filteredVideos.take(5).toList();
  }

  /// Admin-approved public videos visible to ALL logged-in users.
  List<VideoModel> get publicVideos =>
      _videos.where((v) => v.isPublic && v.shareApproved).toList()
        ..sort((a, b) => b.savedAt.compareTo(a.savedAt));

  List<VideoModel> get downloadedVideos =>
      _videos.where((v) => v.isDownloaded).toList();

  void setVideoSearch(String query) {
    _videoSearchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(VideoCategory? cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  void addVideo(VideoModel video) {
    // Students requesting public sharing – save private, auto-submit for approval.
    if (video.isPublic && !isAdmin) {
      final pending = video.copyWith(isPublic: false, isShared: true);
      _videos.insert(0, pending);
      _currentUser = _currentUser?.copyWith(
        videosCount: (_currentUser?.videosCount ?? 0) + 1,
      );
      final req = ShareRequestModel(
        id: _uuid.v4(),
        videoId: pending.id,
        videoTitle: pending.title,
        videoThumbnail: pending.thumbnailUrl,
        requesterId: _currentUser?.id ?? '',
        requesterName: _currentUser?.fullName ?? '',
        message: 'Requesting community sharing for this video.',
        requestedAt: DateTime.now(),
      );
      _shareRequests.insert(0, req);
      // Notify the student that their request is under review
      _notifications.insert(0, AppNotification(
        id: 'pending_${pending.id}',
        type: NotificationType.share,
        title: 'Post Submitted for Review',
        body: '"${pending.title}" has been submitted and is awaiting admin approval.',
        time: DateTime.now(),
      ));
      notifyListeners();
      return;
    }
    _videos.insert(0, video);
    _currentUser = _currentUser?.copyWith(
      videosCount: (_currentUser?.videosCount ?? 0) + 1,
    );
    notifyListeners();
  }

  void updateVideo(VideoModel updated) {
    final idx = _videos.indexWhere((v) => v.id == updated.id);
    if (idx != -1) {
      _videos[idx] = updated;
      notifyListeners();
    }
  }

  void deleteVideo(String videoId) {
    _videos.removeWhere((v) => v.id == videoId);
    _currentUser = _currentUser?.copyWith(
      videosCount: ((_currentUser?.videosCount ?? 1) - 1).clamp(0, 9999),
    );
    notifyListeners();
  }

  void markVideoViewed(String videoId) {
    final idx = _videos.indexWhere((v) => v.id == videoId);
    if (idx != -1) {
      _videos[idx] = _videos[idx].copyWith(
        lastViewedAt: DateTime.now(),
        viewCount: _videos[idx].viewCount + 1,
      );
      notifyListeners();
    }
  }

  void toggleDownload(String videoId) {
    final idx = _videos.indexWhere((v) => v.id == videoId);
    if (idx != -1) {
      final current = _videos[idx];
      _videos[idx] = current.copyWith(isDownloaded: !current.isDownloaded);
      notifyListeners();
    }
  }

  // ─── Albums State ─────────────────────────────────────────────────────────
  List<AlbumModel> _albums = [];

  List<AlbumModel> get albums =>
      _albums.where((a) => a.ownerId == _currentUser?.id).toList();

  void addAlbum(AlbumModel album) {
    _albums.insert(0, album);
    _currentUser = _currentUser?.copyWith(
      albumsCount: (_currentUser?.albumsCount ?? 0) + 1,
    );
    notifyListeners();
  }

  void updateAlbum(AlbumModel updated) {
    final idx = _albums.indexWhere((a) => a.id == updated.id);
    if (idx != -1) {
      _albums[idx] = updated;
      notifyListeners();
    }
  }

  void deleteAlbum(String albumId) {
    _albums.removeWhere((a) => a.id == albumId);
    _currentUser = _currentUser?.copyWith(
      albumsCount: ((_currentUser?.albumsCount ?? 1) - 1).clamp(0, 9999),
    );
    notifyListeners();
  }

  void addVideoToAlbum(String albumId, String videoId) {
    final idx = _albums.indexWhere((a) => a.id == albumId);
    if (idx != -1) {
      final album = _albums[idx];
      if (!album.videoIds.contains(videoId)) {
        _albums[idx] =
            album.copyWith(videoIds: [...album.videoIds, videoId]);
        notifyListeners();
      }
    }
  }

  void removeVideoFromAlbum(String albumId, String videoId) {
    final idx = _albums.indexWhere((a) => a.id == albumId);
    if (idx != -1) {
      final album = _albums[idx];
      _albums[idx] = album.copyWith(
        videoIds: album.videoIds.where((id) => id != videoId).toList(),
      );
      notifyListeners();
    }
  }

  List<VideoModel> getAlbumVideos(AlbumModel album) {
    return _videos
        .where((v) => album.videoIds.contains(v.id))
        .toList();
  }

  // ─── Sessions State ───────────────────────────────────────────────────────
  List<SessionModel> _sessions = [];
  SessionModel? _activeSession;

  List<SessionModel> get sessions =>
      _sessions.where((s) => s.userId == _currentUser?.id).toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));

  SessionModel? get activeSession => _activeSession;
  bool get hasActiveSession => _activeSession != null;

  void startSession() {
    if (_activeSession != null) return;
    _activeSession = SessionModel(
      id: _uuid.v4(),
      userId: _currentUser?.id ?? '',
      startTime: DateTime.now(),
      isActive: true,
    );
    notifyListeners();
  }

  void endSession({String? notes}) {
    if (_activeSession == null) return;
    final ended = _activeSession!.copyWith(
      endTime: DateTime.now(),
      isActive: false,
      notes: notes,
      totalMinutes: DateTime.now()
          .difference(_activeSession!.startTime)
          .inMinutes,
    );
    _sessions.insert(0, ended);
    _activeSession = null;

    // Update total session time
    final added = ended.totalMinutes;
    _currentUser = _currentUser?.copyWith(
      totalSessionMinutes:
          (_currentUser?.totalSessionMinutes ?? 0) + added,
    );
    notifyListeners();
  }

  // ─── Share Requests ───────────────────────────────────────────────────────
  List<ShareRequestModel> _shareRequests = [];

  List<ShareRequestModel> get myShareRequests =>
      _shareRequests
          .where((r) => r.requesterId == _currentUser?.id)
          .toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

  List<ShareRequestModel> get pendingRequests =>
      _shareRequests.where((r) => r.isPending).toList();

  List<ShareRequestModel> get approvedSharedVideos =>
      _shareRequests.where((r) => r.isApproved).toList();

  List<ShareRequestModel> get allShareRequests =>
      _shareRequests.toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

  void submitShareRequest(VideoModel video, String message) {
    final req = ShareRequestModel(
      id: _uuid.v4(),
      videoId: video.id,
      videoTitle: video.title,
      videoThumbnail: video.thumbnailUrl,
      requesterId: _currentUser?.id ?? '',
      requesterName: _currentUser?.fullName ?? '',
      message: message,
      requestedAt: DateTime.now(),
    );
    _shareRequests.insert(0, req);
    updateVideo(video.copyWith(isShared: true));
    notifyListeners();
  }

  void approveShareRequest(String requestId, String? note) {
    final idx = _shareRequests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      _shareRequests[idx] = _shareRequests[idx].copyWith(
        status: ShareStatus.approved,
        reviewedAt: DateTime.now(),
        reviewerNote: note,
      );
      // Mark video as approved and publicly visible
      final videoId = _shareRequests[idx].videoId;
      final vIdx = _videos.indexWhere((v) => v.id == videoId);
      if (vIdx != -1) {
        _videos[vIdx] = _videos[vIdx].copyWith(
          shareApproved: true,
          isPublic: true,
        );
      }
      // Notify the requester
      final req = _shareRequests[idx];
      _notifications.insert(0, AppNotification(
        id: 'approved_${requestId}',
        type: NotificationType.share,
        title: 'Post Approved! ✅',
        body: '"${req.videoTitle}" is now live in the community.${note != null && note.isNotEmpty ? ' Admin note: $note' : ''}',
        time: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  void rejectShareRequest(String requestId, String? note) {
    final idx = _shareRequests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      _shareRequests[idx] = _shareRequests[idx].copyWith(
        status: ShareStatus.rejected,
        reviewedAt: DateTime.now(),
        reviewerNote: note,
      );
      // Notify the requester
      final req = _shareRequests[idx];
      _notifications.insert(0, AppNotification(
        id: 'rejected_${requestId}',
        type: NotificationType.share,
        title: 'Post Not Approved',
        body: '"${req.videoTitle}" was not approved for community sharing.${note != null && note.isNotEmpty ? ' Reason: $note' : ''}',
        time: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  // ─── Downloads State ──────────────────────────────────────────────────────
  List<DownloadItem> _downloadItems = [];

  List<DownloadItem> get downloadItems => _downloadItems;
  List<DownloadItem> get downloadedItems =>
      _downloadItems.where((d) => d.isDownloaded).toList();

  void toggleDownloadItem(String itemId) {
    final idx = _downloadItems.indexWhere((d) => d.id == itemId);
    if (idx != -1) {
      final current = _downloadItems[idx];
      _downloadItems[idx] = current.copyWith(
        isDownloaded: !current.isDownloaded,
        downloadedAt: !current.isDownloaded ? DateTime.now() : null,
      );
      final delta = _downloadItems[idx].isDownloaded ? 1 : -1;
      _currentUser = _currentUser?.copyWith(
        downloadCount:
            ((_currentUser?.downloadCount ?? 0) + delta).clamp(0, 9999),
      );
      notifyListeners();
    }
  }

  // ─── Dashboard Stats ──────────────────────────────────────────────────────
  int get totalVideos =>
      _videos.where((v) => v.ownerId == _currentUser?.id).length;
  int get totalAlbums =>
      _albums.where((a) => a.ownerId == _currentUser?.id).length;
  int get totalDownloads =>
      _downloadItems.where((d) => d.isDownloaded).length;
  int get totalSessionMinutes =>
      _sessions.fold(0, (sum, s) => sum + s.totalMinutes);
  double get totalStudyHours => totalSessionMinutes / 60.0;

  List<double> get weeklyMinutes {
    final data = List<double>.filled(7, 0);
    final now = DateTime.now();
    for (final s in sessions) {
      final diff = now.difference(s.startTime).inDays;
      if (diff < 7) {
        data[6 - diff] += s.totalMinutes.toDouble();
      }
    }
    return data;
  }

  // ─── Auth Actions ─────────────────────────────────────────────────────────

  /// Call once at app start to restore a saved session.
  Future<void> tryAutoLogin() async {
    final user = await DatabaseService.getSessionUser();
    if (user != null) {
      _currentUser = user;
      _authState = AuthState.authenticated;
      _loadMockData();
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _authState = AuthState.loading;
    _authError = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    if (email.trim().isEmpty || password.isEmpty) {
      _authError = 'Please fill in all fields.';
      _authState = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }

    if (!email.contains('@')) {
      _authError = 'Please enter a valid email address.';
      _authState = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }

    final user = await DatabaseService.authenticate(email, password);
    if (user == null) {
      _authError = 'Incorrect email or password.';
      _authState = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }

    _currentUser = user;
    _authState = AuthState.authenticated;
    await DatabaseService.saveSession(user.id);
    _loadMockData();
    notifyListeners();
    return true;
  }

  Future<bool> signUp(String name, String email, String password) async {
    _authState = AuthState.loading;
    _authError = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      _authError = 'Please fill in all fields.';
      _authState = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }

    if (!email.contains('@')) {
      _authError = 'Please enter a valid email address.';
      _authState = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _authError = 'Password must be at least 6 characters.';
      _authState = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }

    try {
      final user = await DatabaseService.createUser(
        id: _uuid.v4(),
        fullName: name.trim(),
        email: email.trim(),
        password: password,
        role: UserRole.student,
      );
      _currentUser = user;
      _authState = AuthState.authenticated;
      await DatabaseService.saveSession(user.id);
      _loadMockData();
      notifyListeners();
      return true;
    } catch (e) {
      _authError = e.toString().replaceFirst('Exception: ', '');
      _authState = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final user = await DatabaseService.getUserByEmail(email);
    return user != null;
  }

  Future<void> logout() async {
    await DatabaseService.clearSession();
    _currentUser = null;
    _authState = AuthState.unauthenticated;
    _videos = [];
    _albums = [];
    _sessions = [];
    _shareRequests = [];
    _downloadItems = [];
    _activeSession = null;
    _notifications = [];
    _news = [];
    _allUsers = [];
    _videoSearchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  // ─── Load Mock Data ───────────────────────────────────────────────────────
  void _loadMockData() {
    _videos = VideoModel.mockVideos;
    _albums = AlbumModel.mockAlbums;
    _sessions = SessionModel.mockSessions;
    _shareRequests = ShareRequestModel.mockRequests;
    _downloadItems = DownloadItem.mockItems;
    _notifications = AppNotification.mockNotifications;
    _news = NewsModel.mockNews;
    // Seed unread announcement notifications for every published mock news post
    for (final news in _news.where((n) => n.isPublished)) {
      _notifications.insert(
        0,
        AppNotification(
          id: 'news_notif_${news.id}',
          type: NotificationType.announcement,
          title: news.title,
          body: news.content.length > 90
              ? '${news.content.substring(0, 90)}…'
              : news.content,
          time: news.createdAt,
        ),
      );
    }
  }

  // ─── News (Admin manages, all users read) ───────────────────────────────
  List<NewsModel> _news = [];

  /// Published news visible to all users (newest first).
  List<NewsModel> get newsFeed =>
      _news.where((n) => n.isPublished).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// All news including drafts – admin only.
  List<NewsModel> get adminNewsFeed =>
      _news.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  void adminAddNews(NewsModel news) {
    _news.insert(0, news);
    if (news.isPublished) _pushNewsNotification(news);
    notifyListeners();
  }

  void adminUpdateNews(NewsModel updated) {
    final idx = _news.indexWhere((n) => n.id == updated.id);
    if (idx != -1) {
      _news[idx] = updated;
      notifyListeners();
    }
  }

  void adminDeleteNews(String id) {
    _news.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void adminTogglePublish(String id) {
    final idx = _news.indexWhere((n) => n.id == id);
    if (idx != -1) {
      final wasPublished = _news[idx].isPublished;
      _news[idx] = _news[idx].copyWith(
        isPublished: !wasPublished,
        updatedAt: DateTime.now(),
      );
      // Only push a notification when moving draft → published
      if (!wasPublished) _pushNewsNotification(_news[idx]);
      notifyListeners();
    }
  }

  /// Creates an announcement notification from a published news post.
  void _pushNewsNotification(NewsModel news) {
    final snippet = news.content.length > 90
        ? '${news.content.substring(0, 90)}…'
        : news.content;
    _notifications.insert(
      0,
      AppNotification(
        id: 'news_notif_${news.id}',
        type: NotificationType.announcement,
        title: news.title,
        body: snippet,
        time: DateTime.now(),
      ),
    );
  }

  // ─── Admin: All Users ─────────────────────────────────────────────────────
  List<UserModel> _allUsers = [];

  List<UserModel> get allUsers => _allUsers;

  Future<void> loadAllUsers() async {
    _allUsers = await DatabaseService.getAllUsers();
    notifyListeners();
  }

  void adminUpdateUserRole(String userId, UserRole role) {
    final idx = _allUsers.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      _allUsers[idx] = UserModel(
        id: _allUsers[idx].id,
        fullName: _allUsers[idx].fullName,
        email: _allUsers[idx].email,
        role: role,
        joinedAt: _allUsers[idx].joinedAt,
        videosCount: _allUsers[idx].videosCount,
        albumsCount: _allUsers[idx].albumsCount,
        downloadCount: _allUsers[idx].downloadCount,
        totalSessionMinutes: _allUsers[idx].totalSessionMinutes,
      );
      notifyListeners();
    }
  }

  // ─── Notifications ────────────────────────────────────────────────────────
  List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markNotificationRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsRead() {
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// Admin sends a custom notification to a specific student.
  void adminSendNotificationToUser(String userName, String title, String body) {
    _notifications.insert(
      0,
      AppNotification(
        id: 'admin_user_${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.system,
        title: title,
        body: body,
        time: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// Admin broadcasts a notification to all students.
  void adminBroadcastNotification(String title, String body) {
    _notifications.insert(
      0,
      AppNotification(
        id: 'broadcast_${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.announcement,
        title: title,
        body: body,
        time: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  // ─── History ──────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get historyItems {
    final items = <Map<String, dynamic>>[];

    // Add video views
    for (final v in _videos.where((v) => v.lastViewedAt != null)) {
      items.add({
        'type': 'view',
        'title': 'Watched: ${v.title}',
        'subtitle': v.category.displayName,
        'time': v.lastViewedAt!,
        'icon': 'play',
      });
    }

    // Add downloads
    for (final d in _downloadItems.where((d) => d.isDownloaded)) {
      items.add({
        'type': 'download',
        'title': 'Downloaded: ${d.title}',
        'subtitle': d.category,
        'time': d.downloadedAt ?? DateTime.now(),
        'icon': 'download',
      });
    }

    // Add sessions
    for (final s in sessions) {
      items.add({
        'type': 'session',
        'title': 'Study Session – ${s.durationLabel}',
        'subtitle': '${s.videoIdsWatched.length} video(s) watched',
        'time': s.startTime,
        'icon': 'session',
      });
    }

    items.sort((a, b) =>
        (b['time'] as DateTime).compareTo(a['time'] as DateTime));
    return items;
  }
}
