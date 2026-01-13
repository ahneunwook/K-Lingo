package com.kdopamine.app.domain.quest.repository;

import com.kdopamine.app.domain.quest.entity.Quest;
import com.kdopamine.app.domain.quest.entity.QuestPeriod;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface QuestRepository extends JpaRepository<Quest, Long> {

    List<Quest> findAllByPeriodAndActiveTrue(QuestPeriod period);
}
