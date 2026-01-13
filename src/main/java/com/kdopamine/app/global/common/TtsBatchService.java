package com.kdopamine.app.global.common;

import com.kdopamine.app.domain.word.entity.Word;
import com.kdopamine.app.domain.word.repository.WordRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j; // 로그 사용을 위해 추가
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j // 로그 출력용
@Service
@RequiredArgsConstructor
public class TtsBatchService {

    private final WordRepository wordRepository;
    private final GoogleTtsClient googleTtsClient;

    public void generateMissingAudio() {
        // 모든 단어를 가져옵니다.
        List<Word> words = wordRepository.findAll();
        int skipCount = 0;
        int successCount = 0;

        log.info("총 {}개의 단어를 검사합니다.", words.size());

        for (Word word : words) {

            // 🔥 [핵심 수정] null이거나, 빈 문자열("")이거나, 공백(" ")이면 생성 대상
            // 반대로 값이 꽉 차있으면(hasText) 스킵합니다.
            if (word.getAudioUrl() != null && !word.getAudioUrl().isBlank()) {
                skipCount++;
                // log.info("⏭️ 스킵 (이미 존재): {}", word.getKorean()); // 너무 시끄러우면 주석 처리
                continue;
            }

            try {
                // 구글 API 호출 및 파일 저장
                String audioUrl = googleTtsClient.createTts(word);

                // DB 업데이트
                word.addAudioUrl(audioUrl);
                wordRepository.save(word);
                successCount++;

                log.info("✅ 생성 완료: {} -> {}", word.getKorean(), audioUrl);

            } catch (Exception e) {
                log.error("❌ 실패: {} (ID: {})", word.getKorean(), word.getId());
                e.printStackTrace();
            }
        }

        log.info("📊 배치 종료 - 생성됨: {}, 건너뜀: {}", successCount, skipCount);
    }
}