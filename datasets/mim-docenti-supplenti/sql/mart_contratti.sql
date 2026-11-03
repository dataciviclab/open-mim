-- Mart: supplenti docenti per contratto finalizzato al ruolo e orario intero.
-- Grano: anno x contratto_finalizzato_ruolo x contratto_orario_intero.
-- Solo dal 2023/24 la fonte espone queste colonne: prima il mart è vuoto.

WITH base AS (
    SELECT
        anno,
        contratto_finalizzato_ruolo,
        contratto_orario_intero,
        SUM(docenti_supplenti_totale) AS docenti_supplenti_totale
    FROM clean_input
    WHERE contratto_finalizzato_ruolo IS NOT NULL
    GROUP BY anno, contratto_finalizzato_ruolo, contratto_orario_intero
)
SELECT
    anno,
    contratto_finalizzato_ruolo,
    contratto_orario_intero,
    CAST(docenti_supplenti_totale AS BIGINT) AS docenti_supplenti_totale,
    ROUND(
        100.0 * docenti_supplenti_totale
        / NULLIF(SUM(docenti_supplenti_totale) OVER (PARTITION BY anno), 0),
        2
    ) AS quota_pct
FROM base
