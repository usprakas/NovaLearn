class AuthSession {
  const AuthSession({required this.accessToken, required this.refreshToken, required this.email});
  final String accessToken;
  final String refreshToken;
  final String email;
}

abstract interface class AuthRepository {
  Future<AuthSession> login(String email, String password);
  Future<AuthSession> register(String email, String password);
  Future<AuthSession> refresh(String refreshToken);
  Future<void> logout(String refreshToken);
}
