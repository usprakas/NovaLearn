package com.novalearn.interfaces.rest.rewards;

import com.novalearn.application.rewards.BadgeService;
import com.novalearn.domain.rewards.ChildBadge;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/children/{childId}/badges")
@Tag(name = "Gamification")
public class BadgesController {

  private final BadgeService badges;

  public BadgesController(BadgeService badges) {
    this.badges = badges;
  }

  @GetMapping
  public List<ChildBadgeResponse> list(@AuthenticationPrincipal UUID parentId, @PathVariable UUID childId) {
    return badges.listEarned(parentId, childId).stream().map(ChildBadgeResponse::from).toList();
  }

  public record ChildBadgeResponse(String badgeCode, Instant awardedAt) {
    static ChildBadgeResponse from(ChildBadge badge) {
      return new ChildBadgeResponse(badge.badgeCode(), badge.awardedAt());
    }
  }
}
