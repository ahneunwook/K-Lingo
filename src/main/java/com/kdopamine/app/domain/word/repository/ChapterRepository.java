package com.kdopamine.app.domain.word.repository;

import com.kdopamine.app.domain.word.entity.Chapter;
import com.kdopamine.app.global.entity.SectionType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ChapterRepository extends JpaRepository<Chapter, Long> {
    List<Chapter> findAllByTypeOrderByDisplayOrderAsc(SectionType type);
}
