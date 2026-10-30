import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novalearn_mobile/core/network/novalearn_api.dart';
import 'package:novalearn_mobile/core/security/session_store.dart';
import 'package:novalearn_mobile/features/auth/application/session_controller.dart';
import 'package:novalearn_mobile/features/auth/domain/auth_repository.dart';

const Session _saved = Session(accessToken: 'expired-access', refreshToken: 'saved-refresh', email: 'p@example.com');

class _MemoryStore extends SessionStore {
  _MemoryStore(this.session, {this.readFails = false});
  Session? session;
  final bool readFails;
  bool cleared = false;

  @override
  Future<Session?> read() async {
    if (readFails) throw StateError('OperationError: could not decrypt');
    return session;
  }

  @override
  Future<void> save(Session s) async => session = s;

  @override
  Future<void> clear() async {
    cleared = true;
    session = null;
  }
}

class _Auth implements AuthRepository {
  _Auth(this.onRefresh);
  final Future<AuthSession> Function(String refreshToken) onRefresh;
  int refreshCalls = 0;

  @override
  Future<AuthSession> refresh(String refreshToken) {
    refreshCalls++;
    return onRefresh(refreshToken);
  }

  @override
  Future<AuthSession> login(String email, String password) => throw UnimplementedError();
  @override
  Future<AuthSession> register(String email, String password) => throw UnimplementedError();
  @override
  Future<void> logout(String refreshToken) async {}
  @override
  Future<void> deleteAccount(String accessToken, String password) async {}
}

Future<Session?> _restored(_Auth auth, _MemoryStore store) async {
  final SessionController controller = SessionController(auth, store);
  for (int i = 0; i < 20 && controller.state is AsyncLoading; i++) {
    await Future<void>.delayed(Duration.zero);
  }
  expect(controller.state, isA<AsyncData<Session?>>());
  return controller.state.value;
}

void main() {
  test('swaps a saved session for a fresh one on startup', () async {
    final _MemoryStore store = _MemoryStore(_saved);
    final _Auth auth = _Auth((String token) async {
      expect(token, 'saved-refresh');
      return const AuthSession(accessToken: 'new-access', refreshToken: 'new-refresh', email: 'p@example.com');
    });

    final Session? session = await _restored(auth, store);

    expect(session?.accessToken, 'new-access');
    expect(store.session?.refreshToken, 'new-refresh');
  });

  test('a rejected refresh token signs out instead of retrying a dead session', () async {
    final _MemoryStore store = _MemoryStore(_saved);
    final _Auth auth = _Auth((_) async =>
        throw const ApiException(statusCode: 401, message: 'Your session has expired.'));

    expect(await _restored(auth, store), isNull);
    expect(store.cleared, isTrue);
  });

  test('keeps the saved session when the server cannot be reached', () async {
    final _MemoryStore store = _MemoryStore(_saved);
    final _Auth auth = _Auth((_) async => throw Exception('connection refused'));

    expect((await _restored(auth, store))?.accessToken, 'expired-access');
    expect(store.cleared, isFalse);
  });

  test('an unreadable saved session falls back to signed out rather than hanging', () async {
    final _MemoryStore store = _MemoryStore(_saved, readFails: true);
    final _Auth auth = _Auth((_) async => throw StateError('should not be called'));

    expect(await _restored(auth, store), isNull);
    expect(auth.refreshCalls, 0);
  });

  test('no saved session means no refresh call', () async {
    final _Auth auth = _Auth((_) async => throw StateError('should not be called'));

    expect(await _restored(auth, _MemoryStore(null)), isNull);
    expect(auth.refreshCalls, 0);
  });
}
