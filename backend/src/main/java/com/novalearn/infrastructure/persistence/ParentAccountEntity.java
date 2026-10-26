package com.novalearn.infrastructure.persistence;
import com.novalearn.domain.auth.Role; import jakarta.persistence.*; import java.util.UUID;
@Entity @Table(name = "parent_accounts") public class ParentAccountEntity {
 @Id private UUID id; @Column(nullable = false, unique = true, length = 320) private String email; @Column(name = "password_hash", nullable = false) private String passwordHash; @Enumerated(EnumType.STRING) @Column(nullable = false, length = 20) private Role role;
 protected ParentAccountEntity() { } public ParentAccountEntity(UUID id, String email, String passwordHash, Role role) { this.id=id; this.email=email; this.passwordHash=passwordHash; this.role=role; }
 public UUID getId(){return id;} public String getEmail(){return email;} public String getPasswordHash(){return passwordHash;} public Role getRole(){return role;}
}
