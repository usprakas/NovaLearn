package com.novalearn.application.dashboard;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.novalearn.application.catalog.LessonCatalogService;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.progress.LessonProgressRepository;
import com.novalearn.application.rewards.RewardsService;
import com.novalearn.domain.catalog.LessonDefinition;
import com.novalearn.domain.child.Avatar;
import com.novalearn.domain.child.ChildProfile;
import com.novalearn.domain.child.GradeLevel;
import com.novalearn.domain.dashboard.ChildDashboard;
import com.novalearn.domain.progress.LessonProgress;
import com.novalearn.domain.rewards.ChildRewardsSummary;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class DashboardServiceTest {

  private static ChildProfile childProfile(UUID child, UUID parent, GradeLevel gradeLevel) {
    return new ChildProfile(
        child, parent, "Kid", LocalDate.of(2018, 1, 1), gradeLevel, Avatar.FOX, Set.of());
  }

  @Test
  void aggregatesProgressAndRewardsIntoAParentFacingSummary() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    LessonProgressRepository progress = mock(LessonProgressRepository.class);
    RewardsService rewards = mock(RewardsService.class);
    LessonCatalogService catalog = mock(LessonCatalogService.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.findById(child)).thenReturn(Optional.of(childProfile(child, parent, GradeLevel.GRADE_1)));
    when(progress.findByChildId(child)).thenReturn(List.of(
        new LessonProgress(UUID.randomUUID(), child, "G1-ADD-01", 100, true, Instant.now()),
        new LessonProgress(UUID.randomUUID(), child, "G1-SUB-01", 60, true, Instant.now()),
        new LessonProgress(UUID.randomUUID(), child, "G1-ENG-01", 40, true, Instant.now())));
    when(catalog.subjectOf("G1-ADD-01")).thenReturn(Optional.of("MATH"));
    when(catalog.subjectOf("G1-SUB-01")).thenReturn(Optional.of("MATH"));
    when(catalog.subjectOf("G1-ENG-01")).thenReturn(Optional.of("ENGLISH"));
    when(rewards.get(parent, child)).thenReturn(new ChildRewardsSummary(25, 2, 2, null));
    DashboardService service = new DashboardService(children, progress, rewards, catalog);

    ChildDashboard dashboard = service.get(parent, child);

    assertThat(dashboard.totalLessonsAttempted()).isEqualTo(3);
    assertThat(dashboard.averageScore()).isEqualTo(67);
    assertThat(dashboard.strongestSubject()).isEqualTo("MATH");
    assertThat(dashboard.weakestSubject()).isEqualTo("ENGLISH");
    assertThat(dashboard.coins()).isEqualTo(25);
    assertThat(dashboard.currentStreak()).isEqualTo(2);
    assertThat(dashboard.recommendedNextLessonCode()).isNull();
  }

  @Test
  void recommendsTheFirstCatalogLessonTheChildHasNotYetCompletedAtTheirOwnGrade() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    LessonProgressRepository progress = mock(LessonProgressRepository.class);
    RewardsService rewards = mock(RewardsService.class);
    LessonCatalogService catalog = mock(LessonCatalogService.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.findById(child)).thenReturn(Optional.of(childProfile(child, parent, GradeLevel.GRADE_1)));
    when(progress.findByChildId(child)).thenReturn(List.of(
        new LessonProgress(UUID.randomUUID(), child, "G1-ADD-01", 100, true, Instant.now())));
    when(catalog.subjectOf("G1-ADD-01")).thenReturn(Optional.of("MATH"));
    when(catalog.forGrade(GradeLevel.GRADE_1)).thenReturn(List.of(
        new LessonDefinition("G1-ADD-01", "MATH", GradeLevel.GRADE_1, 1, "Adding", "desc"),
        new LessonDefinition("G1-SUB-01", "MATH", GradeLevel.GRADE_1, 2, "Subtracting", "desc")));
    when(rewards.get(parent, child)).thenReturn(new ChildRewardsSummary(0, 0, 0, null));
    DashboardService service = new DashboardService(children, progress, rewards, catalog);

    ChildDashboard dashboard = service.get(parent, child);

    assertThat(dashboard.recommendedNextLessonCode()).isEqualTo("G1-SUB-01");
    assertThat(dashboard.recommendedNextLessonTitle()).isEqualTo("Subtracting");
  }

  @Test
  void handlesAChildWithNoProgressYetWithoutFailing() {
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    LessonProgressRepository progress = mock(LessonProgressRepository.class);
    RewardsService rewards = mock(RewardsService.class);
    LessonCatalogService catalog = mock(LessonCatalogService.class);
    UUID parent = UUID.randomUUID();
    UUID child = UUID.randomUUID();
    when(children.findById(child)).thenReturn(Optional.of(childProfile(child, parent, GradeLevel.GRADE_1)));
    when(progress.findByChildId(child)).thenReturn(List.of());
    when(rewards.get(parent, child)).thenReturn(new ChildRewardsSummary(0, 0, 0, null));
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
    LessonCatalogService catalog = mock(LessonCatalogService.class);
    when(children.findById(any())).thenReturn(Optional.empty());
    DashboardService service = new DashboardService(children, progress, rewards, catalog);

    org.junit.jupiter.api.Assertions.assertThrows(
        com.novalearn.application.common.ChildNotFoundException.class,
        () -> service.get(UUID.randomUUID(), UUID.randomUUID()));
  }
}
