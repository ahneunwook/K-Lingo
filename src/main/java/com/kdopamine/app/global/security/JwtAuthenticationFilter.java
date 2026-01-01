package com.kdopamine.app.global.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.kdopamine.app.domain.member.entity.Member;
import com.kdopamine.app.domain.member.repository.MemberRepository;
import com.kdopamine.app.global.exception.BusinessException;
import com.kdopamine.app.global.exception.ErrorCode;
import com.kdopamine.app.global.response.ErrorResponse;
import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.catalina.User;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;
    private final MemberRepository memberRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        // 헤더에서 토큰 꺼내기
        String bearerToken = request.getHeader("Authorization");

        // 토큰이 있는 경우만 검증 진행
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            try {
                // 검증 및 파싱 (성공하면 claims 반환, 실패하면 예외 발생)
                Claims claims = jwtUtil.parseToken(bearerToken);

                // 인증 처리 (SecurityContext에 저장)
                setAuthentication(claims);

            } catch (BusinessException e) {
                log.warn("JWT 인증 실패: {}", e.getErrorCode().getMessage());
                sendErrorResponse(response, e.getErrorCode());
                return;
            }
        }

        filterChain.doFilter(request, response);
    }

    private void setAuthentication(Claims claims) {
        Long userId = Long.valueOf(claims.getSubject());

        Member member = memberRepository.findById(Long.valueOf(userId))
              .orElseThrow(() -> new BusinessException(ErrorCode.RESOURCE_NOT_FOUND));

        CustomUserPrincipal principal = new CustomUserPrincipal(member);
        UserAuthentication authentication = new UserAuthentication(
                principal, null, principal.getAuthorities());

        SecurityContextHolder.getContext().setAuthentication(authentication);
    }

    private void sendErrorResponse(HttpServletResponse response, ErrorCode errorCode) throws IOException {
        response.setStatus(errorCode.getStatus());
        response.setContentType("application/json;charset=UTF-8");

        ErrorResponse errorResponse = ErrorResponse.of(
                errorCode.getCode(),
                errorCode.getMessage()
        );

        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new com.fasterxml.jackson.datatype.jsr310.JavaTimeModule());

        String json = objectMapper.writeValueAsString(errorResponse);

        response.getWriter().write(json);
        response.getWriter().flush();
    }
}
