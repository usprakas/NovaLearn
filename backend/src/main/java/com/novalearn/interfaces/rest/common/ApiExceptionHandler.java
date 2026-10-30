package com.novalearn.interfaces.rest.common;
import com.novalearn.application.auth.*; import com.novalearn.application.catalog.LessonNotFoundException; import com.novalearn.application.common.ChildNotFoundException; import com.novalearn.application.homework.HomeworkScanUnavailableException; import com.novalearn.application.homework.InvalidHomeworkPhotoException; import com.novalearn.application.homework.InvalidHomeworkQuestionException; import com.novalearn.application.homework.UnreadableHomeworkPhotoException; import com.novalearn.application.progress.ExerciseNotFoundException; import com.novalearn.application.tutor.InvalidTutorQuestionException; import org.springframework.http.*; import org.springframework.web.bind.annotation.*; import java.time.Instant;
@RestControllerAdvice public class ApiExceptionHandler {
 @ExceptionHandler(AuthenticationException.class) ResponseEntity<ApiError> unauthorized(RuntimeException ex){return error(HttpStatus.UNAUTHORIZED,ex.getMessage());}
 @ExceptionHandler(ChildNotFoundException.class) ResponseEntity<ApiError> notFound(RuntimeException ex){return error(HttpStatus.NOT_FOUND,ex.getMessage());}
 @ExceptionHandler(LessonNotFoundException.class) ResponseEntity<ApiError> lessonNotFound(RuntimeException ex){return error(HttpStatus.NOT_FOUND,ex.getMessage());}
 @ExceptionHandler(ExerciseNotFoundException.class) ResponseEntity<ApiError> exerciseNotFound(RuntimeException ex){return error(HttpStatus.NOT_FOUND,ex.getMessage());}
 @ExceptionHandler(InvalidTutorQuestionException.class) ResponseEntity<ApiError> invalidQuestion(RuntimeException ex){return error(HttpStatus.BAD_REQUEST,ex.getMessage());}
 @ExceptionHandler(InvalidHomeworkQuestionException.class) ResponseEntity<ApiError> invalidHomeworkQuestion(RuntimeException ex){return error(HttpStatus.BAD_REQUEST,ex.getMessage());}
 @ExceptionHandler(InvalidHomeworkPhotoException.class) ResponseEntity<ApiError> invalidHomeworkPhoto(RuntimeException ex){return error(HttpStatus.BAD_REQUEST,ex.getMessage());}
 @ExceptionHandler(UnreadableHomeworkPhotoException.class) ResponseEntity<ApiError> unreadableHomeworkPhoto(RuntimeException ex){return error(HttpStatus.UNPROCESSABLE_ENTITY,ex.getMessage());}
 @ExceptionHandler(HomeworkScanUnavailableException.class) ResponseEntity<ApiError> homeworkScanUnavailable(RuntimeException ex){return error(HttpStatus.SERVICE_UNAVAILABLE,ex.getMessage());}
 @ExceptionHandler(EmailAlreadyRegisteredException.class) ResponseEntity<ApiError> conflict(RuntimeException ex){return error(HttpStatus.CONFLICT,ex.getMessage());}
 @ExceptionHandler(org.springframework.web.bind.MethodArgumentNotValidException.class) ResponseEntity<ApiError> validation(org.springframework.web.bind.MethodArgumentNotValidException ex){return error(HttpStatus.BAD_REQUEST,ex.getBindingResult().getFieldErrors().getFirst().getDefaultMessage());}
 private ResponseEntity<ApiError> error(HttpStatus status,String detail){return ResponseEntity.status(status).body(new ApiError(Instant.now(),status.value(),detail));} public record ApiError(Instant timestamp,int status,String detail){}
}
