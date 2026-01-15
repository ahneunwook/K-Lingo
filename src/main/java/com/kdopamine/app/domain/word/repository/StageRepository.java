package com.kdopamine.app.domain.word.repository;

import com.kdopamine.app.domain.word.entity.Chapter;
import com.kdopamine.app.domain.word.entity.Stage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface StageRepository extends JpaRepository<Stage, Long> {
    Optional<Stage> findByChapterAndStageOrder(Chapter chapter, Integer stageOrder);

}
