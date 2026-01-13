package com.kdopamine.app.domain.studylog.service;

import com.kdopamine.app.domain.member.entity.Member;
import com.kdopamine.app.domain.member.repository.MemberRepository;
import com.kdopamine.app.domain.studylog.entity.MemberStageProgress;
import com.kdopamine.app.domain.studylog.repository.MemberStageProgressRepository;
import com.kdopamine.app.domain.word.entity.WordStage;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MemberStageService {

    private final MemberStageProgressRepository memberStageProgressRepository;
    private final MemberRepository memberRepository;

    public void saveOrUpdateProgress(Long memberId, WordStage stage, int score, boolean isPassed) {
        // 이미 기록이 있는지 확인
        MemberStageProgress progress = memberStageProgressRepository.findByMemberIdAndWordStageId(memberId, stage.getId())
                .orElse(null);

        if (progress == null) {
            Member member = memberRepository.getReferenceById(memberId);

            progress = MemberStageProgress.create(member, stage);
            progress.updateProgress(score, isPassed);

            memberStageProgressRepository.save(progress);
        } else {
            progress.updateProgress(score, isPassed);
        }
    }
}
