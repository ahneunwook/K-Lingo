package com.kdopamine.app.domain.word.service;

import com.kdopamine.app.domain.word.dto.response.StageRes;
import com.kdopamine.app.domain.word.repository.ChapterRepository;
import com.kdopamine.app.domain.word.repository.StageRepository;
import com.kdopamine.app.domain.word.repository.StageRepositoryCustom;
import com.kdopamine.app.global.entity.SectionType;
import com.kdopamine.app.global.exception.BusinessException;
import com.kdopamine.app.global.exception.ErrorCode;
import com.kdopamine.app.global.security.CustomUserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class StageService {

    private final StageRepositoryCustom stageRepositoryCustom;
    private final StageRepository stageRepository;
    private final ChapterRepository chapterRepository;

    @Transactional(readOnly = true)
    public List<StageRes> getStages(Long chapterId, CustomUserPrincipal user) {
        if (!chapterRepository.existsById(chapterId)) {
            throw new BusinessException(ErrorCode.CATEGORY_NOT_FOUND);
        }

        List<StageRes> stageRes = stageRepositoryCustom.findStagesWithProgress(chapterId, user.getId());

        // 첫 스테이지는 항상 잠금 해제 정책
        boolean isPreviousCleared = true;

        for (StageRes stage : stageRes) {
            if (!isPreviousCleared) {
                stage.setIsLocked(true);
            }

            if (Boolean.TRUE.equals(stage.getIsCleared())) {
                isPreviousCleared = true;
            } else {
                isPreviousCleared = false;
            }
        }
        return stageRes;
    }

    @Transactional(readOnly = true)
    public long getTotalStageCount(SectionType type) {
        return stageRepository.countTotalStagesByType(type);
    }
}
