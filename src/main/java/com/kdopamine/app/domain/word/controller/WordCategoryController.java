package com.kdopamine.app.domain.word.controller;

import com.kdopamine.app.domain.word.dto.response.WordCategoryRes;
import com.kdopamine.app.domain.word.service.WordCategoryService;
import com.kdopamine.app.global.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/words")
@RequiredArgsConstructor
@Slf4j
public class WordCategoryController {

    private final WordCategoryService wordService;

    @GetMapping("/categories")
    public ResponseEntity<ApiResponse<List<WordCategoryRes>>> getCategories(){

        List<WordCategoryRes> res = wordService.getCategories();

        return ResponseEntity.ok(ApiResponse.success(res, "카테고리 조회 성공"));
    }
}
