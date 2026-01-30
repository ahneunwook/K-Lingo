package com.kdopamine.app.domain.studylog.repository;

import com.kdopamine.app.domain.studylog.entity.MemberSentenceProgress;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MemberSentenceProgressRepository extends JpaRepository<MemberSentenceProgress, Long> {
    Optional<MemberSentenceProgress> findByMemberIdAndChapterId(Long memberId, Long chapterId);

}
