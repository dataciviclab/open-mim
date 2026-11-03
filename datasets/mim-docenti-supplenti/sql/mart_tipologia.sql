-- Mart: distribuzione dei supplenti docenti per tipo di supplenza.
-- Grano: anno x tipo_supplenza.

WITH base AS (
    SELECT
        anno,
        tipo_supplenza,
        SUM(docenti_supplenti_totale) AS docenti_supplenti_totale
    FROM clean_input
    GROUP BY anno, tipo_supplenza
)
SELECT
    anno,
    tipo_supplenza,
    CAST(docenti_supplenti_totale AS BIGINT) AS docenti_supplenti_totale,
    ROUND(
        100.0 * docenti_supplenti_totale
        / NULLIF(SUM(docenti_supplenti_totale) OVER (PARTITION BY anno), 0),
        2
    ) AS quota_pct
FROM base
