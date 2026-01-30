package com.kdopamine.app.domain.sentence.repository;

import com.kdopamine.app.domain.sentence.entity.Sentence;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface SentenceRepository extends JpaRepository<Sentence, Long> {

    @Query(value = "SELECT * FROM sentence ORDER BY RANDOM() LIMIT :count", nativeQuery = true)
    List<Sentence> findRandomSentences(@Param("count") int count);

    @Query(value = "SELECT * FROM sentence WHERE chapter_id = :chapterId ORDER BY RANDOM() LIMIT :count", nativeQuery = true)
    List<Sentence> findByChapterRandom(@Param("chapterId") Long chapterId, @Param("count") int count);
}
