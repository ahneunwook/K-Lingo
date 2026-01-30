package com.kdopamine.app.domain.studylog.service;

import com.kdopamine.app.domain.auth.entity.Member;
import com.kdopamine.app.domain.auth.repository.MemberRepository;
import com.kdopamine.app.domain.quest.entity.QuestType;
import com.kdopamine.app.domain.quest.service.QuestService;
import com.kdopamine.app.domain.studylog.entity.MemberWordProgress;
import com.kdopamine.app.domain.studylog.repository.MemberWordProgressRepository;
import com.kdopamine.app.domain.word.entity.Stage;
import com.kdopamine.app.global.entity.SectionType;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MemberStageProgressService {

    private final MemberWordProgressRepository memberWordProgressRepository;
    private final MemberRepository memberRepository;
    private final QuestService questService;

    @Transactional
    public void saveOrUpdateProgress(Long memberId, Stage stage, int score, boolean isPassed) {
        // 이미 기록이 있는지 확인
        MemberWordProgress progress = memberWordProgressRepository
                .findByMemberIdAndStageId(memberId, stage.getId())
                .orElseGet(() -> {
                    Member member = memberRepository.getReferenceById(memberId);
                    MemberWordProgress newProgress = MemberWordProgress.create(member, stage);
                    return memberWordProgressRepository.save(newProgress);
                });

        progress.updateProgress(score, isPassed);

        if (isPassed) {
            questService.handleAction(memberId, QuestType.STAGE_CLEAR);
        }
    }

    @Transactional(readOnly = true)
    public long getClearedStageCount(Long memberId, SectionType type) {
        return memberWordProgressRepository.countClearedStagesByMemberAndType(memberId, type);
    }
}
