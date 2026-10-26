package com.novalearn.infrastructure.persistence;
import org.springframework.data.jpa.repository.JpaRepository; import java.util.*;
interface ParentAccountJpaRepository extends JpaRepository<ParentAccountEntity, UUID> { boolean existsByEmail(String email); Optional<ParentAccountEntity> findByEmail(String email); }
interface ChildProfileJpaRepository extends JpaRepository<ChildProfileEntity, UUID> { List<ChildProfileEntity> findByParentIdOrderByDisplayNameAsc(UUID parentId); boolean existsByIdAndParentId(UUID id, UUID parentId); }
interface LessonProgressJpaRepository extends JpaRepository<LessonProgressEntity, UUID> { Optional<LessonProgressEntity> findByChildIdAndLessonCode(UUID childId,String lessonCode); List<LessonProgressEntity> findByChildIdOrderByUpdatedAtDesc(UUID childId); }
interface ChildRewardsJpaRepository extends JpaRepository<ChildRewardsEntity, UUID> { }
