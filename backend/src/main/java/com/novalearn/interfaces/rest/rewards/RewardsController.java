package com.novalearn.interfaces.rest.rewards;

import com.novalearn.application.rewards.RewardsService;
import com.novalearn.domain.rewards.ChildRewardsSummary;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.time.LocalDate;
import java.util.UUID;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/children/{childId}/rewards")
@Tag(name = "Gamification")
public class RewardsController {

  private final RewardsService rewards;

  public RewardsController(RewardsService rewards) {
    this.rewards = rewards;
  }

  @GetMapping
  public RewardsResponse get(@AuthenticationPrincipal UUID parentId, @PathVariable UUID childId) {
    return RewardsResponse.from(rewards.get(parentId, childId));
  }

  public record RewardsResponse(int coins, int currentStreak, int longestStreak, LocalDate lastActivityDate) {
    static RewardsResponse from(ChildRewardsSummary summary) {
      return new RewardsResponse(summary.coins(), summary.currentStreak(), summary.longestStreak(), summary.lastActivityDate());
    }
  }
}
