import 'package:flutter/material.dart';
import 'core/network/novalearn_api.dart';
import 'core/security/session_store.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/home/presentation/home_screen.dart';

class NovaLearnApp extends StatelessWidget {
  const NovaLearnApp(
      {super.key, required this.api, required this.sessionStore});
  final NovaLearnApi api;
  final SessionStore sessionStore;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'NovaLearn',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff6246ea)),
          useMaterial3: true,
        ),
        home: _SessionGate(api: api, sessionStore: sessionStore),
      );
}

class _SessionGate extends StatefulWidget {
  const _SessionGate({required this.api, required this.sessionStore});
  final NovaLearnApi api;
  final SessionStore sessionStore;
  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  Session? _session;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final Session? session = await widget.sessionStore.read();
    if (mounted) {
      setState(() {
        _session = session;
        _loading = false;
      });
    }
  }

  Future<void> _onAuthenticated(Session session) async {
    await widget.sessionStore.save(session);
    if (mounted) setState(() => _session = session);
  }

  Future<void> _signOut() async {
    await widget.sessionStore.clear();
    if (mounted) setState(() => _session = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_session == null) {
      return AuthScreen(api: widget.api, onAuthenticated: _onAuthenticated);
    }
    return HomeScreen(api: widget.api, session: _session!, onSignOut: _signOut);
  }
}
