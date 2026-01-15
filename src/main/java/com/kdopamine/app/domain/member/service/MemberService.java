package com.kdopamine.app.domain.member.service;

import com.kdopamine.app.domain.auth.entity.Member;
import com.kdopamine.app.domain.auth.service.MemberReader;
import com.kdopamine.app.domain.dailytip.dto.response.DailyTipRes;
import com.kdopamine.app.domain.dailytip.service.TipService;
import com.kdopamine.app.domain.member.dto.response.MemberProgressResponse;
import com.kdopamine.app.domain.member.dto.response.SectionProgressRes;
import com.kdopamine.app.domain.quest.entity.QuestType;
import com.kdopamine.app.domain.quest.service.QuestService;
import com.kdopamine.app.domain.studylog.service.MemberStageProgressService;
import com.kdopamine.app.domain.word.service.StageService;
import com.kdopamine.app.global.entity.SectionType;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MemberService {

    private final MemberReader memberReader;
    private final QuestService questService;
    private final TipService tipService;
    private final StageService stageService;
    private final MemberStageProgressService memberStageProgressService;

    @Transactional
    public MemberProgressResponse getProgress(Long memberId) {
        Member member = memberReader.getMember(memberId);

        member.checkAttendance();
        questService.handleAction(memberId, QuestType.LOGIN);

        DailyTipRes dailyTipRes = tipService.dailyTipRes();

        List<SectionProgressRes> sectionProgressList = calculateSectionProgress(memberId);

        return MemberProgressResponse.from(member, dailyTipRes, sectionProgressList);
    }

    public List<SectionProgressRes> calculateSectionProgress(Long memberId) {
        List<SectionProgressRes> list = new ArrayList<>();

        list.add(createSectionRes(memberId, SectionType.TOPIC, "Topics", "Basic Words"));

        list.add(createSectionRes(memberId, SectionType.SENTENCE, "Sentences", "Fill in Blanks"));

        list.add(createSectionRes(memberId, SectionType.KDRAMA, "K-Drama", "Learn w/ Drama"));

        list.add(createSectionRes(memberId, SectionType.KPOP, "K-Pop", "Sing along"));

        return list;
    }

    public SectionProgressRes createSectionRes(Long memberId, SectionType type, String title, String description){
       long totalCount = stageService.getTotalStageCount(type);

       long clearedCount = memberStageProgressService.getClearedStageCount(memberId, type);

        int progress = 0;
        if (totalCount > 0) {
            progress = (int) ((double) clearedCount / totalCount * 100);
        }

        return SectionProgressRes.of(title, description, type, progress);
    }

}
