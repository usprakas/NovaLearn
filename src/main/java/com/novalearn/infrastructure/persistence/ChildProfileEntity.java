package com.novalearn.infrastructure.persistence;
import jakarta.persistence.*; import java.time.LocalDate; import java.util.UUID;
@Entity @Table(name = "child_profiles") public class ChildProfileEntity {
 @Id private UUID id; @Column(name="parent_id", nullable=false) private UUID parentId; @Column(name="display_name", nullable=false, length=60) private String displayName; @Column(name="birth_date", nullable=false) private LocalDate birthDate;
 protected ChildProfileEntity() { } public ChildProfileEntity(UUID id, UUID parentId, String displayName, LocalDate birthDate){this.id=id;this.parentId=parentId;this.displayName=displayName;this.birthDate=birthDate;}
 public UUID getId(){return id;} public UUID getParentId(){return parentId;} public String getDisplayName(){return displayName;} public LocalDate getBirthDate(){return birthDate;}
}
