import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/novalearn_api.dart';
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
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
                    child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Icon(Icons.auto_awesome,
                            size: 64, color: Color(0xff6246ea)),
                        const SizedBox(height: 16),
                        Text('NovaLearn',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displaySmall),
                        const SizedBox(height: 8),
                        Text(
                            _registering
                                ? 'Create your parent account'
                                : 'Welcome back, parent!',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 32),
                        TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration:
                                const InputDecoration(labelText: 'Email'),
                            validator: (String? value) =>
                                value != null && value.contains('@')
                                    ? null
                                    : 'Enter a valid email'),
                        const SizedBox(height: 16),
                        TextFormField(
                            controller: _password,
                            obscureText: true,
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            validator: (String? value) =>
                                value != null && value.length >= 12
                                    ? null
                                    : 'Use at least 12 characters'),
                        const SizedBox(height: 24),
                        FilledButton(
                            onPressed: _submitting ? null : _submit,
                            child: _submitting
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator())
                                : Text(_registering
                                    ? 'Create account'
                                    : 'Sign in')),
                        TextButton(
                            onPressed: _submitting
                                ? null
                                : () => setState(
                                    () => _registering = !_registering),
                            child: Text(_registering
                                ? 'Already have an account? Sign in'
                                : 'New to NovaLearn? Create an account')),
                      ]))),
        )))),
      );
}
