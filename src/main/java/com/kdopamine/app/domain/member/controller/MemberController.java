package com.kdopamine.app.domain.member.controller;

import com.kdopamine.app.domain.member.dto.response.MemberProgressResponse;
import com.kdopamine.app.domain.member.service.MemberService;
import com.kdopamine.app.global.response.ApiResponse;
import com.kdopamine.app.global.security.CustomUserPrincipal;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/members/me")
@RequiredArgsConstructor
@Slf4j
public class MemberController {

    private final MemberService memberService;

    @GetMapping("/progress")
    public ResponseEntity<ApiResponse<MemberProgressResponse>> getMyProgress(
            @AuthenticationPrincipal CustomUserPrincipal member
    ) {
        MemberProgressResponse response = memberService.getProgress(member.getId());

        return ResponseEntity.ok(ApiResponse.success(response, "조회 성공"));
    }
}
