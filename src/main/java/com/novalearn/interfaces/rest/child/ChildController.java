package com.novalearn.interfaces.rest.child;
import com.novalearn.application.child.ChildService; import com.novalearn.domain.child.ChildProfile; import io.swagger.v3.oas.annotations.tags.Tag; import jakarta.validation.constraints.*; import org.springframework.http.*; import org.springframework.security.core.annotation.AuthenticationPrincipal; import org.springframework.web.bind.annotation.*; import java.time.LocalDate; import java.util.*;
@RestController @RequestMapping("/api/v1/children") @Tag(name="Children") public class ChildController { private final ChildService children; public ChildController(ChildService children){this.children=children;}
 @PostMapping @ResponseStatus(HttpStatus.CREATED) public ChildResponse create(@AuthenticationPrincipal UUID parentId,@RequestBody @jakarta.validation.Valid CreateChildRequest request){return map(children.create(parentId,request.displayName(),request.birthDate()));}
 @GetMapping public List<ChildResponse> list(@AuthenticationPrincipal UUID parentId){return children.list(parentId).stream().map(ChildController::map).toList();}
 private static ChildResponse map(ChildProfile p){return new ChildResponse(p.id(),p.displayName(),p.birthDate());} public record CreateChildRequest(@NotBlank @Size(max=60) String displayName,@NotNull @Past LocalDate birthDate){} public record ChildResponse(UUID id,String displayName,LocalDate birthDate){}
}
