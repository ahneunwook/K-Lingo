package com.kdopamine.app.global.common;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Component
@Profile("tts-batch")
public class TtsBatchRunner implements CommandLineRunner {

    private final TtsBatchService ttsBatchService;

    public TtsBatchRunner(TtsBatchService ttsBatchService) {
        this.ttsBatchService = ttsBatchService;
    }

    @Override
    public void run(String... args) {
        System.out.println("🚨 TTS BATCH START 🚨");
        ttsBatchService.generateMissingAudio();
        System.out.println("✅ TTS BATCH END");
    }
}
