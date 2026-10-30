// lib/services/session.dart
//
// Persists the auth token and basic user info using SharedPreferences.
// If "remember = false" the token is kept only in memory (not on disk).

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class Session {
  Session._();
  static final Session instance = Session._();

  // In-memory fields (always set when logged in)
  String? _token;
  UserModel? _user;

  String? get token => _token;
  UserModel? get user => _user;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  // ── Persist (remember me = true) ───────────────────────────────────────────
  Future<void> save(String token, UserModel user, {bool persist = true}) async {
    _token = token;
    _user = user;
    if (persist) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userId', user.id);
      await prefs.setString('username', user.username);
      await prefs.setString('email', user.email);
      await prefs.setString('createdAt', user.createdAt.toIso8601String());
    }
  }

  // ── Load from disk on app start ────────────────────────────────────────────
  Future<bool> tryRestore() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return false;

    _token = token;
    _user = UserModel(
      id: prefs.getString('userId') ?? '',
      username: prefs.getString('username') ?? '',
      email: prefs.getString('email') ?? '',
      createdAt: DateTime.tryParse(prefs.getString('createdAt') ?? '') ??
          DateTime.now(),
    );
    return true;
  }

  // ── Update user info in memory and on disk ─────────────────────────────────
  Future<void> updateUser(UserModel user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('token')) {
      // Only update disk if we were persisting
      await prefs.setString('userId', user.id);
      await prefs.setString('username', user.username);
      await prefs.setString('email', user.email);
      await prefs.setString('createdAt', user.createdAt.toIso8601String());
    }
  }

  // ── Clear everything (logout) ──────────────────────────────────────────────
  Future<void> clear() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
