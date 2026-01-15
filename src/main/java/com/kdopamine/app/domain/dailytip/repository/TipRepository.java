package com.kdopamine.app.domain.dailytip.repository;

import com.kdopamine.app.domain.dailytip.entity.Tip;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface TipRepository extends JpaRepository<Tip, Long> {
    @Query(value = "SELECT * FROM tips ORDER BY RANDOM() LIMIT 1", nativeQuery = true)
    Optional<Tip> findRandomTip();
}
