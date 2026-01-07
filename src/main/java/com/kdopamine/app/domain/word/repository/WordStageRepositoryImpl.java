package com.kdopamine.app.domain.word.repository;

import com.kdopamine.app.domain.word.dto.response.WordStageRes;
import com.querydsl.core.types.Projections;
import com.querydsl.core.types.dsl.Expressions;
import com.querydsl.jpa.impl.JPAQueryFactory;
import lombok.RequiredArgsConstructor;

import java.util.List;

import static com.kdopamine.app.domain.word.entity.QWordStage.wordStage;
import static com.kdopamine.app.domain.studylog.entity.QMemberStageProgress.memberStageProgress;

@RequiredArgsConstructor
public class WordStageRepositoryImpl implements WordStageRepositoryCustom{

    private final JPAQueryFactory queryFactory;

    @Override
    public List<WordStageRes> findStagesWithProgress(Long categoryId, Long memberId) {
        return queryFactory.select(Projections.constructor(WordStageRes.class,
                wordStage.id,
                wordStage.stageOrder,
                wordStage.title,
                memberStageProgress.bestScore.coalesce(0),
                memberStageProgress.isCleared.coalesce(false),
                Expressions.asBoolean(false)
                ))
                .from(wordStage)
                .leftJoin(memberStageProgress)
                    .on(wordStage.id.eq(memberStageProgress.wordStage.id)
                        .and(memberStageProgress.member.id.eq(memberId)))
                .where(wordStage.wordCategory.id.eq(categoryId))
                .orderBy(wordStage.stageOrder.asc())
                .fetch();
    }
}
