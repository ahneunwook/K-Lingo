package com.kdopamine.app.global.exception;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum ErrorCode {
    // Common
    INVALID_INPUT_VALUE(400, "C001", "잘못된 입력값입니다."),
    METHOD_NOT_ALLOWED(405, "C002", "허용되지 않은 메서드입니다."),
    INTERNAL_SERVER_ERROR(500, "C003", "서버 오류가 발생했습니다."),
    INVALID_TYPE_VALUE(400, "C004", "잘못된 타입입니다."),

    // Business
    RESOURCE_NOT_FOUND(404, "B001", "리소스를 찾을 수 없습니다."),
    DUPLICATE_RESOURCE(409, "B002", "중복된 리소스입니다."),
    UNAUTHORIZED(401, "B003", "인증이 필요합니다."),
    FORBIDDEN(403, "B004", "권한이 없습니다.");

    private final int status;
    private final String code;
    private final String message;
}

