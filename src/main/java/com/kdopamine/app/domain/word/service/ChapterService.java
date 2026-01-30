package com.kdopamine.app.domain.word.service;

import com.kdopamine.app.domain.word.dto.response.ChapterRes;
import com.kdopamine.app.domain.word.entity.Chapter;
import com.kdopamine.app.domain.word.repository.ChapterRepository;
import com.kdopamine.app.global.entity.SectionType;
import com.kdopamine.app.global.exception.BusinessException;
import com.kdopamine.app.global.exception.ErrorCode;
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

    @Transactional(readOnly = true)
    public Chapter findChapterId(Long chapterId){
        return chapterRepository.findById(chapterId)
                .orElseThrow(() -> new BusinessException(ErrorCode.CHAPTER_NOT_FOUND));

    }

}
