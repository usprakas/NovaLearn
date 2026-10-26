import 'rewards.dart';

abstract interface class RewardsRepository {
  Future<ChildRewards> rewards(String token, String childId);
}
