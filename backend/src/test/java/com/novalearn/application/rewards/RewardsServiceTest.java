package com.novalearn.application.rewards;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.domain.rewards.ChildRewardsSummary;
import com.novalearn.domain.rewards.ChildStreak;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.dao.DataIntegrityViolationException;

class RewardsServiceTest {

  private final RewardTransactionRepository transactions = mock(RewardTransactionRepository.class);
  private final ChildStreakRepository streaks = mock(ChildStreakRepository.class);
  private final ChildProfileRepository children = mock(ChildProfileRepository.class);
  private final BadgeService badges = mock(BadgeService.class);
  private final Clock fixedClock = Clock.fixed(Instant.parse("2026-01-10T00:00:00Z"), ZoneOffset.UTC);
  private final RewardsService service = new RewardsService(transactions, streaks, children, badges, fixedClock);

  @Test
  void awardsCoinsAndAdvancesTheStreakOnANewEvent() {
    UUID childId = UUID.randomUUID();
    when(transactions.existsByReferenceTypeAndReferenceId("LESSON_COMPLETION", "ref-1")).thenReturn(false);
    when(streaks.findByChildId(childId)).thenReturn(Optional.empty());
    when(streaks.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

    service.award(childId, 15, "Completed a lesson", "LESSON_COMPLETION", "ref-1");

    verify(transactions).save(any());
    verify(streaks).save(org.mockito.ArgumentMatchers.argThat(s -> s.currentStreak() == 1));
    verify(badges).evaluateAndAward(childId);
  }

  @Test
  void doesNotAwardTwiceForTheSameReferenceAlreadyRecorded() {
    UUID childId = UUID.randomUUID();
    when(transactions.existsByReferenceTypeAndReferenceId("LESSON_COMPLETION", "ref-1")).thenReturn(true);

    service.award(childId, 15, "Completed a lesson", "LESSON_COMPLETION", "ref-1");

    verify(transactions, never()).save(any());
    verify(streaks, never()).save(any());
    verify(badges, never()).evaluateAndAward(any());
  }

  @Test
  void treatsAConcurrentDuplicateInsertAsAlreadyAwardedRatherThanFailing() {
    UUID childId = UUID.randomUUID();
    when(transactions.existsByReferenceTypeAndReferenceId(any(), any())).thenReturn(false);
    when(transactions.save(any())).thenThrow(new DataIntegrityViolationException("unique constraint violated"));

    service.award(childId, 15, "Completed a lesson", "LESSON_COMPLETION", "ref-1");

    verify(streaks, never()).save(any());
  }

  @Test
  void extendsTheStreakOnConsecutiveDaysAndTracksTheLongestStreak() {
    UUID childId = UUID.randomUUID();
    LocalDate yesterday = LocalDate.now(fixedClock).minusDays(1);
    when(transactions.existsByReferenceTypeAndReferenceId(any(), any())).thenReturn(false);
    when(streaks.findByChildId(childId)).thenReturn(Optional.of(new ChildStreak(childId, 3, 3, yesterday)));
    when(streaks.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

    service.award(childId, 10, "reason", "TYPE", "ref-2");

    verify(streaks).save(org.mockito.ArgumentMatchers.argThat(s -> s.currentStreak() == 4 && s.longestStreak() == 4));
  }

  @Test
  void resetsTheStreakAfterAMissedDayButKeepsTheLongestStreakRecord() {
    UUID childId = UUID.randomUUID();
    LocalDate longAgo = LocalDate.now(fixedClock).minusDays(5);
    when(transactions.existsByReferenceTypeAndReferenceId(any(), any())).thenReturn(false);
    when(streaks.findByChildId(childId)).thenReturn(Optional.of(new ChildStreak(childId, 7, 7, longAgo)));
    when(streaks.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

    service.award(childId, 10, "reason", "TYPE", "ref-3");

    verify(streaks).save(org.mockito.ArgumentMatchers.argThat(s -> s.currentStreak() == 1 && s.longestStreak() == 7));
  }

  @Test
  void getSumsCoinsFromTheLedgerAndReadsStreakState() {
    UUID parentId = UUID.randomUUID();
    UUID childId = UUID.randomUUID();
    when(children.belongsToParent(childId, parentId)).thenReturn(true);
    when(transactions.sumCoinsForChild(childId)).thenReturn(35);
    when(streaks.findByChildId(childId)).thenReturn(Optional.of(new ChildStreak(childId, 2, 4, LocalDate.now(fixedClock))));

    ChildRewardsSummary summary = service.get(parentId, childId);

    assertThat(summary.coins()).isEqualTo(35);
    assertThat(summary.currentStreak()).isEqualTo(2);
    assertThat(summary.longestStreak()).isEqualTo(4);
  }

  @Test
  void rejectsReadingRewardsForAChildOutsideTheParentAccount() {
    when(children.belongsToParent(any(), any())).thenReturn(false);

    org.junit.jupiter.api.Assertions.assertThrows(
        com.novalearn.application.common.ChildNotFoundException.class,
        () -> service.get(UUID.randomUUID(), UUID.randomUUID()));
  }
}
