package com.kdopamine.app.domain.word.controller;

import com.kdopamine.app.domain.word.dto.request.WordQuizCheckReq;
import com.kdopamine.app.domain.word.dto.response.WordQuizCheckRes;
import com.kdopamine.app.domain.word.dto.response.WordQuizRes;
import com.kdopamine.app.domain.word.dto.response.WordStageRes;
import com.kdopamine.app.domain.word.service.WordStageService;
import com.kdopamine.app.global.response.ApiResponse;
import com.kdopamine.app.global.security.CustomUserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/stages")
@RequiredArgsConstructor
public class WordStageController {

    private final WordStageService wordStageService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<WordStageRes>>> getStages(
            @RequestParam(name = "categoryId") Long categoryId,
            @AuthenticationPrincipal CustomUserPrincipal user
            ){
        List<WordStageRes> res = wordStageService.getStages(categoryId, user);

        return ResponseEntity.ok(ApiResponse.success(res, "스테이지 조회 성공"));
    }
}
