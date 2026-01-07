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

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
@Profile("local")
public class DataLoader implements CommandLineRunner {

    private final WordCategoryRepository categoryRepository;
    private final WordStageRepository stageRepository;
    private final WordRepository wordRepository;

    @Override
    // ❌ @Transactional 제거! (읽기 전용 조회와 쓰기를 분리하여 트랜잭션 문제 원천 차단)
    public void run(String... args) throws Exception {

        // 1. 스테이지 데이터 확인
        if (stageRepository.count() > 0) {
            log.info("ℹ️ 스테이지 데이터가 이미 존재합니다. (SKIP)");
            return;
        }

        log.info("🚀 데이터 로딩 시작...");

        // 2. DB 카테고리 로드
        Map<String, WordCategory> categoryMap = loadCategoriesFromDB();

        // 카테고리가 텅 비었으면 여기서 멈춤
        if (categoryMap.isEmpty()) {
            log.error("🛑 [치명적 오류] DB에서 카테고리를 하나도 못 가져왔습니다!");
            log.error("👉 확인: DB에 데이터가 진짜 들어있나요? application.yml의 ddl-auto가 create로 되어있어 지워진 건 아닌가요?");
            return;
        }

        // 3. 스테이지 로드
        Map<String, WordStage> stageMap = loadStages(categoryMap);

        // 4. 단어 로드
        loadWords(stageMap);

        log.info("✅ 데이터 세팅 최종 완료!");
    }

    private Map<String, WordCategory> loadCategoriesFromDB() {
        List<WordCategory> categories = categoryRepository.findAll();
        Map<String, WordCategory> map = new HashMap<>();

        log.info("🔍 DB 카테고리 스캔 결과: 총 {}개 발견", categories.size());

        for (WordCategory c : categories) {
            // 공백 제거 및 대문자 변환으로 매칭 확률 높임
            String key = c.getNameEn().trim();
            map.put(key, c);
            log.info("   👉 로드됨: [{}] -> ID: {}", key, c.getId());
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
            // 🔥 [핵심] BOM(투명 문자) 제거 로직
            if (isFirstLine && line.startsWith("\uFEFF")) {
                line = line.substring(1);
                isFirstLine = false;
            }

            if (line.trim().isEmpty()) continue;

            String[] data = line.split(",");
            String categoryName = data[0].trim(); // CSV에 적힌 이름

            // 맵에서 찾기
            WordCategory category = categoryMap.get(categoryName);

            if (category == null) {
                // 🔍 여기서 왜 안 되는지 로그로 범인 색출
                log.error("❌ 매핑 실패! CSV에는 '{}'라고 적혀있는데, DB 목록엔 이 키가 없습니다.", categoryName);
                log.error("   (혹시 DB에는 'Greetings' 소문자인데 CSV는 'GREETINGS' 대문자인가요?)");
                continue;
            }

            WordStage stage = WordStage.createStage(
                    category,
                    Integer.parseInt(data[1].trim()),
                    data[2].trim(),
                    Integer.parseInt(data[3].trim()),
                    Integer.parseInt(data[4].trim())
            );

            stageRepository.save(stage); // 여기선 트랜잭션 필요할 수 있음 (Repository 기본 내장이라 괜찮음)
            map.put(categoryName + "_" + stage.getStageOrder(), stage);
        }
        br.close();
        log.info("📂 스테이지 로드 완료: {}개", map.size());
        return map;
    }

    private void loadWords(Map<String, WordStage> stageMap) throws Exception {
        ClassPathResource resource = new ClassPathResource("data/words.csv");
        if (!resource.exists()) return;

        BufferedReader br = new BufferedReader(new InputStreamReader(resource.getInputStream(), StandardCharsets.UTF_8));
        String line;
        boolean isFirstLine = true;

        while ((line = br.readLine()) != null) {
            // 🔥 BOM 제거
            if (isFirstLine && line.startsWith("\uFEFF")) {
                line = line.substring(1);
                isFirstLine = false;
            }

            if (line.trim().isEmpty()) continue;

            String[] data = line.split(",");

            // GREETINGS_1
            String key = data[0].trim() + "_" + data[1].trim();
            WordStage stage = stageMap.get(key);

            if (stage == null) {
                // 스테이지가 제대로 안 만들어졌으면 단어도 패스
                continue;
            }

            Word word = Word.createWordWithPronunciation(
                    stage,
                    data[2].trim(),
                    data[4].trim(),
                    data[3].trim()
            );

            wordRepository.save(word);
        }
        br.close();
        log.info("📚 단어 로드 완료!");
    }
}