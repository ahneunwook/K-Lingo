package com.kdopamine.app.domain.word.service;

import com.kdopamine.app.domain.word.dto.response.WordCategoryRes;
import com.kdopamine.app.domain.word.repository.WordCategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class WordCategoryService {

    private final WordCategoryRepository wordCategoryRepository;

    @Transactional(readOnly = true)
    public List<WordCategoryRes> getCategories() {
        return wordCategoryRepository.findAllByOrderByDisplayOrderAsc().stream().map(WordCategoryRes::from).toList();
    }


}
