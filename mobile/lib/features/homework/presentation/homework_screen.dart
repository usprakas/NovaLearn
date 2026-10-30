import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/voice/voice_assistant.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/nova_star.dart';
import '../../children/domain/child.dart';
import '../domain/homework_guidance.dart';
import '../domain/homework_repository.dart';

class HomeworkTab extends StatefulWidget {
  const HomeworkTab({
    super.key,
    required this.token,
    required this.child,
    required this.homeworkRepository,
    this.pickImage,
  });
  final String token;
  final Child child;
  final HomeworkRepository homeworkRepository;

  /// Overridable for tests; defaults to the device camera / photo library via image_picker.
  final Future<Uint8List?> Function(ImageSource source)? pickImage;

  @override
  State<HomeworkTab> createState() => _HomeworkTabState();
}

class _HomeworkTabState extends State<HomeworkTab> {
  final TextEditingController _questionController = TextEditingController();
  final VoiceAssistant _voice = VoiceAssistant();
  HomeworkGuidance? _guidance;
  bool _loading = false;
  bool _scanning = false;
  bool _listening = false;
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

  Future<Uint8List?> _pickWithImagePicker(ImageSource source) async {
    // Downscaled on-device before upload: plenty of resolution to read worksheet text, and keeps
    // the request well under the API's 5 MB limit on a slow connection.
    final XFile? file = await ImagePicker()
        .pickImage(source: source, maxWidth: 1600, maxHeight: 1600, imageQuality: 85);
    return file?.readAsBytes();
  }

  Future<void> _scanPhoto(ImageSource source) async {
    setState(() => _error = null);
    final Uint8List? bytes;
    try {
      bytes = await (widget.pickImage ?? _pickWithImagePicker)(source);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = source == ImageSource.camera
          ? "The camera isn't available here. Try choosing a photo instead."
          : "We couldn't open that photo. Try another one.");
      return;
    }
    if (bytes == null || !mounted) return;
    setState(() {
      _scanning = true;
      _guidance = null;
    });
    try {
      final String question =
          await widget.homeworkRepository.scanQuestion(widget.token, widget.child.id, bytes);
      if (!mounted) return;
      _questionController.text = question;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Check the question is right, then tap "Help me understand".')));
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = friendlyErrorMessage(error));
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _explain() async {
    final String question = _questionController.text.trim();
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Type or speak the homework question first.')));
      return;
    }
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
          Text('Homework helper', style: Theme.of(context).textTheme.headlineSmall),
        ]),
        const SizedBox(height: 8),
        const Text(
            'Snap a photo of the question, or type it exactly as it appears on the worksheet, '
            'and NovaLearn will walk through it step by step.'),
        const SizedBox(height: 16),
        Wrap(spacing: 12, runSpacing: 8, children: <Widget>[
          FilledButton.tonalIcon(
            onPressed: _scanning || _loading ? null : () => _scanPhoto(ImageSource.camera),
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('Take a photo'),
          ),
          OutlinedButton.icon(
            onPressed: _scanning || _loading ? null : () => _scanPhoto(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Choose a photo'),
          ),
        ]),
        const SizedBox(height: 6),
        Text('Frame just the question — no faces or names. Photos are not saved.',
            style: Theme.of(context).textTheme.bodySmall),
        if (_scanning) ...<Widget>[
          const SizedBox(height: 12),
          const Row(children: <Widget>[
            SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5)),
            SizedBox(width: 10),
            Text('Reading the question from your photo…'),
          ]),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _questionController,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
              hintText: 'e.g. What is 7 + 5?',
              suffixIcon: IconButton(
                  tooltip: _listening ? 'Stop listening' : 'Ask by voice',
                  onPressed: _toggleListening,
                  icon: Icon(_listening ? Icons.mic : Icons.mic_none,
                      color: _listening ? Theme.of(context).colorScheme.error : null))),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed:
              _loading || _scanning || _questionController.text.trim().isEmpty
              ? null
              : _explain,
          icon: const Icon(Icons.auto_stories_outlined),
          label: const Text('Help me understand'),
        ),
        if (_guidance != null) ...<Widget>[
          const SizedBox(height: 20),
          ...List<Widget>.generate(
              _guidance!.steps.length,
              (int index) => Card(
                  child: ListTile(
                      leading: CircleAvatar(
                          backgroundColor: AppTheme.cosmicViolet,
                          foregroundColor: Colors.white,
                          child: Text('${index + 1}',
                              style: const TextStyle(fontWeight: FontWeight.w800))),
                      title: Text(_guidance!.steps[index], style: const TextStyle(fontSize: 16))))),
          const SizedBox(height: 8),
          Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(child: Text(_guidance!.finalHint)),
                        IconButton(
                            tooltip: 'Read aloud',
                            onPressed: () => _voice.speak(
                                '${_guidance!.steps.join('. ')}. ${_guidance!.finalHint}'),
                            icon: const Icon(Icons.volume_up_outlined),
                            visualDensity: VisualDensity.compact),
                      ]))),
        ],
        if (_error != null) ...<Widget>[
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
      ]);
}
