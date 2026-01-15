package com.kdopamine.app.domain.word.controller;

import com.kdopamine.app.domain.word.dto.response.StageRes;
import com.kdopamine.app.domain.word.service.StageService;
import com.kdopamine.app.global.response.ApiResponse;
import com.kdopamine.app.global.security.CustomUserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/study/stages")
@RequiredArgsConstructor
public class StageController {

    private final StageService stageService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<StageRes>>> getStages(
            @RequestParam(name = "chapterId") Long chapterId,
            @AuthenticationPrincipal CustomUserPrincipal user
            ){
        List<StageRes> res = stageService.getStages(chapterId, user);

        return ResponseEntity.ok(ApiResponse.success(res, "스테이지 조회 성공"));
    }
}
