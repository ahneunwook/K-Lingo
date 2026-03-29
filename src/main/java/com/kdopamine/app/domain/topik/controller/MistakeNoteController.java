package com.kdopamine.app.domain.topik.controller;

import com.kdopamine.app.domain.studylog.dto.response.MistakeNoteListRes;
import com.kdopamine.app.domain.studylog.service.MistakeNoteService;
import com.kdopamine.app.global.response.ApiResponse;
import com.kdopamine.app.global.security.CustomUserPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Tag(name = "오답노트", description = "오답노트 관련 API")
@RestController
@RequestMapping("/mistake-notes")
@RequiredArgsConstructor
public class MistakeNoteController {

    private final MistakeNoteService mistakeNoteService;

    @Operation(summary = "오답노트 조회", description = "사용자의 오답노트 목록을 조회합니다. (단어/문장 분류)")
    @GetMapping
    public ApiResponse<MistakeNoteListRes> getMistakeNotes(
            @AuthenticationPrincipal CustomUserPrincipal user) {
        MistakeNoteListRes response = mistakeNoteService.getMistakeNotes(user.getId());
        return ApiResponse.success(response);
    }

    @Operation(summary = "오답노트 삭제", description = "복습 완료 후 오답노트에서 삭제합니다.")
    @DeleteMapping("/{mistakeNoteId}")
    public ApiResponse<Void> deleteMistakeNote(
            @AuthenticationPrincipal CustomUserPrincipal user,
            @PathVariable Long mistakeNoteId) {
        mistakeNoteService.deleteMistakeNote(user.getId(), mistakeNoteId);
        return ApiResponse.success(null);
    }
}

