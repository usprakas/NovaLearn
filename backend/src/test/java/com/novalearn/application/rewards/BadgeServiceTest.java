package com.novalearn.application.rewards;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.progress.LessonProgressRepository;
import com.novalearn.domain.progress.LessonProgress;
import com.novalearn.domain.rewards.Badge;
import com.novalearn.domain.rewards.ChildStreak;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class BadgeServiceTest {

  private final ChildProfileRepository children = mock(ChildProfileRepository.class);
  private final LessonProgressRepository progress = mock(LessonProgressRepository.class);
  private final ChildStreakRepository streaks = mock(ChildStreakRepository.class);
  private final BadgeRepository badges = mock(BadgeRepository.class);
  private final ChildBadgeRepository childBadges = mock(ChildBadgeRepository.class);
  private final BadgeService service = new BadgeService(children, progress, streaks, badges, childBadges);

  @Test
  void awardsFirstStepsOnTheFirstCompletedLesson() {
    UUID childId = UUID.randomUUID();
    when(progress.findByChildId(childId)).thenReturn(List.of(
        new LessonProgress(UUID.randomUUID(), childId, "G1-ADD-01", 100, true, Instant.now())));
    when(streaks.findByChildId(childId)).thenReturn(Optional.empty());
    when(childBadges.exists(childId, BadgeService.FIRST_STEPS)).thenReturn(false);
    when(badges.findByCode(BadgeService.FIRST_STEPS)).thenReturn(Optional.of(new Badge(BadgeService.FIRST_STEPS, "First Steps", "...")));

    List<Badge> awarded = service.evaluateAndAward(childId);

    assertThat(awarded).extracting(Badge::code).contains(BadgeService.FIRST_STEPS);
    verify(childBadges).save(any());
  }

  @Test
  void doesNotAwardFirstStepsAgainOnceAlreadyEarned() {
    UUID childId = UUID.randomUUID();
    when(progress.findByChildId(childId)).thenReturn(List.of(
        new LessonProgress(UUID.randomUUID(), childId, "G1-ADD-01", 100, true, Instant.now())));
    when(streaks.findByChildId(childId)).thenReturn(Optional.empty());
    when(childBadges.exists(childId, BadgeService.FIRST_STEPS)).thenReturn(true);

    List<Badge> awarded = service.evaluateAndAward(childId);

    assertThat(awarded).extracting(Badge::code).doesNotContain(BadgeService.FIRST_STEPS);
    verify(childBadges, never()).save(any());
  }

  @Test
  void awardsFiveDayStreakBadgeOnceTheStreakReachesFive() {
    UUID childId = UUID.randomUUID();
    when(progress.findByChildId(childId)).thenReturn(List.of());
    when(streaks.findByChildId(childId)).thenReturn(Optional.of(new ChildStreak(childId, 5, 5, null)));
    when(childBadges.exists(childId, BadgeService.FIVE_DAY_STREAK)).thenReturn(false);
    when(badges.findByCode(BadgeService.FIVE_DAY_STREAK)).thenReturn(Optional.of(new Badge(BadgeService.FIVE_DAY_STREAK, "On a Roll", "...")));

    List<Badge> awarded = service.evaluateAndAward(childId);

    assertThat(awarded).extracting(Badge::code).contains(BadgeService.FIVE_DAY_STREAK);
  }

  @Test
  void doesNotAwardTheStreakBadgeBelowFiveDays() {
    UUID childId = UUID.randomUUID();
    when(progress.findByChildId(childId)).thenReturn(List.of());
    when(streaks.findByChildId(childId)).thenReturn(Optional.of(new ChildStreak(childId, 4, 4, null)));

    List<Badge> awarded = service.evaluateAndAward(childId);

    assertThat(awarded).extracting(Badge::code).doesNotContain(BadgeService.FIVE_DAY_STREAK);
  }

  @Test
  void rejectsListingEarnedBadgesForAChildOutsideTheParentAccount() {
    when(children.belongsToParent(any(), any())).thenReturn(false);

    assertThatThrownBy(() -> service.listEarned(UUID.randomUUID(), UUID.randomUUID()))
        .isInstanceOf(com.novalearn.application.common.ChildNotFoundException.class);
  }
}
