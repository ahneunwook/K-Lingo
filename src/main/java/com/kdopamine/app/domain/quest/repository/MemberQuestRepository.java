package com.kdopamine.app.domain.quest.repository;

import com.kdopamine.app.domain.member.entity.Member;
import com.kdopamine.app.domain.quest.entity.MemberQuest;
import com.kdopamine.app.domain.quest.entity.QuestType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface MemberQuestRepository extends JpaRepository<MemberQuest, Long> {

    @Query("SELECT COUNT(mq) > 0 FROM MemberQuest mq " +
            "WHERE mq.member = :member AND mq.questDate = :questDate")
    boolean existsByMemberAndQuestDate(
            @Param("member") Member member,
            @Param("questDate") LocalDate questDate);

    @Query("SELECT mq FROM MemberQuest mq " +
            "JOIN FETCH mq.quest " +
            "WHERE mq.member = :member " +
            "AND mq.questDate = :questDate")
    List<MemberQuest> findAllByMemberAndQuestDate(
            @Param("member") Member member,
            @Param("questDate") LocalDate questDate);

    @Query("SELECT mq from MemberQuest mq " +
            "JOIN mq.quest q " +
            "WHERE mq.member.id = :memberId " +
            "AND mq.questDate = :date " +
            "AND mq.isCompleted = false " +
            "AND q.questType = :type")
    List<MemberQuest> findPendingQuestByMemberAndType(
            @Param("memberId") Long memberId,
            @Param("date") LocalDate date,
            @Param("type") QuestType type);
}
