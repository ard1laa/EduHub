import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

// â”€â”€â”€ Internal record â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _UserRecord {
  final UserModel user;
  final String password;
  _UserRecord({required this.user, required this.password});

  Map<String, dynamic> toJson() => {'user': user.toJson(), 'password': password};
  factory _UserRecord.fromJson(Map<String, dynamic> j) =>
      _UserRecord(user: UserModel.fromJson(j['user'] as Map<String, dynamic>), password: j['password'] as String);
}

// â”€â”€â”€ Hardcoded system accounts (always available as fallback) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
final _systemAccounts = <_UserRecord>[
  _UserRecord(
    user: UserModel(
      id: 'admin_001',
      fullName: 'Dr. Sarah Chen',
      email: 'admin@eduhub.com',
      role: UserRole.admin,
      joinedAt: DateTime(2024, 1, 15),
      videosCount: 45,
      albumsCount: 12,
      downloadCount: 60,
      totalSessionMinutes: 4200,
    ),
    password: 'Admin@123',
  ),
  _UserRecord(
    user: UserModel(
      id: 'user_001',
      fullName: 'Alex Johnson',
      email: 'student@eduhub.com',
      role: UserRole.student,
      joinedAt: DateTime(2025, 9, 1),
      videosCount: 24,
      albumsCount: 6,
      downloadCount: 18,
      totalSessionMinutes: 1340,
    ),
    password: 'Student@123',
  ),
];

// â”€â”€â”€ DatabaseService â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class DatabaseService {
  static const _keyUsers = 'eduhub_users_v3';
  static const _keyCurrentUserId = 'eduhub_session_v3';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      // Ensure system accounts are always present
      final records = await _loadRecords();
      bool dirty = false;
      for (final sys in _systemAccounts) {
        final exists = records.any((r) => r.user.id == sys.user.id);
        if (!exists) {
          records.add(sys);
          dirty = true;
        }
      }
      if (dirty) await _saveRecords(records);
    } catch (e) {
      // SharedPreferences unavailable â€“ system accounts still work via fallback
    }
  }

  // â”€â”€ Auth â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Future<UserModel?> authenticate(String email, String password) async {
    final emailNorm = email.toLowerCase().trim();

    // Always check system accounts first (works even if DB fails)
    for (final r in _systemAccounts) {
      if (r.user.email.toLowerCase() == emailNorm && r.password == password) {
        return r.user;
      }
    }

    // Then check registered users in persistent storage
    try {
      final records = await _loadRecords();
      for (final r in records) {
        if (r.user.email.toLowerCase().trim() == emailNorm && r.password == password) {
          return r.user;
        }
      }
    } catch (_) {}

    return null;
  }

  static Future<UserModel> createUser({
    required String id,
    required String fullName,
    required String email,
    required String password,
    UserRole role = UserRole.student,
  }) async {
    final emailNorm = email.toLowerCase().trim();

    // Check system accounts
    if (_systemAccounts.any((r) => r.user.email.toLowerCase() == emailNorm)) {
      throw Exception('An account with this email already exists.');
    }

    final records = await _loadRecords();
    if (records.any((r) => r.user.email.toLowerCase().trim() == emailNorm)) {
      throw Exception('An account with this email already exists.');
    }

    final user = UserModel(id: id, fullName: fullName, email: email, role: role, joinedAt: DateTime.now());
    records.add(_UserRecord(user: user, password: password));
    await _saveRecords(records);
    return user;
  }

  static Future<void> updateUser(UserModel updated) async {
    try {
      final records = await _loadRecords();
      final idx = records.indexWhere((r) => r.user.id == updated.id);
      if (idx != -1) {
        records[idx] = _UserRecord(user: updated, password: records[idx].password);
        await _saveRecords(records);
      }
    } catch (_) {}
  }

  static Future<List<UserModel>> getAllUsers() async {
    try {
      final records = await _loadRecords();
      final all = _systemAccounts.map((r) => r.user).toList();
      for (final r in records) {
        if (!all.any((u) => u.id == r.user.id)) all.add(r.user);
      }
      return all;
    } catch (_) {
      return _systemAccounts.map((r) => r.user).toList();
    }
  }

  static Future<UserModel?> getUserById(String id) async {
    // Check system accounts
    try {
      return _systemAccounts.firstWhere((r) => r.user.id == id).user;
    } catch (_) {}
    try {
      final records = await _loadRecords();
      return records.firstWhere((r) => r.user.id == id).user;
    } catch (_) {
      return null;
    }
  }

  static Future<UserModel?> getUserByEmail(String email) async {
    final emailNorm = email.toLowerCase().trim();
    try {
      return _systemAccounts.firstWhere((r) => r.user.email.toLowerCase() == emailNorm).user;
    } catch (_) {}
    try {
      final records = await _loadRecords();
      return records.firstWhere((r) => r.user.email.toLowerCase().trim() == emailNorm).user;
    } catch (_) {
      return null;
    }
  }

  
  static Future<void> saveSession(String userId) async {
    try { await _prefs?.setString(_keyCurrentUserId, userId); } catch (_) {}
  }

  static Future<UserModel?> getSessionUser() async {
    try {
      final id = _prefs?.getString(_keyCurrentUserId);
      if (id == null) return null;
      return getUserById(id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearSession() async {
    try { await _prefs?.remove(_keyCurrentUserId); } catch (_) {}
  }


  static Future<List<_UserRecord>> _loadRecords() async {
    if (_prefs == null) return [];
    final raw = _prefs!.getString(_keyUsers);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => _UserRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> _saveRecords(List<_UserRecord> records) async {
    if (_prefs == null) return;
    // Never persist system accounts (they're always in memory)
    final toSave = records.where((r) => !_systemAccounts.any((s) => s.user.id == r.user.id)).toList();
    await _prefs!.setString(_keyUsers, jsonEncode(toSave.map((r) => r.toJson()).toList()));
  }

  static Future<void> resetDatabase() async {
    try {
      await _prefs?.remove(_keyUsers);
      await _prefs?.remove(_keyCurrentUserId);
    } catch (_) {}
  }
}

