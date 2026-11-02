import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shows a simple arithmetic challenge a young child can't easily pass but an adult can in a few
/// seconds — the standard "parent gate" pattern used across kids' apps to keep settings, account
/// deletion, and progress/spend-adjacent screens out of a child's casual reach without requiring
/// a real second login. Returns true only if the child/parent answers correctly; false/null
/// (dismissed) otherwise. Call this before navigating to any parent-only screen.
///
/// A correct answer unlocks the gate for [parentGateUnlockDuration], so a parent checking the
/// dashboard and then settings isn't re-solving a sum each time — short enough that a child who
/// picks the device up afterwards still meets the gate. Signing out locks it again.
Future<bool> showParentGate(BuildContext context) async {
  final DateTime? unlockedUntil = _unlockedUntil;
  if (unlockedUntil != null && parentGateClock().isBefore(unlockedUntil)) return true;
  final math.Random random = math.Random();
  final int a = 10 + random.nextInt(40);
  final int b = 10 + random.nextInt(40);
  final bool? result = await showDialog<bool>(
      context: context, builder: (_) => _ParentGateDialog(a: a, b: b));
  final bool passed = result ?? false;
  if (passed) _unlockedUntil = parentGateClock().add(parentGateUnlockDuration);
  return passed;
}

const Duration parentGateUnlockDuration = Duration(minutes: 10);
DateTime? _unlockedUntil;

@visibleForTesting
DateTime Function() parentGateClock = DateTime.now;

/// Requires the challenge again on the next gated screen (e.g. after signing out).
void lockParentGate() => _unlockedUntil = null;

class _ParentGateDialog extends StatefulWidget {
  const _ParentGateDialog({required this.a, required this.b});
  final int a;
  final int b;

  @override
  State<_ParentGateDialog> createState() => _ParentGateDialogState();
}

class _ParentGateDialogState extends State<_ParentGateDialog> {
  final TextEditingController _answer = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  void _submit() {
    final int? given = int.tryParse(_answer.text.trim());
    if (given == widget.a + widget.b) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = 'Not quite — try again.');
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
      icon: const Icon(Icons.shield_outlined, size: 32),
      title: const Text('Just for grown-ups'),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Solve this to continue:'),
            const SizedBox(height: 16),
            Text('${widget.a} + ${widget.b} = ?',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(
                controller: _answer,
                autofocus: true,
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _submit(),
                decoration: const InputDecoration(labelText: 'Answer')),
            if (_error != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ]),
      actions: <Widget>[
        TextButton(
            onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Continue')),
      ]);
}
