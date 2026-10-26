import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStore {
  SessionStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _tokenKey = 'novalearn.access-token';
  static const String _parentEmailKey = 'novalearn.parent-email';
  final FlutterSecureStorage _storage;

  Future<Session?> read() async {
    final String? token = await _storage.read(key: _tokenKey);
    final String? email = await _storage.read(key: _parentEmailKey);
    if (token == null || email == null) return null;
    return Session(accessToken: token, email: email);
  }

  Future<void> save(Session session) async {
    await _storage.write(key: _tokenKey, value: session.accessToken);
    await _storage.write(key: _parentEmailKey, value: session.email);
  }

  Future<void> clear() => _storage.deleteAll();
}

class Session {
  const Session({required this.accessToken, required this.email});
  final String accessToken;
  final String email;
}
