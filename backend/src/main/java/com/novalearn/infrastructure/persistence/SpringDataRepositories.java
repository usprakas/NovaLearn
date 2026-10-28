package com.novalearn.infrastructure.persistence;
import org.springframework.data.jpa.repository.JpaRepository; import org.springframework.data.jpa.repository.Query; import org.springframework.data.repository.query.Param; import java.util.*;
interface ParentAccountJpaRepository extends JpaRepository<ParentAccountEntity, UUID> { boolean existsByEmail(String email); Optional<ParentAccountEntity> findByEmail(String email); }
interface ChildProfileJpaRepository extends JpaRepository<ChildProfileEntity, UUID> { List<ChildProfileEntity> findByParentIdOrderByDisplayNameAsc(UUID parentId); boolean existsByIdAndParentId(UUID id, UUID parentId); }
interface LessonProgressJpaRepository extends JpaRepository<LessonProgressEntity, UUID> { Optional<LessonProgressEntity> findByChildIdAndLessonCode(UUID childId,String lessonCode); List<LessonProgressEntity> findByChildIdOrderByUpdatedAtDesc(UUID childId); }
interface RefreshTokenJpaRepository extends JpaRepository<RefreshTokenEntity, UUID> { Optional<RefreshTokenEntity> findByTokenHash(String tokenHash); List<RefreshTokenEntity> findByParentIdAndRevokedFalse(UUID parentId); }
interface LessonJpaRepository extends JpaRepository<LessonEntity, UUID> { Optional<LessonEntity> findByCode(String code); List<LessonEntity> findByGradeLevel(com.novalearn.domain.child.GradeLevel gradeLevel); }
interface ExerciseJpaRepository extends JpaRepository<ExerciseEntity, UUID> {
  List<ExerciseEntity> findByLessonCodeOrderByDisplayOrder(String lessonCode);
  int countByLessonCode(String lessonCode);
}
interface ExerciseAttemptJpaRepository extends JpaRepository<ExerciseAttemptEntity, UUID> {
  List<ExerciseAttemptEntity> findByChildIdAndExerciseId(UUID childId, UUID exerciseId);

  @Query("select distinct a.exerciseId from ExerciseAttemptEntity a where a.childId = :childId and a.exerciseId in :exerciseIds")
  Set<UUID> findDistinctExerciseIdsByChildIdAndExerciseIdIn(@Param("childId") UUID childId, @Param("exerciseIds") Set<UUID> exerciseIds);

  @Query("select count(distinct a.exerciseId) from ExerciseAttemptEntity a where a.childId = :childId and a.exerciseId in :exerciseIds and a.correct = true")
  long countDistinctCorrectExerciseIds(@Param("childId") UUID childId, @Param("exerciseIds") Set<UUID> exerciseIds);
}
interface SkillProgressJpaRepository extends JpaRepository<SkillProgressEntity, SkillProgressId> { }
interface ChildStreakJpaRepository extends JpaRepository<ChildStreakEntity, UUID> { }
interface RewardTransactionJpaRepository extends JpaRepository<RewardTransactionEntity, UUID> {
  boolean existsByReferenceTypeAndReferenceId(String referenceType, String referenceId);

  @Query("select sum(t.deltaCoins) from RewardTransactionEntity t where t.childId = :childId")
  Integer sumDeltaCoinsByChildId(@Param("childId") UUID childId);
}
interface BadgeJpaRepository extends JpaRepository<BadgeEntity, String> { }
interface ChildBadgeJpaRepository extends JpaRepository<ChildBadgeEntity, ChildBadgeId> { List<ChildBadgeEntity> findByIdChildId(UUID childId); }
