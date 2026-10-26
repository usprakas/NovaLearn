package com.novalearn.interfaces.rest.auth;

import com.novalearn.application.auth.AuthService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
@Tag(name = "Authentication")
public class AuthController {

  private final AuthService auth;

  public AuthController(AuthService auth) {
    this.auth = auth;
  }

  @PostMapping("/register")
  @ResponseStatus(HttpStatus.CREATED)
  public AuthResponse register(@RequestBody @Valid RegisterRequest request) {
    return map(auth.register(request.email(), request.password()));
  }

  @PostMapping("/login")
  public AuthResponse login(@RequestBody @Valid LoginRequest request) {
    return map(auth.authenticate(request.email(), request.password()));
  }

  /** Rotates the presented refresh token: it is revoked and a new access/refresh pair is issued. */
  @PostMapping("/refresh")
  public AuthResponse refresh(@RequestBody @Valid RefreshRequest request) {
    return map(auth.refresh(request.refreshToken()));
  }

  @PostMapping("/logout")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void logout(@RequestBody @Valid RefreshRequest request) {
    auth.logout(request.refreshToken());
  }

  private AuthResponse map(AuthService.AuthResult result) {
    return new AuthResponse(result.parentId(), result.email(), result.accessToken(), result.refreshToken(), "Bearer");
  }

  public record RegisterRequest(@NotBlank @Email String email, @NotBlank @Size(min = 12, max = 72) String password) { }

  public record LoginRequest(@NotBlank @Email String email, @NotBlank String password) { }

  public record RefreshRequest(@NotBlank String refreshToken) { }

  public record AuthResponse(UUID parentId, String email, String accessToken, String refreshToken, String tokenType) { }
}
