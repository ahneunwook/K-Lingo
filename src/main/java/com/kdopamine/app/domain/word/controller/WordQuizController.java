package com.kdopamine.app.domain.word.controller;

import com.kdopamine.app.domain.word.dto.request.WordQuizCheckReq;
import com.kdopamine.app.domain.word.dto.response.WordQuizRes;
import com.kdopamine.app.domain.word.dto.response.WordQuizResultRes;
import com.kdopamine.app.domain.word.service.WordQuizService;
import com.kdopamine.app.global.response.ApiResponse;
import com.kdopamine.app.global.security.CustomUserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/quizzes")
@RequiredArgsConstructor
public class WordQuizController {

    private final WordQuizService wordQuizService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<WordQuizRes>>> getQuizWords(
            @RequestParam(name = "stageId") Long stageId
    ) {
        List<WordQuizRes> res = wordQuizService.getWordQuiz(stageId);
        return ResponseEntity.ok(ApiResponse.success(res, "문제 조회 성공"));
    }

    @PostMapping("/submit")
    public ResponseEntity<ApiResponse<WordQuizResultRes>> submitQuiz(
            @AuthenticationPrincipal CustomUserPrincipal member,
            @RequestParam(name = "stageId") Long stageId,
            @RequestBody List<WordQuizCheckReq> answers
    ) {
        WordQuizResultRes res = wordQuizService.submitQuiz(member.getId(), stageId, answers);
        return ResponseEntity.ok(ApiResponse.success(res, "정답 채점 완료"));
    }
}
