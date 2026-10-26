package com.novalearn.infrastructure.persistence;
import com.novalearn.application.auth.*; import com.novalearn.application.child.ChildProfileRepository; import com.novalearn.application.progress.LessonProgressRepository; import com.novalearn.domain.auth.RefreshToken; import com.novalearn.domain.child.ChildProfile; import com.novalearn.domain.progress.LessonProgress; import org.springframework.stereotype.Repository; import java.util.*;
@Repository class JpaParentAccountAdapter implements ParentAccountRepository {
 private final ParentAccountJpaRepository repo; JpaParentAccountAdapter(ParentAccountJpaRepository repo){this.repo=repo;} public boolean existsByEmail(String e){return repo.existsByEmail(e);} public ParentAccount save(ParentAccount a){ParentAccountEntity e=repo.save(new ParentAccountEntity(a.id(),a.email(),a.passwordHash(),a.role()));return new ParentAccount(e.getId(),e.getEmail(),e.getPasswordHash(),e.getRole());} public Optional<ParentAccount> findByEmail(String email){return repo.findByEmail(email).map(e->new ParentAccount(e.getId(),e.getEmail(),e.getPasswordHash(),e.getRole()));}
 public Optional<ParentAccount> findById(UUID id){return repo.findById(id).map(e->new ParentAccount(e.getId(),e.getEmail(),e.getPasswordHash(),e.getRole()));}
 public void deleteById(UUID id){repo.deleteById(id);}}
@Repository class JpaChildProfileAdapter implements ChildProfileRepository {
 private final ChildProfileJpaRepository repo; JpaChildProfileAdapter(ChildProfileJpaRepository repo){this.repo=repo;}
 public ChildProfile save(ChildProfile p){ChildProfileEntity e=repo.save(new ChildProfileEntity(p.id(),p.parentId(),p.displayName(),p.birthDate(),p.gradeLevel(),p.avatar(),p.learningPreferences()));return map(e);}
 public List<ChildProfile> findByParentId(UUID p){return repo.findByParentIdOrderByDisplayNameAsc(p).stream().map(JpaChildProfileAdapter::map).toList();}
 public boolean belongsToParent(UUID c,UUID p){return repo.existsByIdAndParentId(c,p);}
 private static ChildProfile map(ChildProfileEntity e){return new ChildProfile(e.getId(),e.getParentId(),e.getDisplayName(),e.getBirthDate(),e.getGradeLevel(),e.getAvatar(),e.getLearningPreferences());}}
@Repository class JpaLessonProgressAdapter implements LessonProgressRepository {
 private final LessonProgressJpaRepository repo; JpaLessonProgressAdapter(LessonProgressJpaRepository repo){this.repo=repo;} public Optional<LessonProgress> findByChildIdAndLessonCode(UUID c,String l){return repo.findByChildIdAndLessonCode(c,l).map(JpaLessonProgressAdapter::map);} public LessonProgress save(LessonProgress p){return map(repo.save(new LessonProgressEntity(p.id(),p.childId(),p.lessonCode(),p.score(),p.completed(),p.updatedAt())));} public List<LessonProgress> findByChildId(UUID c){return repo.findByChildIdOrderByUpdatedAtDesc(c).stream().map(JpaLessonProgressAdapter::map).toList();} private static LessonProgress map(LessonProgressEntity e){return new LessonProgress(e.getId(),e.getChildId(),e.getLessonCode(),e.getScore(),e.isCompleted(),e.getUpdatedAt());}}
@Repository class JpaRefreshTokenAdapter implements RefreshTokenRepository {
 private final RefreshTokenJpaRepository repo; JpaRefreshTokenAdapter(RefreshTokenJpaRepository repo){this.repo=repo;}
 public RefreshToken save(RefreshToken token){RefreshTokenEntity e=repo.save(new RefreshTokenEntity(token.id(),token.parentId(),token.tokenHash(),token.issuedAt(),token.expiresAt(),token.revoked()));return map(e);}
 public Optional<RefreshToken> findByTokenHash(String tokenHash){return repo.findByTokenHash(tokenHash).map(JpaRefreshTokenAdapter::map);}
 public void revoke(UUID id){repo.findById(id).ifPresent(e->{e.setRevoked(true);repo.save(e);});}
 public void revokeAllForParent(UUID parentId){repo.findByParentIdAndRevokedFalse(parentId).forEach(e->{e.setRevoked(true);repo.save(e);});}
 private static RefreshToken map(RefreshTokenEntity e){return new RefreshToken(e.getId(),e.getParentId(),e.getTokenHash(),e.getIssuedAt(),e.getExpiresAt(),e.isRevoked());}}
