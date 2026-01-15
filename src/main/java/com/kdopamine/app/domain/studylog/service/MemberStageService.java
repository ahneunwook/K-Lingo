package com.kdopamine.app.domain.studylog.service;

import com.kdopamine.app.domain.auth.entity.Member;
import com.kdopamine.app.domain.auth.repository.MemberRepository;
import com.kdopamine.app.domain.quest.entity.QuestType;
import com.kdopamine.app.domain.quest.service.QuestService;
import com.kdopamine.app.domain.studylog.entity.MemberStageProgress;
import com.kdopamine.app.domain.studylog.repository.MemberStageProgressRepository;
import com.kdopamine.app.domain.word.entity.Stage;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MemberStageService {

    private final MemberStageProgressRepository memberStageProgressRepository;
    private final MemberRepository memberRepository;
    private final QuestService questService;

    @Transactional
    public void saveOrUpdateProgress(Long memberId, Stage stage, int score, boolean isPassed) {
        // 이미 기록이 있는지 확인
        MemberStageProgress progress = memberStageProgressRepository
                .findByMemberIdAndStageId(memberId, stage.getId())
                .orElseGet(() -> {
                    Member member = memberRepository.getReferenceById(memberId);
                    MemberStageProgress newProgress = MemberStageProgress.create(member, stage);
                    return memberStageProgressRepository.save(newProgress);
                });

        progress.updateProgress(score, isPassed);

        if (isPassed) {
            questService.handleAction(memberId, QuestType.STAGE_CLEAR);
        }
    }
}
