package com.kdopamine.app.domain.word.repository;

import com.kdopamine.app.domain.word.entity.Word;
import com.kdopamine.app.domain.word.entity.WordStage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface WordStageRepository extends JpaRepository<WordStage, Long> {
}
