import 'child_badge.dart';

abstract interface class BadgesRepository {
  Future<List<ChildBadge>> badges(String token, String childId);
}
