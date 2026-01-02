package com.kdopamine.app.domain.member.service;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.kdopamine.app.domain.member.dto.response.GoogleTokenResponse;
import com.kdopamine.app.domain.member.entity.Member;
import com.kdopamine.app.domain.member.repository.MemberRepository;
import com.kdopamine.app.global.exception.BusinessException;
import com.kdopamine.app.global.exception.ErrorCode;
import com.kdopamine.app.global.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Collections;

@Slf4j
@Service
@RequiredArgsConstructor
public class OAuthService {

    private final MemberRepository memberRepository;
    private final JwtUtil jwtUtil;

    @Value("${oauth.google.client-id}")
    private String clientId;

    /**
     * Flutter에서 받은 idToken을 검증하고 JWT 발급
     *
     * 흐름:
     * 1. Flutter → Google 로그인 → idToken 받음
     * 2. Flutter → POST /auth/login/google (idToken 전송) → 백엔드
     * 3. 백엔드 → Google에 idToken 검증 요청 (이 메서드)
     * 4. 백엔드 → 회원 저장/조회 → JWT 생성 → Flutter로 반환
     */
    public GoogleTokenResponse googleLogin(String idToken) {
        // 1. Google ID Token 검증
        GoogleIdToken.Payload payload = verifyGoogleIdToken(idToken);
        log.info("Google ID Token 검증 완료 - email: {}", payload.getEmail());

        // 2. 회원 조회 또는 신규 가입
        Member member = memberRepository.findByEmail(payload.getEmail())
                .orElseGet(() -> {
                    log.info("신규 회원 저장");
                    return memberRepository.save(
                            Member.createSocialMember(
                                    payload.getEmail(),
                                    (String) payload.get("name"),
                                    "GOOGLE",
                                    payload.getSubject()  // Google 고유 ID
                            )
                    );
                });
        log.info("회원 정보 - {}", member.getEmail());

        // 3. JWT 토큰 생성
        String accessToken = jwtUtil.createAccessToken(member.getId(), member.getEmail(), member.getRole());
        String refreshToken = jwtUtil.createRefreshToken(member.getId());
        log.info("JWT 토큰 생성 완료");

        // 4. 토큰 반환
        return GoogleTokenResponse.of(accessToken, refreshToken);
    }

    /**
     * Google ID Token 검증
     */
    private GoogleIdToken.Payload verifyGoogleIdToken(String idToken) {
        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(),
                    GsonFactory.getDefaultInstance())
                    .setAudience(Collections.singletonList(clientId))
                    .build();

            GoogleIdToken googleIdToken = verifier.verify(idToken);

            if (googleIdToken == null) {
                log.error("Google ID Token 검증 실패 - 유효하지 않은 토큰");
                throw new BusinessException(ErrorCode.TOKEN_INVALID);
            }

            return googleIdToken.getPayload();

        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            log.error("Google ID Token 검증 중 오류 발생", e);
            throw new BusinessException(ErrorCode.SERVER_EXCEPTION_JWT);
        }
    }

}
