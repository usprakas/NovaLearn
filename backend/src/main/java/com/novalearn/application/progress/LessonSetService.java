package com.novalearn.application.progress;

import com.novalearn.application.catalog.ExerciseRepository;
import com.novalearn.application.catalog.LessonNotFoundException;
import com.novalearn.application.catalog.LessonRepository;
import com.novalearn.application.child.ChildProfileRepository;
import com.novalearn.application.common.ChildNotFoundException;
import com.novalearn.domain.catalog.Exercise;
import com.novalearn.domain.catalog.LessonDefinition;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Serves a lesson in small sets of {@link #SET_SIZE} questions instead of all at once. With no
 * set number requested, the child gets the first set that still has an unanswered question — so
 * finishing set 1 and coming back (even on another device) picks up at set 2. Once every set has
 * been answered, it starts again at set 1 for practice and says so via {@code completedAllSets}.
 */
@Service
public class LessonSetService {

  public static final int SET_SIZE = 3;

  private final ChildProfileRepository children;
  private final LessonRepository lessons;
  private final ExerciseRepository exercises;
  private final ExerciseAttemptRepository attempts;

  public LessonSetService(
      ChildProfileRepository children,
      LessonRepository lessons,
      ExerciseRepository exercises,
      ExerciseAttemptRepository attempts) {
    this.children = children;
    this.lessons = lessons;
    this.exercises = exercises;
    this.attempts = attempts;
  }

  public record LessonSet(
      LessonDefinition lesson, int setNumber, int totalSets, boolean completedAllSets, List<Exercise> exercises) { }

  /** {@code requestedSet} is 1-based; null means "the child's next unfinished set". */
  @Transactional(readOnly = true)
  public LessonSet set(UUID parentId, UUID childId, String lessonCode, Integer requestedSet) {
    if (!children.belongsToParent(childId, parentId)) {
      throw new ChildNotFoundException();
    }
    LessonDefinition lesson = lessons.findByCode(lessonCode).orElseThrow(LessonNotFoundException::new);
    List<Exercise> ordered = exercises.findByLessonCode(lessonCode).stream()
        .sorted(Comparator.comparingInt(Exercise::order))
        .toList();
    List<List<Exercise>> sets = new ArrayList<>();
    for (int i = 0; i < ordered.size(); i += SET_SIZE) {
      sets.add(ordered.subList(i, Math.min(i + SET_SIZE, ordered.size())));
    }
    if (sets.isEmpty()) {
      return new LessonSet(lesson, 1, 1, false, List.of());
    }

    Set<UUID> attempted = attempts.findAttemptedExerciseIds(
        childId, ordered.stream().map(Exercise::id).collect(Collectors.toSet()));
    int firstUnfinished = -1;
    for (int i = 0; i < sets.size() && firstUnfinished < 0; i++) {
      if (sets.get(i).stream().anyMatch(e -> !attempted.contains(e.id()))) {
        firstUnfinished = i;
      }
    }
    boolean completedAll = firstUnfinished < 0;

    int index = requestedSet != null
        ? Math.max(0, Math.min(requestedSet - 1, sets.size() - 1))
        : (completedAll ? 0 : firstUnfinished);
    return new LessonSet(lesson, index + 1, sets.size(), completedAll, sets.get(index));
  }
}
