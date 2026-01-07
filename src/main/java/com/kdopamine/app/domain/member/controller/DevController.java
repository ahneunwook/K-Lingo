package com.kdopamine.app.domain.member.controller;

import com.kdopamine.app.domain.member.entity.Member;
import com.kdopamine.app.domain.member.repository.MemberRepository;
import com.kdopamine.app.global.response.ApiResponse;
import com.kdopamine.app.global.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/dev")
@RequiredArgsConstructor
@Profile("local")
public class DevController {

    private final JwtUtil jwtUtil;
    private final MemberRepository memberRepository;

    @GetMapping("/login")
    public ResponseEntity<ApiResponse<String>> devLogin() {
        // 1. DB에 테스트용 유저가 없으면 만듦
        Member testMember = memberRepository.findByEmail("test@test.com")
                .orElseGet(() -> memberRepository.save(Member.createSocialMember("test@test.com", "테스트유저",  "GOOGLE", "DEV_12345")));

        // 2. 구글 인증 과정 생략하고 바로 우리 서버 토큰 발급!
        String accessToken = jwtUtil.createAccessToken(testMember.getId(), testMember.getEmail(), testMember.getRole());

        return ResponseEntity.ok(ApiResponse.success(accessToken, "프리패스 토큰 발급 완료"));
    }
}
