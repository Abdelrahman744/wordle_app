// lib/services/api_service.dart
//
// All HTTP communication with the Wordle backend.
// Every method throws a human-readable String on failure so the UI can show it.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/game_model.dart';
import '../models/stats_model.dart';
import '../models/user_model.dart';
import 'session.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static const _timeout = Duration(seconds: 10);

  // ── Helpers ────────────────────────────────────────────────────────────────

  Map<String, String> _headers({bool auth = false}) {
    final h = {'Content-Type': 'application/json'};
    if (auth) {
      final token = Session.instance.token;
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  /// Throws a user-friendly message from the server JSON or a generic one.
  Never _throw(http.Response res) {
    try {
      final body = json.decode(res.body) as Map<String, dynamic>;
      throw body['error'] as String? ?? 'Unexpected error (${res.statusCode})';
    } catch (e) {
      if (e is String) rethrow;
      throw 'Unexpected error (${res.statusCode})';
    }
  }

  Future<http.Response> _post(String path, Map<String, dynamic> body,
      {bool auth = false}) async {
    try {
      return await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: _headers(auth: auth),
            body: json.encode(body),
          )
          .timeout(_timeout);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Cannot reach server. Make sure the backend is running and check your baseUrl in config.dart.';
    }
  }

  Future<http.Response> _get(String path, {bool auth = false}) async {
    try {
      return await http
          .get(
            Uri.parse('$baseUrl$path'),
            headers: _headers(auth: auth),
          )
          .timeout(_timeout);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Cannot reach server. Make sure the backend is running and check your baseUrl in config.dart.';
    }
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  /// Register a new account. Returns token + user.
  Future<({String token, UserModel user})> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final res = await _post('/api/auth/register', {
      'username': username,
      'email': email,
      'password': password,
    });
    if (res.statusCode == 201) {
      final body = json.decode(res.body) as Map<String, dynamic>;
      return (
        token: body['token'] as String,
        user: UserModel.fromJson(body['user'] as Map<String, dynamic>),
      );
    }
    _throw(res);
  }

  /// Sign in. Returns token + user.
  Future<({String token, UserModel user})> login({
    required String email,
    required String password,
  }) async {
    final res = await _post('/api/auth/login', {
      'email': email,
      'password': password,
    });
    if (res.statusCode == 200) {
      final body = json.decode(res.body) as Map<String, dynamic>;
      return (
        token: body['token'] as String,
        user: UserModel.fromJson(body['user'] as Map<String, dynamic>),
      );
    }
    _throw(res);
  }

  /// Verify the stored token is still valid and refresh user info.
  Future<UserModel> getMe() async {
    final res = await _get('/api/auth/me', auth: true);
    if (res.statusCode == 200) {
      final body = json.decode(res.body) as Map<String, dynamic>;
      return UserModel.fromJson(body['user'] as Map<String, dynamic>);
    }
    _throw(res);
  }

  // ── Games ─────────────────────────────────────────────────────────────────

  Future<GameModel> saveGame({
    required String word,
    required bool won,
    required int attempts,
    required String mode,
  }) async {
    final res = await _post(
      '/api/games',
      {'word': word, 'won': won, 'attempts': attempts, 'mode': mode},
      auth: true,
    );
    if (res.statusCode == 201) {
      final body = json.decode(res.body) as Map<String, dynamic>;
      return GameModel.fromJson(body['game'] as Map<String, dynamic>);
    }
    _throw(res);
  }

  Future<List<GameModel>> getGames() async {
    final res = await _get('/api/games', auth: true);
    if (res.statusCode == 200) {
      final body = json.decode(res.body) as Map<String, dynamic>;
      final list = body['games'] as List<dynamic>;
      return list
          .map((e) => GameModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    _throw(res);
  }

  Future<StatsModel> getStats() async {
    final res = await _get('/api/stats', auth: true);
    if (res.statusCode == 200) {
      return StatsModel.fromJson(
          json.decode(res.body) as Map<String, dynamic>);
    }
    _throw(res);
  }
}
