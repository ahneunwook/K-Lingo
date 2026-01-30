package com.kdopamine.app.domain.word.repository;

import com.kdopamine.app.domain.studylog.entity.QMemberWordProgress;
import com.kdopamine.app.domain.word.dto.response.StageRes;
import com.querydsl.core.types.Projections;
import com.querydsl.core.types.dsl.Expressions;
import com.querydsl.jpa.impl.JPAQueryFactory;
import lombok.RequiredArgsConstructor;

import java.util.List;

import static com.kdopamine.app.domain.word.entity.QStage.stage;
import static com.kdopamine.app.domain.studylog.entity.QMemberWordProgress.memberWordProgress;

@RequiredArgsConstructor
public class StageRepositoryImpl implements StageRepositoryCustom {

    private final JPAQueryFactory queryFactory;

    @Override
    public List<StageRes> findStagesWithProgress(Long chapterId, Long memberId) {

        QMemberWordProgress progress = QMemberWordProgress.memberWordProgress;

        return queryFactory.select(Projections.constructor(StageRes.class,
                stage.id,
                stage.stageOrder,
                stage.title,
                memberWordProgress.bestScore.coalesce(0),
                memberWordProgress.isCleared.coalesce(false),
                Expressions.asBoolean(false)
                ))
                .from(stage)
                // ★ Left Join: 스테이지는 다 보여주고, 내 기록이 있으면 붙임
                .leftJoin(progress)
                .on(stage.id.eq(progress.stage.id)
                        .and(progress.member.id.eq(memberId)))
                // ★ Chapter ID로 조회 (기존 categoryId)
                .where(stage.chapter.id.eq(chapterId))
                .orderBy(stage.stageOrder.asc())
                .fetch();
    }
}
