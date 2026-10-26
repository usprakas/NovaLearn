import 'package:flutter/material.dart';
import '../../children/domain/child.dart';
import '../domain/tutor_answer.dart';
import '../domain/tutor_repository.dart';

class TutorTab extends StatefulWidget {
  const TutorTab({
    super.key,
    required this.token,
    required this.child,
    required this.tutorRepository,
  });
  final String token;
  final Child child;
  final TutorRepository tutorRepository;

  @override
  State<TutorTab> createState() => _TutorTabState();
}

class _TutorTabState extends State<TutorTab> {
  final TextEditingController _questionController = TextEditingController();
  TutorAnswer? _answer;
  bool _loading = false;
  int _attempt = 0;
  String? _error;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _ask({required bool tryAnotherWay}) async {
    final String question = _questionController.text.trim();
    if (question.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      if (!tryAnotherWay) _attempt = 0;
    });
    try {
      final TutorAnswer answer = await widget.tutorRepository.ask(
          widget.token, widget.child.id, question, null, _attempt);
      if (!mounted) return;
      setState(() {
        _answer = answer;
        _attempt += 1;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'NovaLearn could not answer right now: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Text('Ask NovaLearn', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
            "${widget.child.displayName} can ask any question, and NovaLearn will explain it in a "
            "kid-friendly way. If one explanation doesn't click, ask again for a different approach."),
        const SizedBox(height: 16),
        TextField(
          controller: _questionController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g. Why is the moon following me?'),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _loading ? null : () => _ask(tryAnotherWay: false),
          icon: const Icon(Icons.send),
          label: const Text('Ask'),
        ),
        if (_answer != null) ...<Widget>[
          const SizedBox(height: 20),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(_answer!.strategy.replaceAll('_', ' '),
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
                        const SizedBox(height: 8),
                        Text(_answer!.explanation),
                      ]))),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _loading ? null : () => _ask(tryAnotherWay: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Try another way'),
          ),
        ],
        if (_error != null) ...<Widget>[
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
      ]);
}
