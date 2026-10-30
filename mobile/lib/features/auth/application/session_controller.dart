import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/novalearn_api.dart';
import '../../../core/providers.dart';
import '../../../core/security/session_store.dart';
import '../domain/auth_repository.dart';

/// Owns the current session: restoring it on startup, logging in/registering, and signing out.
/// Replaces the hand-rolled `_SessionGateState` that used to thread `Session`/`NovaLearnApi`
/// through every screen's constructor — see docs/ADR/0003-state-management.md.
class SessionController extends StateNotifier<AsyncValue<Session?>> {
  SessionController(this._auth, this._store) : super(const AsyncValue.loading()) {
    _restore();
  }

  final AuthRepository _auth;
  final SessionStore _store;

  /// Restores a saved session and immediately swaps it for a fresh one. The saved access token is
  /// usually expired by the time someone comes back (1h TTL), while the refresh token lasts 30
  /// days — so refreshing up front keeps a returning parent signed in instead of every request
  /// failing on a dead token. A rejected refresh token means the session really is over: clear
  /// it and show sign-in. A network failure or timeout keeps the saved session (any request that
  /// then gets a 401 signs out via `NovaLearnApi.onUnauthorized`). Never leaves the app stuck
  /// loading, even if the stored data itself can't be read.
  Future<void> _restore() async {
    final Session? stored;
    try {
      stored = await _store.read();
    } catch (_) {
      await _clearQuietly();
      state = const AsyncValue.data(null);
      return;
    }
    if (stored == null) {
      state = const AsyncValue.data(null);
      return;
    }
    try {
      final AuthSession fresh =
          await _auth.refresh(stored.refreshToken).timeout(const Duration(seconds: 20));
      final Session session =
          Session(accessToken: fresh.accessToken, refreshToken: fresh.refreshToken, email: fresh.email);
      await _store.save(session);
      state = AsyncValue.data(session);
    } on ApiException catch (error) {
      if (error.statusCode >= 400 && error.statusCode < 500 && error.statusCode != 429) {
        await _clearQuietly();
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.data(stored);
      }
    } catch (_) {
      state = AsyncValue.data(stored);
    }
  }

  Future<void> _clearQuietly() async {
    try {
      await _store.clear();
    } catch (_) {
      // Nothing more to do — an unreadable store is treated as signed out either way.
    }
  }

  Future<void> login(String email, String password) => _authenticate(() => _auth.login(email, password));

  Future<void> register(String email, String password) => _authenticate(() => _auth.register(email, password));

  Future<void> _authenticate(Future<AuthSession> Function() action) async {
    final AuthSession result = await action();
    final Session session =
        Session(accessToken: result.accessToken, refreshToken: result.refreshToken, email: result.email);
    await _store.save(session);
    state = AsyncValue.data(session);
  }

  Future<void> signOut() async {
    final Session? current = state.value;
    if (current != null) {
      try {
        await _auth.logout(current.refreshToken);
      } catch (_) {
        // Best-effort: the refresh token simply expires on its own if this call fails.
      }
    }
    await _store.clear();
    state = const AsyncValue.data(null);
  }

  /// Permanently deletes the account server-side (re-confirming the password), then signs out
  /// locally. Lets the server's exception (e.g. a wrong password) propagate to the caller so the
  /// screen can show it, rather than silently clearing the local session on failure.
  Future<void> deleteAccount(String password) async {
    final Session? current = state.value;
    if (current == null) return;
    await _auth.deleteAccount(current.accessToken, password);
    await _store.clear();
    state = const AsyncValue.data(null);
  }
}

final StateNotifierProvider<SessionController, AsyncValue<Session?>> sessionControllerProvider =
    StateNotifierProvider<SessionController, AsyncValue<Session?>>(
  (ref) => SessionController(ref.watch(novaLearnApiProvider), ref.watch(sessionStoreProvider)),
);
