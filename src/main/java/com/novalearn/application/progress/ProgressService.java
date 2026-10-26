package com.novalearn.application.progress;
import com.novalearn.application.child.ChildProfileRepository; import com.novalearn.application.common.ChildNotFoundException; import com.novalearn.application.rewards.RewardsService; import com.novalearn.domain.progress.LessonProgress; import org.springframework.stereotype.Service; import org.springframework.transaction.annotation.Transactional; import java.time.Instant; import java.util.List; import java.util.UUID;
@Service public class ProgressService {
 private final LessonProgressRepository progress; private final ChildProfileRepository children; private final RewardsService rewards;
 public ProgressService(LessonProgressRepository progress, ChildProfileRepository children, RewardsService rewards) { this.progress = progress; this.children = children; this.rewards = rewards; }
 @Transactional public LessonProgress record(UUID parentId, UUID childId, String lessonCode, int score, boolean completed) {
   if (!children.belongsToParent(childId, parentId)) throw new ChildNotFoundException();
   LessonProgress current = progress.findByChildIdAndLessonCode(childId, lessonCode).orElse(new LessonProgress(UUID.randomUUID(), childId, lessonCode, 0, false, Instant.now()));
   boolean newlyCompleted = completed && !current.completed();
   LessonProgress saved = progress.save(new LessonProgress(current.id(), childId, lessonCode, Math.max(current.score(), score), current.completed() || completed, Instant.now()));
   if (newlyCompleted) rewards.recordLessonCompletion(childId, score);
   return saved; }
 @Transactional(readOnly = true) public List<LessonProgress> list(UUID parentId, UUID childId) { if (!children.belongsToParent(childId, parentId)) throw new ChildNotFoundException(); return progress.findByChildId(childId); }
}
