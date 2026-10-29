import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/nova_star.dart';
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
  String? _selectedChildId;

  @override
  void initState() {
    super.initState();
    _children = _load();
  }

  Future<List<Child>> _load() =>
      widget.childrenRepository.children(widget.token);

  void _reload({String? selectChildId}) => setState(() {
        _children = _load();
        if (selectChildId != null) _selectedChildId = selectChildId;
      });

  Future<void> _addChild(BuildContext context) async {
    final Child? result = await showDialog<Child>(
        context: context,
        builder: (_) =>
            _ChildDialog(token: widget.token, repository: widget.childrenRepository));
    if (result != null) _reload(selectChildId: result.id);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Child>>(
      future: _children,
      builder: (BuildContext context, AsyncSnapshot<List<Child>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ErrorState(
              message: friendlyErrorMessage(snapshot.error!), onRetry: _reload);
        }
        final List<Child> children = snapshot.data ?? <Child>[];
        if (children.isEmpty) {
          return _NewChildPrompt(
              token: widget.token,
              repository: widget.childrenRepository,
              onCreated: _reload);
        }
        final Child active = children.firstWhere(
            (Child c) => c.id == _selectedChildId,
            orElse: () => children.first);
        return Column(children: <Widget>[
          _ChildSwitcherBar(
              children: children,
              active: active,
              onSelect: (String id) => setState(() => _selectedChildId = id),
              onAddChild: () => _addChild(context)),
          Expanded(child: widget.builder(context, active, _reload)),
        ]);
      });
}

/// A slim header, shown above every tab, naming the active child with a way to switch between
/// siblings (when there's more than one) and to add another — the only entry point for a second
/// child, since the full-screen "add your child" prompt only ever shows when the list is empty.
class _ChildSwitcherBar extends StatelessWidget {
  const _ChildSwitcherBar(
      {required this.children,
      required this.active,
      required this.onSelect,
      required this.onAddChild});
  final List<Child> children;
  final Child active;
  final ValueChanged<String> onSelect;
  final VoidCallback onAddChild;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
        color: scheme.surfaceContainerLow,
        child: SafeArea(
            bottom: false,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(children: <Widget>[
                  Expanded(
                      child: children.length > 1
                          ? PopupMenuButton<String>(
                              tooltip: 'Switch child',
                              onSelected: onSelect,
                              itemBuilder: (BuildContext context) => children
                                  .map((Child c) => PopupMenuItem<String>(
                                      value: c.id,
                                      child: Row(children: <Widget>[
                                        if (c.id == active.id)
                                          Icon(Icons.check, size: 18, color: scheme.primary)
                                        else
                                          const SizedBox(width: 18),
                                        const SizedBox(width: 8),
                                        Text(c.displayName),
                                      ])))
                                  .toList(),
                              child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                                _ChildAvatar(name: active.displayName),
                                const SizedBox(width: 10),
                                Flexible(
                                    child: Text(active.displayName,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.titleMedium)),
                                const Icon(Icons.expand_more_rounded),
                              ]))
                          : Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                              _ChildAvatar(name: active.displayName),
                              const SizedBox(width: 10),
                              Flexible(
                                  child: Text(active.displayName,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.titleMedium)),
                            ])),
                  IconButton(
                      tooltip: 'Add another child',
                      onPressed: onAddChild,
                      icon: const Icon(Icons.person_add_alt_1_outlined)),
                ]))));
  }
}

/// A gradient initial-letter avatar, picking one of a few brand colors deterministically by name
/// so siblings read as visually distinct rather than identical primaryContainer circles. Only
/// colors already verified for white text (see app_theme.dart) are used here.
class _ChildAvatar extends StatelessWidget {
  const _ChildAvatar({required this.name});
  final String name;

  static const List<Color> _palette = <Color>[
    AppTheme.cosmicViolet,
    Color(0xff2563eb),
    Color(0xff12883e),
  ];

  @override
  Widget build(BuildContext context) {
    final Color color = _palette[name.hashCode.abs() % _palette.length];
    return CircleAvatar(
        radius: 16,
        backgroundColor: color,
        child: Text(name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)));
  }
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
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[AppTheme.novaPink, AppTheme.cosmicViolet],
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.35),
                              blurRadius: 24,
                              spreadRadius: 1),
                        ],
                      ),
                      child: const Stack(alignment: Alignment.center, children: <Widget>[
                        Icon(Icons.family_restroom_rounded, size: 46, color: Colors.white),
                        Positioned(right: 14, top: 14, child: NovaStar(size: 20, color: Colors.white)),
                      ])),
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
  String _gradeLevel = 'GRADE_1';
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
                    'Birthday: ${_birthDate.toIso8601String().substring(0, 10)}')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
                initialValue: _gradeLevel,
                decoration: const InputDecoration(labelText: 'Grade'),
                items: gradeLevels
                    .map((String g) =>
                        DropdownMenuItem<String>(value: g, child: Text(gradeLevelLabel(g))))
                    .toList(),
                onChanged: (String? value) {
                  if (value != null) setState(() => _gradeLevel = value);
                }),
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
                          displayName: _name.text,
                          birthDate: _birthDate,
                          gradeLevel: _gradeLevel));
                  if (!mounted) return;
                  navigator.pop(child);
                },
                child: const Text('Save'))
          ]);
}
