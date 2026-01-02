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
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;
    private final MemberRepository memberRepository;
    private final ObjectMapper objectMapper;

    // JWT 검증을 건너뛸 경로들
    private static final List<String> EXCLUDED_PATHS = Arrays.asList(
            "/swagger-ui",
            "/v3/api-docs",
            "/auth/login/google",
            "/error"
    );

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = uri.substring(contextPath.length());

        if (shouldNotFilter(path)) {
            filterChain.doFilter(request, response);
            return;
        }

        try {
            String token = extractToken(request);

            if (token != null) {
                authenticateUser(token);
            }

            filterChain.doFilter(request, response);

        } catch (BusinessException e) {
            log.warn("JWT authentication failed: {}", e.getErrorCode().getMessage());
            sendErrorResponse(response, e.getErrorCode());
        } catch (Exception e) {
            log.error("Unexpected error during JWT authentication", e);
            sendErrorResponse(response, ErrorCode.SERVER_EXCEPTION_JWT);
        }
    }

    private boolean shouldNotFilter(String path) {
        return EXCLUDED_PATHS.stream().anyMatch(path::startsWith);
    }

    private String extractToken(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");

        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }

        return null;
    }

    private void authenticateUser(String token) {
        Claims claims = jwtUtil.parseToken(token);
        Long userId = Long.valueOf(claims.getSubject());

        Member member = memberRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.MEMBER_NOT_FOUND));

        CustomUserPrincipal principal = new CustomUserPrincipal(member);
        UserAuthentication authentication = new UserAuthentication(
                principal,
                null,
                principal.getAuthorities()
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);

    }

    private void sendErrorResponse(HttpServletResponse response, ErrorCode errorCode) throws IOException {
        response.setStatus(errorCode.getStatus());
        response.setContentType("application/json;charset=UTF-8");

        ErrorResponse errorResponse = ErrorResponse.of(
                errorCode.getCode(),
                errorCode.getMessage()
        );

        String json = objectMapper.writeValueAsString(errorResponse);
        response.getWriter().write(json);
        response.getWriter().flush();
    }
}
