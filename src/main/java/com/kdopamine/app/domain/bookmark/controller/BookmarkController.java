package com.kdopamine.app.domain.bookmark.controller;

import com.kdopamine.app.domain.bookmark.dto.response.BookmarkSentenceRes;
import com.kdopamine.app.domain.bookmark.dto.response.BookmarkWordRes;
import com.kdopamine.app.domain.bookmark.service.BookmarkService;
import com.kdopamine.app.global.response.ApiResponse;
import com.kdopamine.app.global.security.CustomUserPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "북마크", description = "북마크(단어장/문장) 관련 API")
@RestController
@RequestMapping("/bookmarks")
@RequiredArgsConstructor
public class BookmarkController {

    private final BookmarkService bookmarkService;

    // ==================== 조회 ====================
    @Operation(summary = "단어 북마크 목록 조회", description = "단어장 탭용 북마크 목록")
    @GetMapping("/words")
    public ApiResponse<List<BookmarkWordRes>> getWordBookmarks(
            @AuthenticationPrincipal CustomUserPrincipal user) {
        return ApiResponse.success(bookmarkService.getWordBookmarks(user.getId()));
    }

    @Operation(summary = "문장 북마크 목록 조회", description = "문장 탭용 북마크 목록")
    @GetMapping("/sentences")
    public ApiResponse<List<BookmarkSentenceRes>> getSentenceBookmarks(
            @AuthenticationPrincipal CustomUserPrincipal user) {
        return ApiResponse.success(bookmarkService.getSentenceBookmarks(user.getId()));
    }

    // ==================== 추가 ====================

    @Operation(summary = "단어 북마크 추가", description = "단어를 북마크에 추가합니다.")
    @PostMapping("/words/{wordId}")
    public ApiResponse<Void> addWordBookmark(
            @AuthenticationPrincipal CustomUserPrincipal user,
            @PathVariable Long wordId) {
        bookmarkService.addWordBookmark(user.getId(), wordId);
        return ApiResponse.success(null);
    }

    @Operation(summary = "문장 북마크 추가", description = "문장을 북마크에 추가합니다.")
    @PostMapping("/sentences/{sentenceId}")
    public ApiResponse<Void> addSentenceBookmark(
            @AuthenticationPrincipal CustomUserPrincipal user,
            @PathVariable Long sentenceId) {
        bookmarkService.addSentenceBookmark(user.getId(), sentenceId);
        return ApiResponse.success(null);
    }

    // ==================== 삭제 ====================

    @Operation(summary = "단어 북마크 삭제", description = "단어를 북마크에서 삭제합니다.")
    @DeleteMapping("/words/{wordId}")
    public ApiResponse<Void> removeWordBookmark(
            @AuthenticationPrincipal CustomUserPrincipal user,
            @PathVariable Long wordId) {
        bookmarkService.removeWordBookmark(user.getId(), wordId);
        return ApiResponse.success(null);
    }

    @Operation(summary = "문장 북마크 삭제", description = "문장을 북마크에서 삭제합니다.")
    @DeleteMapping("/sentences/{sentenceId}")
    public ApiResponse<Void> removeSentenceBookmark(
            @AuthenticationPrincipal CustomUserPrincipal user,
            @PathVariable Long sentenceId) {
        bookmarkService.removeSentenceBookmark(user.getId(), sentenceId);
        return ApiResponse.success(null);
    }
}

