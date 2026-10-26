package com.novalearn.application.dashboard;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.novalearn.application.catalog.LessonCatalog;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.progress.LessonProgressRepository;
import com.novalearn.application.rewards.RewardsService;
import com.novalearn.domain.dashboard.ChildDashboard;
import com.novalearn.domain.progress.LessonProgress;
import com.novalearn.domain.rewards.ChildRewards;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class DashboardServiceTest {

  @Test
  void aggregatesProgressAndRewardsIntoAParentFacingSummary() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    LessonProgressRepository progress = mock(LessonProgressRepository.class);
    RewardsService rewards = mock(RewardsService.class);
    LessonCatalog catalog = new LessonCatalog();
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.belongsToParent(child, parent)).thenReturn(true);
    when(progress.findByChildId(child)).thenReturn(List.of(
        new LessonProgress(UUID.randomUUID(), child, "G1-ADD-01", 100, true, Instant.now()),
        new LessonProgress(UUID.randomUUID(), child, "G1-SUB-01", 60, true, Instant.now()),
        new LessonProgress(UUID.randomUUID(), child, "G1-ENG-01", 40, true, Instant.now())));
    when(rewards.get(parent, child)).thenReturn(new ChildRewards(child, 25, 2, 2, null));
    DashboardService service = new DashboardService(children, progress, rewards, catalog);

    ChildDashboard dashboard = service.get(parent, child);

    assertThat(dashboard.totalLessonsAttempted()).isEqualTo(3);
    assertThat(dashboard.averageScore()).isEqualTo(67);
    assertThat(dashboard.strongestSubject()).isEqualTo("MATH");
    assertThat(dashboard.weakestSubject()).isEqualTo("ENGLISH");
    assertThat(dashboard.coins()).isEqualTo(25);
    assertThat(dashboard.currentStreak()).isEqualTo(2);
  }

  @Test
  void handlesAChildWithNoProgressYetWithoutFailing() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    LessonProgressRepository progress = mock(LessonProgressRepository.class);
    RewardsService rewards = mock(RewardsService.class);
    LessonCatalog catalog = new LessonCatalog();
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.belongsToParent(child, parent)).thenReturn(true);
    when(progress.findByChildId(child)).thenReturn(List.of());
    when(rewards.get(parent, child)).thenReturn(ChildRewards.initial(child));
    DashboardService service = new DashboardService(children, progress, rewards, catalog);

    ChildDashboard dashboard = service.get(parent, child);

    assertThat(dashboard.totalLessonsAttempted()).isZero();
    assertThat(dashboard.averageScore()).isZero();
    assertThat(dashboard.strongestSubject()).isNull();
  }

  @Test
  void rejectsAChildOutsideTheParentAccount() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    LessonProgressRepository progress = mock(LessonProgressRepository.class);
    RewardsService rewards = mock(RewardsService.class);
    LessonCatalog catalog = new LessonCatalog();
    when(children.belongsToParent(any(), any())).thenReturn(false);
    DashboardService service = new DashboardService(children, progress, rewards, catalog);

    org.junit.jupiter.api.Assertions.assertThrows(
        com.novalearn.application.common.ChildNotFoundException.class,
        () -> service.get(UUID.randomUUID(), UUID.randomUUID()));
  }
}
