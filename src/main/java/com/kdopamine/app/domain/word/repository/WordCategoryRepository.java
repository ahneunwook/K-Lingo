package com.kdopamine.app.domain.word.repository;

import com.kdopamine.app.domain.word.entity.WordCategory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface WordCategoryRepository extends JpaRepository<WordCategory, Long> {
    List<WordCategory> findAllByOrderByDisplayOrderAsc();

}
