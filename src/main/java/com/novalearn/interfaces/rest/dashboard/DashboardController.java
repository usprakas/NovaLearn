package com.novalearn.interfaces.rest.dashboard;

import com.novalearn.application.dashboard.DashboardService;
import com.novalearn.domain.dashboard.ChildDashboard;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.UUID;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/children/{childId}/dashboard")
@Tag(name = "Parent dashboard")
public class DashboardController {

  private final DashboardService dashboard;

  public DashboardController(DashboardService dashboard) {
    this.dashboard = dashboard;
  }

  @GetMapping
  public DashboardResponse get(@AuthenticationPrincipal UUID parentId, @PathVariable UUID childId) {
    return DashboardResponse.from(dashboard.get(parentId, childId));
  }

  public record DashboardResponse(
      int lessonsCompletedThisWeek,
      int totalLessonsAttempted,
      int averageScore,
      String strongestSubject,
      String weakestSubject,
      int coins,
      int currentStreak,
      int longestStreak) {
    static DashboardResponse from(ChildDashboard dashboard) {
      return new DashboardResponse(
          dashboard.lessonsCompletedThisWeek(),
          dashboard.totalLessonsAttempted(),
          dashboard.averageScore(),
          dashboard.strongestSubject(),
          dashboard.weakestSubject(),
          dashboard.coins(),
          dashboard.currentStreak(),
          dashboard.longestStreak());
    }
  }
}
