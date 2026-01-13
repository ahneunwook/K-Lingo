package com.kdopamine.app.domain.word.service;

import com.kdopamine.app.domain.word.dto.response.WordQuizRes;
import com.kdopamine.app.domain.word.dto.response.WordStageRes;
import com.kdopamine.app.domain.word.entity.QuizType;
import com.kdopamine.app.domain.word.entity.Word;
import com.kdopamine.app.domain.word.repository.WordCategoryRepository;
import com.kdopamine.app.domain.word.repository.WordRepository;
import com.kdopamine.app.domain.word.repository.WordStageRepositoryCustom;
import com.kdopamine.app.global.exception.BusinessException;
import com.kdopamine.app.global.exception.ErrorCode;
import com.kdopamine.app.global.security.CustomUserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WordStageService {

    private final WordStageRepositoryCustom wordStageRepositoryCustom;
    private final WordCategoryRepository wordCategoryRepository;

    @Transactional(readOnly = true)
    public List<WordStageRes> getStages(Long categoryId, CustomUserPrincipal user) {
        if (!wordCategoryRepository.existsById(categoryId)) {
            throw new BusinessException(ErrorCode.CATEGORY_NOT_FOUND);
        }

        List<WordStageRes> wordStageRes = wordStageRepositoryCustom.findStagesWithProgress(categoryId, user.getId());

        // 첫 스테이지는 항상 잠금 해제 정책
        boolean isPreviousCleared = true;

        for (WordStageRes stage : wordStageRes) {
            if (!isPreviousCleared) {
                stage.setIsLocked(true);
            }

            if (Boolean.TRUE.equals(stage.getIsCleared())) {
                isPreviousCleared = true;
            } else {
                isPreviousCleared = false;
            }
        }
        return wordStageRes;
    }
}
