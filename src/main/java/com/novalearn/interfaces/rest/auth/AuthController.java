package com.novalearn.interfaces.rest.auth;
import com.novalearn.application.auth.AuthService; import io.swagger.v3.oas.annotations.tags.Tag; import jakarta.validation.constraints.*; import org.springframework.http.*; import org.springframework.web.bind.annotation.*; import java.util.UUID;
@RestController @RequestMapping("/api/v1/auth") @Tag(name="Authentication") public class AuthController {
 private final AuthService auth; public AuthController(AuthService auth){this.auth=auth;}
 @PostMapping("/register") @ResponseStatus(HttpStatus.CREATED) public AuthResponse register(@RequestBody @jakarta.validation.Valid RegisterRequest request){return map(auth.register(request.email(),request.password()));}
 @PostMapping("/login") public AuthResponse login(@RequestBody @jakarta.validation.Valid LoginRequest request){return map(auth.authenticate(request.email(),request.password()));}
 private AuthResponse map(AuthService.AuthResult r){return new AuthResponse(r.parentId(),r.email(),r.accessToken(),"Bearer");}
 public record RegisterRequest(@NotBlank @Email String email,@NotBlank @Size(min=12,max=72) String password){} public record LoginRequest(@NotBlank @Email String email,@NotBlank String password){} public record AuthResponse(UUID parentId,String email,String accessToken,String tokenType){}
}
