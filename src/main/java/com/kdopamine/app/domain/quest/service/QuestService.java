package com.kdopamine.app.domain.quest.service;

import com.kdopamine.app.domain.auth.entity.Member;
import com.kdopamine.app.domain.auth.service.MemberReader;
import com.kdopamine.app.domain.quest.dto.response.QuestResponse;
import com.kdopamine.app.domain.quest.dto.response.QuestRewardResponse;
import com.kdopamine.app.domain.quest.entity.MemberQuest;
import com.kdopamine.app.domain.quest.entity.Quest;
import com.kdopamine.app.domain.quest.entity.QuestPeriod;
import com.kdopamine.app.domain.quest.entity.QuestType;
import com.kdopamine.app.domain.quest.repository.MemberQuestRepository;
import com.kdopamine.app.domain.quest.repository.QuestRepository;
import com.kdopamine.app.global.exception.BusinessException;
import com.kdopamine.app.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;

@Service
@RequiredArgsConstructor
public class QuestService {

    private final QuestRepository questRepository;
    private final MemberQuestRepository memberQuestRepository;
    private final MemberReader memberReader;

    @Transactional
    public List<QuestResponse> getTodayQuests(Long memberId) {
        Member member = memberReader.getMember(memberId);

        assignDailyQuests(member);

        List<MemberQuest> memberQuests = memberQuestRepository.findAllByMemberAndQuestDate(member, LocalDate.now());

        return memberQuests.stream().map(QuestResponse::from).toList();
    }

    public void assignDailyQuests(Member member) {
        LocalDate today = LocalDate.now();

        if (memberQuestRepository.existsByMemberAndQuestDate(member, today)) {
            return;
        }

        List<Quest> allQuests = questRepository.findAllByPeriodAndActiveTrue(QuestPeriod.DAILY);

        // 리스트를 섞어서 앞에서 3개만 가져옴
        // (만약 퀘스트가 3개보다 적으면 그냥 있는 거 다 가져옴)
        Collections.shuffle(allQuests);
        int pickCount = Math.min(allQuests.size(), 3);
        List<Quest> selectedQuests = allQuests.subList(0, pickCount);

        List<MemberQuest> memberQuests = selectedQuests.stream()
                .map(quest -> MemberQuest.create(member, quest, today))
                .toList();

        memberQuestRepository.saveAll(memberQuests);
    }

    @Transactional
    public void handleAction(Long memberId, QuestType type, int correctCount) {
        LocalDate today = LocalDate.now();

        List<MemberQuest> targetQuests = memberQuestRepository.findPendingQuestByMemberAndType(memberId, today, type);

        for (MemberQuest mq : targetQuests) {
            mq.increaseProgress(correctCount);
        }
    }

    @Transactional
    public void handleAction(Long memberId, QuestType type) {
        handleAction(memberId, type, 1);
    }

    @Transactional
    public QuestRewardResponse claimReward(Long memberQuestId, Long memberId) {
        MemberQuest memberQuest = memberQuestRepository.findById(memberQuestId)
                .orElseThrow(() -> new BusinessException(ErrorCode.QUEST_NOT_FOUND));

        if (!memberQuest.isOwnedBy(memberId)) {
            throw new BusinessException(ErrorCode.FORBIDDEN);
        }

        memberQuest.claimReward();

        Member member = memberReader.getMember(memberId);
        int previousLevel = member.getLevel();
        int rewardXp = memberQuest.getQuest().getRewardXp();

        member.gainXp(rewardXp);

        boolean isLevelUp = member.getLevel() > previousLevel;

        return QuestRewardResponse.of(rewardXp, member, isLevelUp, previousLevel);
    }
}