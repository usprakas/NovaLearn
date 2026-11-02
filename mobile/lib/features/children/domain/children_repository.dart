import 'child.dart';

abstract interface class ChildrenRepository {
  Future<List<Child>> children(String token);
  Future<Child> createChild(String token, ChildDraft draft);

  /// Edits an existing profile in place, so the child keeps their progress, coins, and badges.
  Future<Child> updateChild(String token, String childId, ChildDraft draft);
}
