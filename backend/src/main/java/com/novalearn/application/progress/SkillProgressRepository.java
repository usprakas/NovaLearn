package com.novalearn.application.progress;

import com.novalearn.domain.progress.SkillProgress;
import java.util.Optional;
import java.util.UUID;

public interface SkillProgressRepository {
  Optional<SkillProgress> findByChildIdAndSkillCode(UUID childId, String skillCode);

  SkillProgress save(SkillProgress progress);
}
