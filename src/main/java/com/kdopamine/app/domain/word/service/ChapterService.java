package com.kdopamine.app.domain.word.service;

import com.kdopamine.app.domain.word.dto.response.ChapterRes;
import com.kdopamine.app.domain.word.repository.ChapterRepository;
import com.kdopamine.app.global.entity.SectionType;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ChapterService {

    private final ChapterRepository chapterRepository;

    @Transactional(readOnly = true)
    public List<ChapterRes> getChapters(SectionType type) {
        return chapterRepository.findAllByTypeOrderByDisplayOrderAsc(type).stream().map(ChapterRes::from).toList();
    }
}
