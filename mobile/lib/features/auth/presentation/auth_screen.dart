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

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
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
