package com.novalearn.application.child;

import com.novalearn.domain.child.ChildProfile; import java.util.List; import java.util.UUID;
public interface ChildProfileRepository { ChildProfile save(ChildProfile profile); List<ChildProfile> findByParentId(UUID parentId); boolean belongsToParent(UUID childId, UUID parentId); }
