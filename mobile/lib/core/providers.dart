import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'network/novalearn_api.dart';
import 'security/session_store.dart';

/// Single shared API client — every repository interface it implements is resolved through
/// this one provider, so screens depend on the *interface* they need (e.g. `ref.watch(
/// novaLearnApiProvider)` typed as `TutorRepository`) without constructing their own client.
final novaLearnApiProvider = Provider<NovaLearnApi>((ref) => NovaLearnApi());

final sessionStoreProvider = Provider<SessionStore>((ref) => SessionStore());
