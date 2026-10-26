package com.novalearn.application.child;

import com.novalearn.domain.child.ChildProfile; import org.springframework.stereotype.Service; import org.springframework.transaction.annotation.Transactional; import java.time.LocalDate; import java.util.List; import java.util.UUID;
@Service public class ChildService {
 private final ChildProfileRepository children; public ChildService(ChildProfileRepository children) { this.children = children; }
 @Transactional public ChildProfile create(UUID parentId, String displayName, LocalDate birthDate) { return children.save(new ChildProfile(UUID.randomUUID(), parentId, displayName.trim(), birthDate)); }
 @Transactional(readOnly = true) public List<ChildProfile> list(UUID parentId) { return children.findByParentId(parentId); }
}
