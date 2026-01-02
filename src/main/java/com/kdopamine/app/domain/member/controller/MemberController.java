package com.kdopamine.app.domain.member.controller;

import com.kdopamine.app.domain.member.entity.Role;
import com.kdopamine.app.global.security.CustomUserPrincipal;
import com.kdopamine.app.global.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Slf4j
public class MemberController {

    private final JwtUtil jwtUtil;

    @GetMapping("/test-token/{userId}")
    public ResponseEntity<String> createTestToken(@PathVariable Long userId) {
        String token = jwtUtil.createAccessToken(userId, "test@gmail.com", Role.USER);

        return ResponseEntity.ok(token);
    }

    @GetMapping("/me")
    public ResponseEntity<?> getMyInfo(@AuthenticationPrincipal CustomUserPrincipal principal) {
        log.info("=== /me 엔드포인트 진입 ===");

        if (principal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("인증 실패: Principal이 비어있습니다.");
        }

        Map<String, Object> data = new HashMap<>();
        data.put("유저PK", principal.getId());
        data.put("이메일", principal.getEmail());
        data.put("권한", principal.getAuthorities());
        data.put("엔티티상태", principal.getMember() != null ? "연결완료" : "연결실패");

        return ResponseEntity.ok(data);
    }
}
