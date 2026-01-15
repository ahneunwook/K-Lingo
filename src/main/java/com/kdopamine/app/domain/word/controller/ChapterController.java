package com.kdopamine.app.domain.word.controller;

import com.kdopamine.app.domain.word.dto.response.ChapterRes;
import com.kdopamine.app.domain.word.service.ChapterService;
import com.kdopamine.app.global.entity.SectionType;
import com.kdopamine.app.global.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/study")
@RequiredArgsConstructor
@Slf4j
public class ChapterController {

    private final ChapterService chapterService;

    @GetMapping("/chapters")
    public ResponseEntity<ApiResponse<List<ChapterRes>>> getCategories(
            @RequestParam SectionType type
    ){

        List<ChapterRes> res = chapterService.getChapters(type);

        return ResponseEntity.ok(ApiResponse.success(res, "챕터 조회 성공"));
    }
}
