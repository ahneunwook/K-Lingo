package com.kdopamine.app.domain.topik.entity;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum TopikSection {
    READING("Reading"),     // 읽기
    LISTENING("Listening"), // 듣기
    WRITING("Writing");     // 쓰기

    private final String label;
}