package com.novalearn.application.catalog;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.novalearn.domain.catalog.LessonDefinition;
import org.junit.jupiter.api.Test;

class LessonCatalogTest {

  @Test
  void listsEveryRegisteredLessonSortedBySubjectThenOrder() {
    LessonCatalog catalog = new LessonCatalog();

    var lessons = catalog.all();

    assertThat(lessons).extracting(LessonDefinition::code).contains("G1-ADD-01", "G1-SUB-01", "G1-ENG-01", "G1-ENG-02");
    assertThat(lessons).isSortedAccordingTo(
        (a, b) -> a.subject().equals(b.subject()) ? Integer.compare(a.order(), b.order()) : a.subject().compareTo(b.subject()));
  }

  @Test
  void findsALessonByCodeWithItsQuestions() {
    LessonCatalog catalog = new LessonCatalog();

    LessonDefinition lesson = catalog.find("G1-ADD-01").orElseThrow();

    assertThat(lesson.subject()).isEqualTo("MATH");
    assertThat(lesson.questions()).isNotEmpty();
  }

  @Test
  void reportsTheSubjectForAKnownLessonCode() {
    LessonCatalog catalog = new LessonCatalog();

    assertThat(catalog.subjectOf("G1-ENG-01")).contains("ENGLISH");
    assertThat(catalog.subjectOf("NOT-A-REAL-CODE")).isEmpty();
  }

  @Test
  void throwsLessonNotFoundExceptionForAnUnknownCode() {
    LessonCatalog catalog = new LessonCatalog();

    assertThatThrownBy(() -> catalog.find("NOPE").orElseThrow(LessonNotFoundException::new))
        .isInstanceOf(LessonNotFoundException.class);
  }
}
