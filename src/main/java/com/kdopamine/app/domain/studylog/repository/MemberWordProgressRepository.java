package com.kdopamine.app.domain.studylog.repository;

import com.kdopamine.app.domain.studylog.entity.MemberWordProgress;
import com.kdopamine.app.global.entity.SectionType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface MemberWordProgressRepository extends JpaRepository<MemberWordProgress, Long> {
    Optional<MemberWordProgress> findByMemberIdAndStageId(Long memberId, Long stageId);

    @Query("SELECT COUNT(msp) FROM MemberWordProgress msp " +
            "WHERE msp.member.id = :memberId " +
            "AND msp.isCleared = true " +
            "AND msp.stage.chapter.type = :type")
    long countClearedStagesByMemberAndType(@Param("memberId") Long memberId,
                                           @Param("type") SectionType type);
}