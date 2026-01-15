package com.kdopamine.app.domain.word.repository;

import com.kdopamine.app.domain.word.dto.response.StageRes;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StageRepositoryCustom {
    List<StageRes> findStagesWithProgress(Long categoryId, Long memberId);
}
