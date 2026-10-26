package com.novalearn.infrastructure.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "badges")
public class BadgeEntity {
  @Id
  @Column(length = 50)
  private String code;
  @Column(nullable = false, length = 100)
  private String name;
  @Column(nullable = false, length = 300)
  private String description;

  protected BadgeEntity() { }

  public BadgeEntity(String code, String name, String description) {
    this.code = code;
    this.name = name;
    this.description = description;
  }

  public String getCode() { return code; }
  public String getName() { return name; }
  public String getDescription() { return description; }
}
