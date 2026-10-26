import 'package:flutter/material.dart';
import '../domain/child.dart';
import '../domain/children_repository.dart';

class ChildPicker extends StatefulWidget {
  const ChildPicker(
      {super.key,
      required this.token,
      required this.childrenRepository,
      required this.builder});
  final String token;
  final ChildrenRepository childrenRepository;
  final Widget Function(BuildContext, Child, VoidCallback) builder;
  @override
  State<ChildPicker> createState() => _ChildPickerState();
}

class _ChildPickerState extends State<ChildPicker> {
  late Future<List<Child>> _children;
  @override
  void initState() {
    super.initState();
    _children = _load();
  }

  Future<List<Child>> _load() =>
      widget.childrenRepository.children(widget.token);
  void _reload() => setState(() {
        _children = _load();
      });
  @override
  Widget build(BuildContext context) => FutureBuilder<List<Child>>(
      future: _children,
      builder: (BuildContext context, AsyncSnapshot<List<Child>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                      'We could not load child profiles. ${snapshot.error}')));
        }
        final List<Child> children = snapshot.data ?? <Child>[];
        if (children.isEmpty) {
          return _NewChildPrompt(
              token: widget.token,
              repository: widget.childrenRepository,
              onCreated: _reload);
        }
        return widget.builder(context, children.first, _reload);
      });
}

class _NewChildPrompt extends StatelessWidget {
  const _NewChildPrompt(
      {required this.token, required this.repository, required this.onCreated});
  final String token;
  final ChildrenRepository repository;
  final VoidCallback onCreated;
  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      width: 96,
                      height: 96,
                      decoration:
                          BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
                      child: Icon(Icons.family_restroom_rounded,
                          size: 48, color: scheme.onPrimaryContainer)),
                  const SizedBox(height: 24),
                  Text("Let's set up your child's profile",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Add their name and birthday to get started with NovaLearn.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add your child'),
                      onPressed: () async {
                        final Child? result = await showDialog<Child>(
                            context: context,
                            builder: (_) =>
                                _ChildDialog(token: token, repository: repository));
                        if (result != null) onCreated();
                      }),
                ])));
  }
}

class _ChildDialog extends StatefulWidget {
  const _ChildDialog({required this.token, required this.repository});
  final String token;
  final ChildrenRepository repository;
  @override
  State<_ChildDialog> createState() => _ChildDialogState();
}

class _ChildDialogState extends State<_ChildDialog> {
  final TextEditingController _name = TextEditingController();
  DateTime _birthDate = DateTime(2020, 1, 1);
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: const Text('Add a child'),
          content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Display name')),
            const SizedBox(height: 12),
            TextButton(
                onPressed: () async {
                  final DateTime? date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2012),
                      lastDate:
                          DateTime.now().subtract(const Duration(days: 1)),
                      initialDate: _birthDate);
                  if (!mounted || date == null) return;
                  setState(() => _birthDate = date);
                },
                child: Text(
                    'Birthday: ${_birthDate.toIso8601String().substring(0, 10)}'))
          ]),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () async {
                  if (_name.text.trim().isEmpty) return;
                  final NavigatorState navigator = Navigator.of(context);
                  final Child child = await widget.repository.createChild(
                      widget.token,
                      ChildDraft(
                          displayName: _name.text, birthDate: _birthDate));
                  if (!mounted) return;
                  navigator.pop(child);
                },
                child: const Text('Save'))
          ]);
}
