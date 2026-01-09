package com.kdopamine.app.domain.word.repository;

import com.kdopamine.app.domain.word.entity.Word;
import com.kdopamine.app.domain.word.entity.WordCategory;
import com.kdopamine.app.domain.word.entity.WordStage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface WordRepository extends JpaRepository<Word, Long> {
    boolean existsByWordStageAndKorean(WordStage wordStage, String korean);

    List<Word> findByWordStageId(Long stageId);
}
