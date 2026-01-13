package com.kdopamine.app.global.common;

import com.kdopamine.app.domain.word.entity.Word;
import com.kdopamine.app.domain.word.entity.WordCategory;
import com.kdopamine.app.domain.word.entity.WordStage;
import com.kdopamine.app.domain.word.repository.WordCategoryRepository;
import com.kdopamine.app.domain.word.repository.WordRepository;
import com.kdopamine.app.domain.word.repository.WordStageRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Component
@RequiredArgsConstructor
@Profile("local")
public class DataLoader implements CommandLineRunner {

    private final WordCategoryRepository categoryRepository;
    private final WordStageRepository stageRepository;
    private final WordRepository wordRepository;

    @Override
    @Transactional // 트랜잭션 하나로 묶음 (속도 향상 및 정합성)
    public void run(String... args) throws Exception {

        log.info("🚀 데이터 로딩 시작...");

        // 1. DB 카테고리 로드
        Map<String, WordCategory> categoryMap = loadCategoriesFromDB();

        if (categoryMap.isEmpty()) {
            log.error("🛑 [오류] DB에 카테고리가 없습니다. import.sql 등을 확인하세요.");
            return;
        }

        // 2. 스테이지 로드 (중복 체크 포함)
        Map<String, WordStage> stageMap = loadStages(categoryMap);

        // 3. 단어 로드 (중복 체크 포함)
        loadWords(stageMap);

        log.info("✅ 데이터 세팅 최종 완료!");
    }

    private Map<String, WordCategory> loadCategoriesFromDB() {
        List<WordCategory> categories = categoryRepository.findAll();
        Map<String, WordCategory> map = new HashMap<>();
        for (WordCategory c : categories) {
            String key = c.getNameEn().trim().toUpperCase();
            map.put(key, c);
        }
        return map;
    }

    private Map<String, WordStage> loadStages(Map<String, WordCategory> categoryMap) throws Exception {
        Map<String, WordStage> map = new HashMap<>();
        ClassPathResource resource = new ClassPathResource("data/stages.csv");

        if (!resource.exists()) {
            log.warn("❌ stages.csv 없음");
            return map;
        }

        BufferedReader br = new BufferedReader(new InputStreamReader(resource.getInputStream(), StandardCharsets.UTF_8));
        String line;
        boolean isFirstLine = true;

        while ((line = br.readLine()) != null) {
            if (isFirstLine && line.startsWith("\uFEFF")) {
                line = line.substring(1);
                isFirstLine = false;
            }

            if (line.trim().isEmpty()) continue;

            String[] data = line.split(",");
            if (data.length < 4) continue; // 데이터 깨짐 방지

            String categoryName = data[0].trim().toUpperCase();
            int stageOrder = Integer.parseInt(data[1].trim());
            String title = data[2].trim();
            int passScore = Integer.parseInt(data[3].trim());

            WordCategory category = categoryMap.get(categoryName);
            if (category == null) {
                log.warn("⚠️ 카테고리 매칭 실패: {}", categoryName);
                continue;
            }

            Optional<WordStage> existingStage = stageRepository.findByWordCategoryAndStageOrder(category, stageOrder);

            WordStage stage;
            if (existingStage.isPresent()) {
                // 이미 있으면 DB에서 가져와서 맵에 넣음 (새로 저장 X)
                stage = existingStage.get();
                // log.info("ℹ️ 스테이지 스킵 (이미 존재): {} - Stage {}", categoryName, stageOrder);
            } else {
                // 없으면 새로 저장
                stage = WordStage.createStage(category, stageOrder, title, passScore);
                stageRepository.save(stage);
                log.info("💾 스테이지 저장: {} - Stage {}", categoryName, stageOrder);
            }

            // 나중에 단어 넣을 때 쓰려고 맵에 저장 (Key: GREETINGS_1)
            map.put(categoryName + "_" + stage.getStageOrder(), stage);
        }
        br.close();
        return map;
    }

    private void loadWords(Map<String, WordStage> stageMap) throws Exception {
        ClassPathResource resource = new ClassPathResource("data/words.csv");
        if (!resource.exists()) return;

        // 🔥 [핵심 개선] 모든 단어를 한 번에 조회!
        List<Word> allExistingWords = wordRepository.findAll();

        // 🔥 "스테이지ID_한국어" 형태로 Set 구성 → O(1) 조회
        Set<String> existingWordKeys = allExistingWords.stream()
                .map(w -> w.getWordStage().getId() + "_" + w.getKorean())
                .collect(Collectors.toSet());

        log.info("📊 기존 단어 {} 개 로드 완료", allExistingWords.size());

        BufferedReader br = new BufferedReader(
                new InputStreamReader(resource.getInputStream(), StandardCharsets.UTF_8)
        );

        String line;
        boolean isFirstLine = true;
        List<Word> wordsToSave = new ArrayList<>();

        while ((line = br.readLine()) != null) {
            if (isFirstLine && line.startsWith("\uFEFF")) {
                line = line.substring(1);
                isFirstLine = false;
            }

            if (line.trim().isEmpty()) continue;

            String[] data = line.split(",");
            if (data.length < 5) continue;

            String categoryName = data[0].trim().toUpperCase();
            String stageOrderStr = data[1].trim();
            String korean = data[2].trim();
            String english = data[3].trim();
            String pronunciation = data[4].trim();

            String key = categoryName + "_" + stageOrderStr;
            WordStage stage = stageMap.get(key);

            if (stage == null) continue;

            // 🔥 메모리 Set에서 O(1) 체크
            String wordKey = stage.getId() + "_" + korean;
            if (existingWordKeys.contains(wordKey)) {
                continue; // 이미 있으면 스킵
            }

            Word word = Word.createWordWithPronunciation(
                    stage, korean, pronunciation, english
            );
            wordsToSave.add(word);
        }

        br.close();

        // 🔥 새 단어만 배치로 저장
        if (!wordsToSave.isEmpty()) {
            wordRepository.saveAll(wordsToSave);
            log.info("💾 새 단어 {} 개 저장 완료", wordsToSave.size());
        } else {
            log.info("ℹ️ 저장할 새 단어 없음 (모두 존재)");
        }

        log.info("📚 단어 로드 로직 완료");
    }
}