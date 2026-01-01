package com.kdopamine.app.global.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Getter
@Builder
public class ErrorResponse {
    private final String code;
    private final String message;

    @Builder.Default
    private final List<FieldError> errors = new ArrayList<>();

    @Builder.Default
    private final LocalDateTime timestamp = LocalDateTime.now();

    @Getter
    @AllArgsConstructor
    public static class FieldError {
        private final String field;
        private final String value;
        private final String reason;
        private final String path;

    }

    public static ErrorResponse of(String code, String message) {
        return ErrorResponse.builder()
                .code(code)
                .message(message)
                .build();
    }

    public static ErrorResponse of(String code, String message, List<FieldError> errors) {
        return ErrorResponse.builder()
                .code(code)
                .message(message)
                .errors(errors)
                .build();
    }
}

