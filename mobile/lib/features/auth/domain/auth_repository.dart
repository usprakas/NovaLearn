class AuthSession {
  const AuthSession({required this.accessToken, required this.email});
  final String accessToken;
  final String email;
}

abstract interface class AuthRepository {
  Future<AuthSession> login(String email, String password);
  Future<AuthSession> register(String email, String password);
}
