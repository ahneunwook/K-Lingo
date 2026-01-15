package com.kdopamine.app.domain.member.service;

import com.kdopamine.app.domain.auth.entity.Member;
import com.kdopamine.app.domain.auth.service.MemberReader;
import com.kdopamine.app.domain.dailytip.dto.response.DailyTipRes;
import com.kdopamine.app.domain.dailytip.entity.Tip;
import com.kdopamine.app.domain.dailytip.repository.TipRepository;
import com.kdopamine.app.domain.dailytip.service.TipService;
import com.kdopamine.app.domain.member.dto.response.MemberProgressResponse;
import com.kdopamine.app.domain.quest.entity.QuestType;
import com.kdopamine.app.domain.quest.service.QuestService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MemberService {

    private final MemberReader memberReader;
    private final QuestService questService;
    private final TipService tipService;

    @Transactional
    public MemberProgressResponse getProgress(Long memberId) {
        Member member = memberReader.getMember(memberId);

        member.checkAttendance();
        questService.handleAction(memberId, QuestType.LOGIN);

        DailyTipRes dailyTipRes = tipService.dailyTipRes();

        return MemberProgressResponse.from(member, dailyTipRes);
    }
}
