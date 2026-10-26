import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStore {
  SessionStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _accessTokenKey = 'novalearn.access-token';
  static const String _refreshTokenKey = 'novalearn.refresh-token';
  static const String _parentEmailKey = 'novalearn.parent-email';
  final FlutterSecureStorage _storage;

  Future<Session?> read() async {
    final String? accessToken = await _storage.read(key: _accessTokenKey);
    final String? refreshToken = await _storage.read(key: _refreshTokenKey);
    final String? email = await _storage.read(key: _parentEmailKey);
    if (accessToken == null || refreshToken == null || email == null) return null;
    return Session(accessToken: accessToken, refreshToken: refreshToken, email: email);
  }

  Future<void> save(Session session) async {
    await _storage.write(key: _accessTokenKey, value: session.accessToken);
    await _storage.write(key: _refreshTokenKey, value: session.refreshToken);
    await _storage.write(key: _parentEmailKey, value: session.email);
  }

  Future<void> clear() => _storage.deleteAll();
}

class Session {
  const Session({required this.accessToken, required this.refreshToken, required this.email});
  final String accessToken;
  final String refreshToken;
  final String email;
}
