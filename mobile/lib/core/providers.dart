import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'network/novalearn_api.dart';
import 'security/session_store.dart';
import '../features/auth/application/session_controller.dart';

/// Single shared API client — every repository interface it implements is resolved through
/// this one provider, so screens depend on the *interface* they need (e.g. `ref.watch(
/// novaLearnApiProvider)` typed as `TutorRepository`) without constructing their own client.
///
/// `onUnauthorized` reads `sessionControllerProvider` lazily, inside the closure, rather than via
/// `ref.watch`/`ref.read` here — `sessionControllerProvider` itself depends on this provider, so
/// resolving it eagerly during this provider's own build would be circular. The closure is only
/// ever invoked later, when a real 401 happens, by which point both providers already exist.
final Provider<NovaLearnApi> novaLearnApiProvider = Provider<NovaLearnApi>((ref) => NovaLearnApi(
    onUnauthorized: () => ref.read(sessionControllerProvider.notifier).signOut()));

final sessionStoreProvider = Provider<SessionStore>((ref) => SessionStore());
