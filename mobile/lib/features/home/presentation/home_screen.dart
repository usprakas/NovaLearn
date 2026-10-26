import 'package:flutter/material.dart';
import '../../../core/network/novalearn_api.dart';
import '../../../core/security/session_store.dart';
import '../../children/domain/child.dart';
import '../../children/presentation/child_picker.dart';
import '../../homework/presentation/homework_screen.dart';
import '../../learning/presentation/lesson_list_screen.dart';
import '../../learning/presentation/parent_dashboard.dart';
import '../../tutor/presentation/tutor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(
      {super.key,
      required this.api,
      required this.session,
      required this.onSignOut});
  final NovaLearnApi api;
  final Session session;
  final Future<void> Function() onSignOut;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('NovaLearn'), actions: <Widget>[
          IconButton(
              tooltip: 'Sign out',
              onPressed: widget.onSignOut,
              icon: const Icon(Icons.logout))
        ]),
        body: ChildPicker(
          token: widget.session.accessToken,
          childrenRepository: widget.api,
          builder: (BuildContext context, Child child,
                  VoidCallback reloadChildren) =>
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

  Widget _buildTab(Child child, VoidCallback reloadChildren) {
    switch (_tab) {
      case 0:
        return LessonListTab(
            token: widget.session.accessToken,
            child: child,
            lessonsRepository: widget.api,
            progressRepository: widget.api,
            onLessonCompleted: reloadChildren);
      case 1:
        return TutorTab(
            token: widget.session.accessToken,
            child: child,
            tutorRepository: widget.api);
      case 2:
        return HomeworkTab(
            token: widget.session.accessToken,
            child: child,
            homeworkRepository: widget.api);
      default:
        return ParentDashboard(
            token: widget.session.accessToken,
            child: child,
            dashboardRepository: widget.api,
            progressRepository: widget.api);
    }
  }
}
