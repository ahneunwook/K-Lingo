package com.kdopamine.app.domain.topik.entity;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum TopikLevel {
    LEVEL_1("Level 1 (Beginner)"),
    LEVEL_2("Level 2 (Beginner)"),

    // TOPIK II
    LEVEL_3("Level 3 (Intermediate)"),
    LEVEL_4("Level 4 (Intermediate)"),
    LEVEL_5("Level 5 (Advanced)"),
    LEVEL_6("Level 6 (Advanced)");

    private final String label;
}
