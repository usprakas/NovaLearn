import 'child_dashboard.dart';

abstract interface class DashboardRepository {
  Future<ChildDashboard> dashboard(String token, String childId);
}
