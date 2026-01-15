package com.kdopamine.app.domain.studylog.repository;

import com.kdopamine.app.domain.studylog.entity.MemberStageProgress;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MemberStageProgressRepository extends JpaRepository<MemberStageProgress, Long> {
    Optional<MemberStageProgress> findByMemberIdAndStageId(Long memberId, Long stageId);

}
