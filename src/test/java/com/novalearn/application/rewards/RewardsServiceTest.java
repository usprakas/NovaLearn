package com.novalearn.application.rewards;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.domain.rewards.ChildRewards;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class RewardsServiceTest {

  private final Clock fixedClock = Clock.fixed(Instant.parse("2026-01-10T00:00:00Z"), ZoneOffset.UTC);

  @Test
  void awardsCoinsForAFirstCompletionAndBonusForAPerfectScore() {
    ChildRewardsRepository rewards = mock(ChildRewardsRepository.class);
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    UUID childId = UUID.randomUUID();
    when(rewards.findByChildId(childId)).thenReturn(Optional.empty());
    when(rewards.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
    RewardsService service = new RewardsService(rewards, children, fixedClock);

    ChildRewards result = service.recordLessonCompletion(childId, 100);

    assertThat(result.coins()).isEqualTo(15);
    assertThat(result.currentStreak()).isEqualTo(1);
    assertThat(result.longestStreak()).isEqualTo(1);
  }

  @Test
  void doesNotAwardTheBonusForAnImperfectScore() {
    ChildRewardsRepository rewards = mock(ChildRewardsRepository.class);
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    UUID childId = UUID.randomUUID();
    when(rewards.findByChildId(childId)).thenReturn(Optional.empty());
    when(rewards.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
    RewardsService service = new RewardsService(rewards, children, fixedClock);

    ChildRewards result = service.recordLessonCompletion(childId, 80);

    assertThat(result.coins()).isEqualTo(10);
  }

  @Test
  void extendsTheStreakOnConsecutiveDaysAndTracksTheLongestStreak() {
    ChildRewardsRepository rewards = mock(ChildRewardsRepository.class);
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    UUID childId = UUID.randomUUID();
    LocalDate yesterday = LocalDate.now(fixedClock).minusDays(1);
    when(rewards.findByChildId(childId)).thenReturn(Optional.of(new ChildRewards(childId, 10, 3, 3, yesterday)));
    when(rewards.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
    RewardsService service = new RewardsService(rewards, children, fixedClock);

    ChildRewards result = service.recordLessonCompletion(childId, 50);

    assertThat(result.currentStreak()).isEqualTo(4);
    assertThat(result.longestStreak()).isEqualTo(4);
  }

  @Test
  void resetsTheStreakAfterAMissedDayButKeepsTheLongestStreakRecord() {
    ChildRewardsRepository rewards = mock(ChildRewardsRepository.class);
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    UUID childId = UUID.randomUUID();
    LocalDate longAgo = LocalDate.now(fixedClock).minusDays(5);
    when(rewards.findByChildId(childId)).thenReturn(Optional.of(new ChildRewards(childId, 10, 7, 7, longAgo)));
    when(rewards.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
    RewardsService service = new RewardsService(rewards, children, fixedClock);

    ChildRewards result = service.recordLessonCompletion(childId, 50);

    assertThat(result.currentStreak()).isEqualTo(1);
    assertThat(result.longestStreak()).isEqualTo(7);
  }

  @Test
  void doesNotDoubleCountTheStreakForASecondCompletionOnTheSameDay() {
    ChildRewardsRepository rewards = mock(ChildRewardsRepository.class);
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    UUID childId = UUID.randomUUID();
    LocalDate today = LocalDate.now(fixedClock);
    when(rewards.findByChildId(childId)).thenReturn(Optional.of(new ChildRewards(childId, 10, 2, 2, today)));
    when(rewards.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
    RewardsService service = new RewardsService(rewards, children, fixedClock);

    ChildRewards result = service.recordLessonCompletion(childId, 50);

    assertThat(result.currentStreak()).isEqualTo(2);
  }

  @Test
  void rejectsReadingRewardsForAChildOutsideTheParentAccount() {
    ChildRewardsRepository rewards = mock(ChildRewardsRepository.class);
    ChildProfileRepository children = mock(ChildProfileRepository.class);
    when(children.belongsToParent(any(), any())).thenReturn(false);
    RewardsService service = new RewardsService(rewards, children, fixedClock);

    org.junit.jupiter.api.Assertions.assertThrows(
        com.novalearn.application.common.ChildNotFoundException.class,
        () -> service.get(UUID.randomUUID(), UUID.randomUUID()));
  }
}
