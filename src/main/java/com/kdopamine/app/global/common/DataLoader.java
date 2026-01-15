package com.kdopamine.app.global.common;

import com.kdopamine.app.domain.word.entity.Chapter;
import com.kdopamine.app.domain.word.entity.Stage;
import com.kdopamine.app.domain.word.entity.Word;
import com.kdopamine.app.domain.word.repository.ChapterRepository; // 이름 변경됨
import com.kdopamine.app.domain.word.repository.StageRepository;
import com.kdopamine.app.domain.word.repository.WordRepository;
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

    // ★ Repository 변경 확인
    private final ChapterRepository chapterRepository;
    private final StageRepository stageRepository;
    private final WordRepository wordRepository;

    @Override
    @Transactional
    public void run(String... args) throws Exception {

        log.info("🚀 데이터 로딩 시작...");

        // 1. DB 챕터 로드 (기존 카테고리 대체)
        Map<String, Chapter> chapterMap = loadChaptersFromDB();

        if (chapterMap.isEmpty()) {
            log.error("🛑 [오류] DB에 챕터(Chapter)가 없습니다. import.sql을 확인하세요.");
            return;
        }

        // 2. 스테이지 로드 (WordStage -> Stage)
        Map<String, Stage> stageMap = loadStages(chapterMap);

        // 3. 단어 로드
        loadWords(stageMap);

        log.info("✅ 데이터 세팅 최종 완료!");
    }

    // WordCategory -> Chapter 로 변경
    private Map<String, Chapter> loadChaptersFromDB() {
        List<Chapter> chapters = chapterRepository.findAll();
        Map<String, Chapter> map = new HashMap<>();
        for (Chapter c : chapters) {
            // "GREETINGS" 같은 영문 이름을 키로 사용
            String key = c.getNameEn().trim().toUpperCase();
            map.put(key, c);
        }
        return map;
    }

    private Map<String, Stage> loadStages(Map<String, Chapter> chapterMap) throws Exception {
        Map<String, Stage> map = new HashMap<>();
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

            // CSV 포맷: [CategoryName, Order, Title, PassScore, XpReward(선택)]
            String[] data = line.split(",");
            if (data.length < 4) continue;

            String chapterName = data[0].trim().toUpperCase();
            int stageOrder = Integer.parseInt(data[1].trim());
            String title = data[2].trim();
            int passScore = Integer.parseInt(data[3].trim());

            // ★ XP 보상 추가 (CSV에 없으면 기본 20점)
            int xpReward = 20;
            if (data.length >= 5) {
                xpReward = Integer.parseInt(data[4].trim());
            }

            Chapter chapter = chapterMap.get(chapterName);
            if (chapter == null) {
                log.warn("⚠️ 챕터 매칭 실패: {}", chapterName);
                continue;
            }

            // ★ 리포지토리 메서드 이름 변경됨 (findByChapterAndStageOrder)
            Optional<Stage> existingStage = stageRepository.findByChapterAndStageOrder(chapter, stageOrder);

            Stage stage;
            if (existingStage.isPresent()) {
                stage = existingStage.get();
            } else {
                // ★ Stage 빌더 사용
                stage = Stage.create(chapter, stageOrder, title, passScore, xpReward);
                stageRepository.save(stage);
                log.info("💾 스테이지 저장: {} - Stage {}", chapterName, stageOrder);
            }

            // 나중에 단어 매핑용 (Key: GREETINGS_1)
            map.put(chapterName + "_" + stage.getStageOrder(), stage);
        }
        br.close();
        return map;
    }

    private void loadWords(Map<String, Stage> stageMap) throws Exception {
        ClassPathResource resource = new ClassPathResource("data/words.csv");
        if (!resource.exists()) return;

        List<Word> allExistingWords = wordRepository.findAll();

        // ★ w.getWordStage() -> w.getStage() 로 변경됨
        Set<String> existingWordKeys = allExistingWords.stream()
                .map(w -> w.getStage().getId() + "_" + w.getKorean())
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
            Stage stage = stageMap.get(key); // WordStage -> Stage

            if (stage == null) continue;

            String wordKey = stage.getId() + "_" + korean;
            if (existingWordKeys.contains(wordKey)) {
                continue;
            }

            // ★ Word 생성 메서드 호출 (첫 번째 인자가 Stage 타입으로 변경되었음)
            Word word = Word.createWordWithPronunciation(
                    stage, korean, pronunciation, english
            );
            wordsToSave.add(word);
        }

        br.close();

        if (!wordsToSave.isEmpty()) {
            wordRepository.saveAll(wordsToSave);
            log.info("💾 새 단어 {} 개 저장 완료", wordsToSave.size());
        } else {
            log.info("ℹ️ 저장할 새 단어 없음");
        }

        log.info("📚 단어 로드 로직 완료");
    }
}