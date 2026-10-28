import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/novalearn_api.dart';
import '../../../core/security/session_store.dart';
import '../application/session_controller.dart';

/// Where account-level actions live — today just sign-out and permanent account deletion.
/// Deleting the account signs the parent out automatically: SessionController clears the local
/// session on success, which AuthScreen/HomeScreen already route on via sessionControllerProvider,
/// so this screen doesn't need to navigate anywhere itself.
class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key, required this.session});
  final Session session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          Card(
              child: ListTile(
                  leading: const Icon(Icons.mail_outline),
                  title: const Text('Signed in as'),
                  subtitle: Text(session.email))),
          const SizedBox(height: 12),
          Card(
              child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sign out'),
                  onTap: () => ref.read(sessionControllerProvider.notifier).signOut())),
          const SizedBox(height: 32),
          Text('Danger zone',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: scheme.error, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Card(
              color: scheme.errorContainer.withValues(alpha: 0.35),
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('Delete account',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        const Text(
                            "Permanently deletes your account and every child profile, their "
                            "lesson progress, and rewards. This can't be undone."),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                                foregroundColor: scheme.error,
                                side: BorderSide(color: scheme.error)),
                            icon: const Icon(Icons.delete_forever_outlined),
                            label: const Text('Delete account'),
                            onPressed: () => _confirmDelete(context, ref)),
                      ]))),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
        context: context, builder: (_) => _DeleteAccountDialog(ref: ref));
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.ref});
  final WidgetRef ref;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final TextEditingController _password = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _password.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() => setState(() {});

  @override
  void dispose() {
    _password.removeListener(_onPasswordChanged);
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_password.text.isEmpty) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.ref.read(sessionControllerProvider.notifier).deleteAccount(_password.text);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Unable to reach NovaLearn. Check your connection and try again.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: const Text('Confirm password'),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Enter your password to permanently delete your account.'),
            const SizedBox(height: 16),
            TextField(
                controller: _password,
                obscureText: true,
                autofocus: true,
                onSubmitted: (_) => _submit(),
                decoration: const InputDecoration(labelText: 'Password')),
            if (_error != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ]),
      actions: <Widget>[
        TextButton(
            onPressed: _submitting ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: _submitting || _password.text.isEmpty ? null : _submit,
            child: _submitting
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text('Delete')),
      ]);
}
