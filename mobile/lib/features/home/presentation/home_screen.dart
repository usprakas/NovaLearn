import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/security/session_store.dart';
import '../../auth/presentation/account_settings_screen.dart';
import '../../children/domain/child.dart';
import '../../children/presentation/child_picker.dart';
import '../../homework/presentation/homework_screen.dart';
import '../../learning/presentation/lesson_list_screen.dart';
import '../../learning/presentation/parent_dashboard.dart';
import '../../tutor/presentation/tutor_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.session});
  final Session session;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final api = ref.watch(novaLearnApiProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('NovaLearn'), actions: <Widget>[
        IconButton(
            tooltip: 'Account',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => AccountSettingsScreen(session: widget.session))),
            icon: const Icon(Icons.account_circle_outlined))
      ]),
      body: ChildPicker(
        token: widget.session.accessToken,
        childrenRepository: api,
        builder: (BuildContext context, Child child, VoidCallback reloadChildren) =>
            _buildTab(child, reloadChildren),
      ),
      bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (int value) => setState(() => _tab = value),
          destinations: const <NavigationDestination>[
            NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Learn'),
            NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: 'Tutor'),
            NavigationDestination(
                icon: Icon(Icons.auto_stories_outlined),
                selectedIcon: Icon(Icons.auto_stories),
                label: 'Homework'),
            NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights),
                label: 'Progress'),
          ]),
    );
  }

  Widget _buildTab(Child child, VoidCallback reloadChildren) {
    final api = ref.watch(novaLearnApiProvider);
    switch (_tab) {
      case 0:
        return LessonListTab(
            token: widget.session.accessToken,
            child: child,
            lessonsRepository: api,
            exerciseRepository: api,
            dashboardRepository: api,
            onLessonCompleted: reloadChildren);
      case 1:
        return TutorTab(
            token: widget.session.accessToken,
            child: child,
            tutorRepository: api);
      case 2:
        return HomeworkTab(
            token: widget.session.accessToken,
            child: child,
            homeworkRepository: api);
      default:
        return ParentDashboard(
            token: widget.session.accessToken,
            child: child,
            dashboardRepository: api,
            progressRepository: api,
            badgesRepository: api);
    }
  }
}
