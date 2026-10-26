package com.novalearn.application.catalog;

import com.novalearn.domain.catalog.LessonDefinition;
import com.novalearn.domain.catalog.LessonQuestion;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.springframework.stereotype.Component;

/**
 * The Grade 1 Math/English curriculum slice. Content lives in code, not a database table — this
 * keeps the original Sprint 1 decision that lesson codes stay opaque so curriculum can expand
 * without a schema change (see ARCHITECTURE.md). A real catalog with hundreds of lessons across
 * grades would move this to a CMS or an admin-editable table; in-code is the right size for an
 * MVP with five lessons.
 */
@Component
public class LessonCatalog {

  private final Map<String, LessonDefinition> lessons = new LinkedHashMap<>();

  public LessonCatalog() {
    register(new LessonDefinition("G1-ADD-01", "MATH", 1, "Adding within 10",
        "Use pictures and counting to add two small numbers.", List.of(
            new LessonQuestion("Maya has 2 apples. Her friend gives her 3 more. How many apples does Maya have?",
                List.of("4", "5", "6"), 1),
            new LessonQuestion("What is 4 + 1?", List.of("3", "4", "5"), 2),
            new LessonQuestion("What is 3 + 3?", List.of("5", "6", "7"), 1))));

    register(new LessonDefinition("G1-SUB-01", "MATH", 2, "Subtracting within 10",
        "Take away objects and count what is left.", List.of(
            new LessonQuestion("Leo has 5 stickers and gives away 2. How many does he have left?",
                List.of("2", "3", "4"), 1),
            new LessonQuestion("What is 6 - 4?", List.of("1", "2", "3"), 1),
            new LessonQuestion("What is 9 - 3?", List.of("5", "6", "7"), 1))));

    register(new LessonDefinition("G1-ENG-01", "ENGLISH", 1, "Letter sounds: A to E",
        "Match letters to their beginning sounds.", List.of(
            new LessonQuestion("Which word starts with the same sound as 'Apple'?",
                List.of("Dog", "Ant", "Cat"), 1),
            new LessonQuestion("Which word starts with the same sound as 'Ball'?",
                List.of("Bear", "Fish", "Sun"), 0),
            new LessonQuestion("Which word starts with the same sound as 'Egg'?",
                List.of("Elephant", "Moon", "Toy"), 0))));

    register(new LessonDefinition("G1-ENG-02", "ENGLISH", 2, "Simple sight words",
        "Recognize common words by sight.", List.of(
            new LessonQuestion("Which word means 'a color of the sky'?", List.of("Blue", "Run", "Big"), 0),
            new LessonQuestion("Which word means 'the opposite of small'?", List.of("Cat", "Big", "Sit"), 1),
            new LessonQuestion("Which word means 'to move quickly on foot'?", List.of("Run", "Blue", "Sit"), 0))));
  }

  private void register(LessonDefinition lesson) {
    lessons.put(lesson.code(), lesson);
  }

  public List<LessonDefinition> all() {
    return lessons.values().stream()
        .sorted(Comparator.comparing(LessonDefinition::subject).thenComparing(LessonDefinition::order))
        .toList();
  }

  public Optional<LessonDefinition> find(String code) {
    return Optional.ofNullable(lessons.get(code));
  }

  public Optional<String> subjectOf(String code) {
    return find(code).map(LessonDefinition::subject);
  }
}
