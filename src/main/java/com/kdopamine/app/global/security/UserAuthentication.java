package com.kdopamine.app.global.security;

import lombok.extern.slf4j.Slf4j;
import org.jspecify.annotations.Nullable;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;

import java.util.Collection;

@Slf4j
public class UserAuthentication extends AbstractAuthenticationToken {
    private final Object principal;
    private String credentials;

    // 인증 완료 후 사용하는 생성자
    public UserAuthentication(Object principal, String credentials, Collection<? extends GrantedAuthority> authorities) {
        super(authorities);
        this.principal = principal;
        this.credentials = credentials;
        super.setAuthenticated(true);
    }

    public @Nullable Object getCredentials() {
        return this.credentials;
    }

    @Override
    public @Nullable Object getPrincipal() {
        return this.principal;
    }

    @Override
    public void setAuthenticated(boolean authenticated) {
        if (authenticated) {
            throw new IllegalArgumentException("보안을 위해 생성자를 통해서만 인증 상태를 변경할 수 있습니다.");
        }
        super.setAuthenticated(false);
    }

    @Override
    public void eraseCredentials() {
        super.eraseCredentials();
        this.credentials = null;
    }
}
