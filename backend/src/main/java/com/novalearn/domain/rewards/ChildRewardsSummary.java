package com.novalearn.domain.rewards;

import java.time.LocalDate;

/** Read model for "how is this child doing on rewards right now" — coins are summed from the ledger, not stored directly. */
public record ChildRewardsSummary(int coins, int currentStreak, int longestStreak, LocalDate lastActivityDate) { }
