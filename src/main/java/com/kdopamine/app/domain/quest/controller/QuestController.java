package com.kdopamine.app.domain.quest.controller;

import com.kdopamine.app.domain.quest.dto.response.QuestResponse;
import com.kdopamine.app.domain.quest.dto.response.QuestRewardResponse;
import com.kdopamine.app.domain.quest.entity.MemberQuest;
import com.kdopamine.app.domain.quest.service.QuestService;
import com.kdopamine.app.global.response.ApiResponse;
import com.kdopamine.app.global.security.CustomUserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/quests")
@RequiredArgsConstructor
public class QuestController {

    private final QuestService questService;

    @GetMapping("/today")
    public ResponseEntity<ApiResponse<List<QuestResponse>>> getTodayQuests(@AuthenticationPrincipal CustomUserPrincipal member) {
        List<QuestResponse> quests = questService.getTodayQuests(member.getId());
        return ResponseEntity.ok(ApiResponse.success(quests, "퀘스트 조회 성공"));
    }

    @PostMapping("/{memberQuestId}/claim")
    public ResponseEntity<ApiResponse<QuestRewardResponse>> claimReward(
            @PathVariable Long memberQuestId,
            @AuthenticationPrincipal CustomUserPrincipal member)
    {
        QuestRewardResponse questRewardResponse = questService.claimReward(memberQuestId, member.getId());

        return ResponseEntity.ok(ApiResponse.success(questRewardResponse, "보상 완료"));
    }

}
