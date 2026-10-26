import 'child.dart';

abstract interface class ChildrenRepository {
  Future<List<Child>> children(String token);
  Future<Child> createChild(String token, ChildDraft draft);
}
