package com.kdopamine.app.domain.word.repository;

import com.kdopamine.app.domain.word.dto.response.WordStageRes;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WordStageRepositoryCustom {
    List<WordStageRes> findStagesWithProgress(Long categoryId, Long memberId);
}
