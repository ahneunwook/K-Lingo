package com.kdopamine.app.global.security;

import com.kdopamine.app.domain.member.entity.Role;
import com.kdopamine.app.global.exception.BusinessException;
import com.kdopamine.app.global.exception.ErrorCode;
import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.UUID;

@Slf4j
@Component
public class JwtUtil {

    private final String issuer;
    private final SecretKey secretKey;
    private final long accessTokenExpiry;
    private final long refreshTokenExpiry;

    private static final String BEARER_PREFIX = "Bearer ";

    public JwtUtil(
            @Value("${jwt.issuer}") String issuer,
            @Value("${jwt.secret-key}") String secretKey,
            @Value("${jwt.access-token-expiry}") long accessTokenExpiry,
            @Value("${jwt.refresh-token-expiry}") long refreshTokenExpiry
    ) {
        this.issuer = issuer;
        this.accessTokenExpiry = accessTokenExpiry;
        this.refreshTokenExpiry = refreshTokenExpiry;

        // 시크릿 키 설정 (jjwt 0.12.x 최신 버전 기준)
        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        this.secretKey = Keys.hmacShaKeyFor(keyBytes);
    }

    public String createAccessToken(Long userId, String email, Role role) {
        Date date = new Date();
        Date expiryDate = new Date(date.getTime() + accessTokenExpiry);

        return BEARER_PREFIX + Jwts.builder()
                .subject(String.valueOf(userId))
                .issuer(issuer)
                .issuedAt(date)
                .expiration(expiryDate)
                .claim("type", "access")
                .claim("email", email)
                .claim("userRole", role.name()) // Enum의 이름 저장
                .signWith(secretKey)
                .compact();
    }

    public String createRefreshToken(Long userId) {
        Date date = new Date();
        String jti = UUID.randomUUID().toString();
        Date expiryDate = new Date(date.getTime() + refreshTokenExpiry);

        return BEARER_PREFIX + Jwts.builder()
                .subject(String.valueOf(userId))
                .id(jti)
                .claim("type", "refresh")
                .issuer(issuer)
                .expiration(expiryDate)
                .issuedAt(date)
                .signWith(secretKey)
                .compact();
    }

    public String substringToken(String tokenValue) {
        if (StringUtils.hasText(tokenValue) && tokenValue.startsWith(BEARER_PREFIX)) {
            return tokenValue.substring(7);
        }
        return null;
    }

    public Claims parseRawToken(String token) {
        try {
            return Jwts.parser()
                    .verifyWith(secretKey)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (ExpiredJwtException e) {
            log.warn("토큰이 만료 되었습니다.");
            throw new BusinessException(ErrorCode.TOKEN_EXPIRED);
        } catch (SecurityException | MalformedJwtException | UnsupportedJwtException e) {
            log.warn("잘못된 형식의 토큰입니다.");
            throw new BusinessException(ErrorCode.TOKEN_INVALID);
        } catch (IllegalArgumentException e) {
            log.warn("토큰 정보가 비어있습니다.");
            throw new BusinessException(ErrorCode.TOKEN_EMPTY);
        } catch (Exception e) {
            log.error("JWT 검증 중 알 수 없는 오류 발생");
            throw new BusinessException(ErrorCode.SERVER_EXCEPTION_JWT);
        }
    }

    public Claims parseToken(String bearerToken) {
        String token = substringToken(bearerToken);
        if (!StringUtils.hasText(token)) {
            throw new BusinessException(ErrorCode.TOKEN_EMPTY);
        }
        return parseRawToken(token);
    }
}

