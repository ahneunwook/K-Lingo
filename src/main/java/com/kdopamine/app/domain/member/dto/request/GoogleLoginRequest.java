package com.kdopamine.app.domain.member.dto.request;

import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class GoogleLoginRequest {
    private String idToken; // Flutter에서 받은 구글 인증 코드
}
