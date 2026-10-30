import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/novalearn_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/nova_star.dart';
import '../application/session_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _registering = false;
  bool _submitting = false;
  bool _demoLoading = false;
  bool _showWakingHint = false;
  Timer? _wakingHintTimer;

  // A real, persistent account on the live backend, seeded with two sample children and some
  // actual progress — not a client-side mock. Credentials are intentionally public: this is a
  // demo account, meant to be explored by anyone without signing up.
  static const String _demoEmail = 'demo@novalearn.app';
  static const String _demoPassword = 'NovaLearnDemo2026!';

  /// The free-tier backend (and its free-tier database) can both go idle and take anywhere from
  /// a few seconds to over a minute to wake back up on the first request after a quiet period —
  /// a real, observed characteristic of this deployment, not a bug. Without this, that wait is a
  /// silent spinner indistinguishable from the app being broken.
  void _startWakingHintTimer() {
    _wakingHintTimer?.cancel();
    _wakingHintTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showWakingHint = true);
    });
  }

  void _stopWakingHintTimer() {
    _wakingHintTimer?.cancel();
    if (_showWakingHint) setState(() => _showWakingHint = false);
  }

  Future<void> _loginDemo() async {
    setState(() => _demoLoading = true);
    _startWakingHintTimer();
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .login(_demoEmail, _demoPassword);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "Couldn't reach the demo account. Check your connection and try again.")));
      }
    } finally {
      _stopWakingHintTimer();
      if (mounted) setState(() => _demoLoading = false);
    }
  }

  @override
  void dispose() {
    _wakingHintTimer?.cancel();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    _startWakingHintTimer();
    try {
      final SessionController controller = ref.read(sessionControllerProvider.notifier);
      if (_registering) {
        await controller.register(_email.text, _password.text);
      } else {
        await controller.login(_email.text, _password.text);
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Unable to reach NovaLearn. Check your connection and try again.')));
      }
    } finally {
      _stopWakingHintTimer();
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[AppTheme.deepSpace, Color(0xff3b2a6b), AppTheme.cosmicViolet],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      NovaStarField(
                        starCount: 7,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          child: Column(
                            children: <Widget>[
                              _NovaBadge(),
                              const SizedBox(height: 18),
                              Text('NovaLearn',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(color: Colors.white)),
                              const SizedBox(height: 6),
                              Text('Learning that launches curiosity.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        color: scheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                          child: Form(
                              key: _formKey,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(
                                        _registering
                                            ? 'Create your parent account'
                                            : 'Welcome back, parent!',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.titleLarge),
                                    const SizedBox(height: 4),
                                    Text(
                                        _registering
                                            ? "Just takes a minute — you'll add your child next."
                                            : "Let's pick up where your learner left off.",
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: scheme.onSurfaceVariant)),
                                    const SizedBox(height: 28),
                                    TextFormField(
                                        controller: _email,
                                        keyboardType: TextInputType.emailAddress,
                                        decoration: const InputDecoration(
                                            labelText: 'Email',
                                            prefixIcon: Icon(Icons.mail_outline_rounded)),
                                        validator: (String? value) =>
                                            value != null && value.contains('@')
                                                ? null
                                                : 'Enter a valid email'),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                        controller: _password,
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                            labelText: 'Password',
                                            prefixIcon: Icon(Icons.lock_outline_rounded)),
                                        validator: (String? value) =>
                                            value != null && value.length >= 12
                                                ? null
                                                : 'Use at least 12 characters'),
                                    const SizedBox(height: 28),
                                    FilledButton(
                                        onPressed: _submitting ? null : _submit,
                                        child: _submitting
                                            ? const SizedBox.square(
                                                dimension: 20,
                                                child: CircularProgressIndicator(
                                                    color: Colors.white, strokeWidth: 2.5))
                                            : Text(_registering
                                                ? 'Create account'
                                                : 'Sign in')),
                                    const SizedBox(height: 4),
                                    TextButton(
                                        onPressed: _submitting
                                            ? null
                                            : () => setState(
                                                () => _registering = !_registering),
                                        child: Text(_registering
                                            ? 'Already have an account? Sign in'
                                            : 'New to NovaLearn? Create an account')),
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      child: _showWakingHint
                                          ? Padding(
                                              key: const ValueKey<String>('waking-hint'),
                                              padding: const EdgeInsets.only(top: 12),
                                              child: Row(children: <Widget>[
                                                SizedBox(
                                                    width: 14,
                                                    height: 14,
                                                    child: CircularProgressIndicator(
                                                        strokeWidth: 2, color: scheme.primary)),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                    child: Text(
                                                        "Still connecting — the server may be waking up, this can take up to a minute.",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(color: scheme.onSurfaceVariant))),
                                              ]))
                                          : const SizedBox.shrink(key: ValueKey<String>('no-hint')),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(children: <Widget>[
                                      Expanded(child: Divider(color: scheme.outlineVariant)),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: Text('or',
                                              style: TextStyle(color: scheme.onSurfaceVariant))),
                                      Expanded(child: Divider(color: scheme.outlineVariant)),
                                    ]),
                                    const SizedBox(height: 16),
                                    OutlinedButton.icon(
                                        onPressed: _submitting || _demoLoading ? null : _loginDemo,
                                        icon: _demoLoading
                                            ? const SizedBox.square(
                                                dimension: 18,
                                                child: CircularProgressIndicator(strokeWidth: 2.5))
                                            : const Icon(Icons.play_circle_outline_rounded),
                                        label: const Text('Try the demo — no sign-up needed')),
                                  ])),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The app's badge: a NovaStar sparkle inside a glowing ring, instead of a stock Material icon in
/// a flat circle — the one moment a visitor forms their first impression of "NovaLearn" as a
/// name, not just a login form.
class _NovaBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: <Color>[AppTheme.novaOrange, AppTheme.cosmicViolet],
          radius: 0.85,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: AppTheme.novaOrange.withValues(alpha: 0.45),
              blurRadius: 28,
              spreadRadius: 2),
        ],
      ),
      child: const Center(child: NovaStar(size: 42, color: Colors.white)));
}
