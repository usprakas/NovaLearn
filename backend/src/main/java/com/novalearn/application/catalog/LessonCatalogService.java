package com.novalearn.application.catalog;

import com.novalearn.domain.catalog.Exercise;
import com.novalearn.domain.catalog.LessonDefinition;
import com.novalearn.domain.child.GradeLevel;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * The lesson catalog now lives in the database (lessons/exercises tables, seeded by
 * V8__seed_grade1_math_curriculum.sql) rather than in code — see docs/ARCHITECTURE.md for why
 * this supersedes the original Sprint 1 in-code-catalog decision once exercises needed their own
 * server-side-evaluated identity. This service is the same facade shape the old in-code
 * `LessonCatalog` had, so its callers (the catalog controller, {@code DashboardService}) did not
 * need to change beyond the constructor type.
 */
@Service
public class LessonCatalogService {

  private final LessonRepository lessons;
  private final ExerciseRepository exercises;

  /**
   * Core subjects first, then the Indian-syllabus subjects, in the order a parent would expect to
   * see them; any subject not listed here sorts after these, alphabetically. Plain alphabetical
   * order would put MATH between HINDI and TELUGU.
   */
  static final List<String> SUBJECT_ORDER = List.of("MATH", "ENGLISH", "EVS", "HINDI", "TELUGU");

  static final Comparator<LessonDefinition> BY_SUBJECT_THEN_ORDER =
      Comparator.<LessonDefinition>comparingInt(lesson -> subjectRank(lesson.subject()))
          .thenComparing(LessonDefinition::subject)
          .thenComparing(LessonDefinition::order);

  private static int subjectRank(String subject) {
    int rank = SUBJECT_ORDER.indexOf(subject);
    return rank < 0 ? SUBJECT_ORDER.size() : rank;
  }

  public LessonCatalogService(LessonRepository lessons, ExerciseRepository exercises) {
    this.lessons = lessons;
    this.exercises = exercises;
  }

  @Transactional(readOnly = true)
  public List<LessonDefinition> all() {
    return lessons.findAll().stream()
        .sorted(BY_SUBJECT_THEN_ORDER)
        .toList();
  }

  /** Only the lessons at exactly this grade — a child never sees another grade's catalog. */
  @Transactional(readOnly = true)
  public List<LessonDefinition> forGrade(GradeLevel gradeLevel) {
    return lessons.findByGradeLevel(gradeLevel).stream()
        .sorted(BY_SUBJECT_THEN_ORDER)
        .toList();
  }

  @Transactional(readOnly = true)
  public LessonDefinition get(String code) {
    return lessons.findByCode(code).orElseThrow(LessonNotFoundException::new);
  }

  @Transactional(readOnly = true)
  public List<Exercise> exercisesOf(String lessonCode) {
    return exercises.findByLessonCode(lessonCode);
  }

  @Transactional(readOnly = true)
  public Optional<String> subjectOf(String lessonCode) {
    return lessons.findByCode(lessonCode).map(LessonDefinition::subject);
  }
}
