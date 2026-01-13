package com.kdopamine.app.global.exception;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum ErrorCode {
    // Auth / JWT
    TOKEN_EXPIRED(401, "A001", "토큰이 만료되었습니다. 다시 로그인해주세요."),
    TOKEN_INVALID(402, "A002", "유효하지 않은 토큰입니다."),
    TOKEN_EMPTY(401, "A003", "토큰이 존재하지 않습니다."),
    SERVER_EXCEPTION_JWT(500, "A004", "토큰 처리 중 서버 오류가 발생했습니다."),
    TOKEN_NOT_FOUND(404, "A005", "일치하는 토큰을 찾을 수 없습니다."),
    INVALID_REFRESH_TOKEN(401, "A006", "리프레시 토큰이 유효하지 않습니다."),
    MEMBER_NOT_FOUND(404, "A007", "해당 사용자를 찾을 수 없습니다."),

    // Common
    INVALID_INPUT_VALUE(400, "B001", "잘못된 입력값입니다."),
    METHOD_NOT_ALLOWED(405, "B002", "허용되지 않은 메서드입니다."),
    INTERNAL_SERVER_ERROR(500, "B003", "서버 오류가 발생했습니다."),
    INVALID_TYPE_VALUE(400, "B004", "잘못된 타입입니다."),

    // Business
    RESOURCE_NOT_FOUND(404, "C001", "리소스를 찾을 수 없습니다."),
    DUPLICATE_RESOURCE(409, "C002", "중복된 리소스입니다."),
    UNAUTHORIZED(401, "C003", "인증이 필요합니다."),
    FORBIDDEN(403, "C004", "권한이 없습니다."),

    //words
    CATEGORY_NOT_FOUND(404, "D001","해당 카테고리가 없습니다."),
    WORD_NOT_FOUND(404, "D002", "해당 단어가 없습니다."),
    WORD_STAGE_NOT_FOUND(404, "D003", "해당 스테이지가 없습니다."),

    //quest
    QUEST_IS_NOT_COMPLETE(400, "E001", "퀘스트가 완료되지 않았습니다."),
    ALREADY_GET_REWARD(400, "E002", "이미 보상을 수령했습니다."),
    QUEST_NOT_FOUND(404, "E003", "해당 퀘스트가 없습니다.");

    private final int status;
    private final String code;
    private final String message;
}

