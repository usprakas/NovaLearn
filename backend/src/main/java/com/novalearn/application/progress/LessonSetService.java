package com.novalearn.application.progress;

import com.novalearn.application.catalog.ExerciseRepository;
import com.novalearn.application.catalog.LessonNotFoundException;
import com.novalearn.application.catalog.LessonRepository;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.domain.catalog.Exercise;
import com.novalearn.domain.catalog.LessonDefinition;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.random.RandomGenerator;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Serves a lesson in small sets of {@link #SET_SIZE} questions instead of all at once, picked at
 * random each time so a child doesn't see the same questions in the same order on every visit.
 * While some of the lesson's questions are still unanswered, a set is drawn only from those, so
 * every question gets seen; the set number follows how many the child has answered, so coming
 * back (even on another device) continues where they left off. Once every question has been
 * answered, sets are drawn at random from the whole lesson for practice, and
 * {@code completedAllSets} says so.
 */
@Service
public class LessonSetService {

  public static final int SET_SIZE = 3;

  private final ChildProfileRepository children;
  private final LessonRepository lessons;
  private final ExerciseRepository exercises;
  private final ExerciseAttemptRepository attempts;
  private final RandomGenerator random;

  @Autowired
  public LessonSetService(
      ChildProfileRepository children,
      LessonRepository lessons,
      ExerciseRepository exercises,
      ExerciseAttemptRepository attempts) {
    this(children, lessons, exercises, attempts, new SecureRandom());
  }

  LessonSetService(
      ChildProfileRepository children,
      LessonRepository lessons,
      ExerciseRepository exercises,
      ExerciseAttemptRepository attempts,
      RandomGenerator random) {
    this.children = children;
    this.lessons = lessons;
    this.exercises = exercises;
    this.attempts = attempts;
    this.random = random;
  }

  public record LessonSet(
      LessonDefinition lesson, int setNumber, int totalSets, boolean completedAllSets, List<Exercise> exercises) { }

  /**
   * {@code requestedSet} (1-based) only labels practice rounds, where the child steps through
   * set 1, 2, ... again; before then the set number comes from the child's own progress.
   */
  @Transactional(readOnly = true)
  public LessonSet set(UUID parentId, UUID childId, String lessonCode, Integer requestedSet) {
    if (!children.belongsToParent(childId, parentId)) {
      throw new ChildNotFoundException();
    }
    LessonDefinition lesson = lessons.findByCode(lessonCode).orElseThrow(LessonNotFoundException::new);
    List<Exercise> all = exercises.findByLessonCode(lessonCode);
    if (all.isEmpty()) {
      return new LessonSet(lesson, 1, 1, false, List.of());
    }
    int totalSets = (all.size() + SET_SIZE - 1) / SET_SIZE;

    Set<UUID> attempted = attempts.findAttemptedExerciseIds(
        childId, all.stream().map(Exercise::id).collect(Collectors.toSet()));
    List<Exercise> unanswered = new ArrayList<>(all.stream().filter(e -> !attempted.contains(e.id())).toList());

    if (unanswered.isEmpty()) {
      int number = requestedSet == null ? 1 : Math.max(1, Math.min(requestedSet, totalSets));
      return new LessonSet(lesson, number, totalSets, true, pick(new ArrayList<>(all)));
    }
    int answered = all.size() - unanswered.size();
    int number = Math.min(answered / SET_SIZE + 1, totalSets);
    return new LessonSet(lesson, number, totalSets, false, pick(unanswered));
  }

  private List<Exercise> pick(List<Exercise> pool) {
    Collections.shuffle(pool, random);
    return List.copyOf(pool.subList(0, Math.min(SET_SIZE, pool.size())));
  }
}
