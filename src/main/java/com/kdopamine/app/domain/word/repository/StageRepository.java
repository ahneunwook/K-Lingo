package com.kdopamine.app.domain.word.repository;

import com.kdopamine.app.domain.word.entity.Chapter;
import com.kdopamine.app.domain.word.entity.Stage;
import com.kdopamine.app.global.entity.SectionType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface StageRepository extends JpaRepository<Stage, Long> {
    Optional<Stage> findByChapterAndStageOrder(Chapter chapter, Integer stageOrder);

    @Query("SELECT COUNT(s) FROM Stage s WHERE s.chapter.type = :type")
    long countTotalStagesByType(@Param("type") SectionType type);
}
