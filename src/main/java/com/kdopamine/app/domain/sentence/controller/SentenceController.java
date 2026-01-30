package com.kdopamine.app.domain.sentence.controller;

import com.kdopamine.app.domain.sentence.dto.request.SentenceSubmitReq;
import com.kdopamine.app.domain.sentence.dto.response.SentenceQuizRes;
import com.kdopamine.app.domain.sentence.dto.response.SentenceSubmitRes;
import com.kdopamine.app.domain.sentence.service.SentenceService;
import com.kdopamine.app.global.response.ApiResponse;
import com.kdopamine.app.global.security.CustomUserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/sentence")
@RequiredArgsConstructor
public class SentenceController {

    private final SentenceService sentenceService;

    @GetMapping("/quiz/random")
    public ResponseEntity<ApiResponse<List<SentenceQuizRes>>> getRandomQuizzes(
            @AuthenticationPrincipal CustomUserPrincipal member,
            @RequestParam(defaultValue = "20") int count
    ){
        List<SentenceQuizRes> response = sentenceService.getRandomQuizzes(member.getId(), count);

        return ResponseEntity.ok(ApiResponse.success(response, "문장 퀴즈 조회 성공"));
    }

    @GetMapping("/quiz/chapter/{chapterId}")
    public ResponseEntity<ApiResponse<List<SentenceQuizRes>>> getChapterQuizzes(
            @AuthenticationPrincipal CustomUserPrincipal member,
            @PathVariable Long chapterId,
            @RequestParam(defaultValue = "20") int count
    ){
        List<SentenceQuizRes> response = sentenceService.getChapterQuizzes(member.getId(), chapterId, count);
        return ResponseEntity.ok(ApiResponse.success(response, "챕터별 퀴즈 조회 성공"));
    }

    @PostMapping("/quiz/submit")
    public ResponseEntity<ApiResponse<SentenceSubmitRes>> submitQuiz(
            @AuthenticationPrincipal CustomUserPrincipal member,
            @RequestBody @Valid SentenceSubmitReq request
    ){
        SentenceSubmitRes response = sentenceService.submitQuiz(member.getId(), request);

        return ResponseEntity.ok(ApiResponse.success(response, "채점 완료"));
    }
}
