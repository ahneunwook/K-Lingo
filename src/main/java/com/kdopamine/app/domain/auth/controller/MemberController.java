package com.kdopamine.app.domain.auth.controller;

import com.kdopamine.app.domain.auth.dto.request.GoogleLoginRequest;
import com.kdopamine.app.domain.auth.dto.request.RefreshTokenRequest;
import com.kdopamine.app.domain.auth.dto.response.GoogleTokenResponse;
import com.kdopamine.app.domain.auth.service.OAuthService;
import com.kdopamine.app.global.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping
@RequiredArgsConstructor
@Slf4j
public class MemberController {

    private final OAuthService oAuthService;

    // 사용자가 구글 로그인 성공하면, 구글이 이 주소로 사용자를 강제 이동시킵니다
    @PostMapping("/auth/login/google")
    public ResponseEntity<ApiResponse<GoogleTokenResponse>> googleLogin(@RequestBody GoogleLoginRequest request) {
        GoogleTokenResponse tokens = oAuthService.googleLogin(request.getIdToken());

        return ResponseEntity.ok(ApiResponse.success(tokens, "구글 로그인 성공"));
    }

    @PostMapping("/auth/refresh")
    public ResponseEntity<ApiResponse<GoogleTokenResponse>> refreshToken(@RequestBody RefreshTokenRequest request) {
        if (request.getRefreshToken() == null || request.getRefreshToken().isEmpty()) {
            System.out.println("리프레쉬 토큰이 필요함");
        }

        System.out.println("🔄 Refresh 요청: " + request.getRefreshToken().substring(0, 20) + "...");

        GoogleTokenResponse tokens = oAuthService.refreshAccessToken(request.getRefreshToken());

        return ResponseEntity.ok(ApiResponse.success(tokens, "토큰 갱신 성공"));
    }
}
