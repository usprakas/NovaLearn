import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shows a simple arithmetic challenge a young child can't easily pass but an adult can in a few
/// seconds — the standard "parent gate" pattern used across kids' apps to keep settings, account
/// deletion, and progress/spend-adjacent screens out of a child's casual reach without requiring
/// a real second login. Returns true only if the child/parent answers correctly; false/null
/// (dismissed) otherwise. Call this before navigating to any parent-only screen.
Future<bool> showParentGate(BuildContext context) async {
  final math.Random random = math.Random();
  final int a = 10 + random.nextInt(40);
  final int b = 10 + random.nextInt(40);
  final bool? result = await showDialog<bool>(
      context: context, builder: (_) => _ParentGateDialog(a: a, b: b));
  return result ?? false;
}

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
