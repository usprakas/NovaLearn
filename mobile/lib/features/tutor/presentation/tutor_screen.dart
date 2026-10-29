import 'package:flutter/material.dart';
import '../../../core/voice/voice_assistant.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/nova_star.dart';
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
  final VoiceAssistant _voice = VoiceAssistant();
  TutorAnswer? _answer;
  bool _loading = false;
  bool _listening = false;
  int _attempt = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _questionController.addListener(_onQuestionChanged);
  }

  void _onQuestionChanged() => setState(() {});

  @override
  void dispose() {
    _questionController.removeListener(_onQuestionChanged);
    _questionController.dispose();
    _voice.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await _voice.stopListening();
      if (mounted) setState(() => _listening = false);
      return;
    }
    setState(() => _listening = true);
    final bool started = await _voice.startListening(
      (String text, bool isFinal) {
        setState(() {
          _questionController.text = text;
          if (isFinal) _listening = false;
        });
      },
      onStoppedListening: () {
        if (mounted) setState(() => _listening = false);
      },
    );
    if (!mounted) return;
    if (!started) {
      setState(() => _listening = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Voice input isn't available in this browser/device.")));
    }
  }

  Future<void> _ask({required bool tryAnotherWay}) async {
    final String question = _questionController.text.trim();
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Type or speak a question first.')));
      return;
    }
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
      setState(() => _error = friendlyErrorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Row(children: <Widget>[
          const NovaStar(size: 22),
          const SizedBox(width: 8),
          Text('Ask NovaLearn', style: Theme.of(context).textTheme.headlineSmall),
        ]),
        const SizedBox(height: 8),
        Text(
            "${widget.child.displayName} can ask any question, and NovaLearn will explain it in a "
            "kid-friendly way. If one explanation doesn't click, ask again for a different approach."),
        const SizedBox(height: 16),
        TextField(
          controller: _questionController,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
              hintText: 'e.g. Why is the moon following me?',
              suffixIcon: IconButton(
                  tooltip: _listening ? 'Stop listening' : 'Ask by voice',
                  onPressed: _toggleListening,
                  icon: Icon(_listening ? Icons.mic : Icons.mic_none,
                      color: _listening ? Theme.of(context).colorScheme.error : null))),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _loading || _questionController.text.trim().isEmpty
              ? null
              : () => _ask(tryAnotherWay: false),
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
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (!_answer!.refused)
                                Expanded(
                                    child: Text(_answer!.strategy.replaceAll('_', ' '),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                                color: Theme.of(context).colorScheme.primary)))
                              else
                                const Spacer(),
                              IconButton(
                                  tooltip: 'Read aloud',
                                  onPressed: () => _voice.speak(_answer!.explanation),
                                  icon: const Icon(Icons.volume_up_outlined),
                                  visualDensity: VisualDensity.compact),
                            ]),
                        Text(_answer!.explanation),
                      ]))),
          if (!_answer!.refused) ...<Widget>[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loading ? null : () => _ask(tryAnotherWay: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Try another way'),
            ),
          ],
          if (_answer!.suggestedNextActivity != null) ...<Widget>[
            const SizedBox(height: 12),
            Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_answer!.suggestedNextActivity!))),
          ],
        ],
        if (_error != null) ...<Widget>[
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
      ]);
}
