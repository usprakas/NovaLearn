import 'package:flutter/material.dart';
import '../../children/domain/child.dart';
import '../domain/homework_guidance.dart';
import '../domain/homework_repository.dart';

class HomeworkTab extends StatefulWidget {
  const HomeworkTab({
    super.key,
    required this.token,
    required this.child,
    required this.homeworkRepository,
  });
  final String token;
  final Child child;
  final HomeworkRepository homeworkRepository;

  @override
  State<HomeworkTab> createState() => _HomeworkTabState();
}

class _HomeworkTabState extends State<HomeworkTab> {
  final TextEditingController _questionController = TextEditingController();
  HomeworkGuidance? _guidance;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _explain() async {
    final String question = _questionController.text.trim();
    if (question.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final HomeworkGuidance guidance = await widget.homeworkRepository
          .explain(widget.token, widget.child.id, question);
      if (!mounted) return;
      setState(() => _guidance = guidance);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'NovaLearn could not help right now: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Text('Homework helper', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text(
            'Photo scanning is not available yet, so type the question exactly as it '
            "appears on the worksheet and NovaLearn will walk through it step by step."),
        const SizedBox(height: 16),
        TextField(
          controller: _questionController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g. What is 7 + 5?'),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _loading ? null : _explain,
          icon: const Icon(Icons.auto_stories_outlined),
          label: const Text('Help me understand'),
        ),
        if (_guidance != null) ...<Widget>[
          const SizedBox(height: 20),
          ...List<Widget>.generate(
              _guidance!.steps.length,
              (int index) => Card(
                  child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(_guidance!.steps[index])))),
          const SizedBox(height: 8),
          Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_guidance!.finalHint))),
        ],
        if (_error != null) ...<Widget>[
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
      ]);
}
