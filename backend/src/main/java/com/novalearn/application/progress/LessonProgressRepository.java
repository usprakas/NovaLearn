package com.novalearn.application.progress;
import com.novalearn.domain.progress.LessonProgress; import java.util.List; import java.util.Optional; import java.util.UUID;
public interface LessonProgressRepository { Optional<LessonProgress> findByChildIdAndLessonCode(UUID childId, String lessonCode); LessonProgress save(LessonProgress progress); List<LessonProgress> findByChildId(UUID childId); }
