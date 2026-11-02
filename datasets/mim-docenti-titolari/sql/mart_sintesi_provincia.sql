-- Mart: sintesi territoriale per provincia x ordine scolastico.
-- Grano: anno x provincia x ordine_scuola.
-- Include quota di genere e quota sul totale nazionale dell'ordine.

WITH base AS (
    SELECT
        anno,
        provincia,
        ordine_scuola,
        SUM(docenti_totale)    AS docenti_totale,
        SUM(docenti_maschile)  AS docenti_maschile,
        SUM(docenti_femminile) AS docenti_femminile
    FROM clean_input
    GROUP BY anno, provincia, ordine_scuola
)
SELECT
    anno,
    provincia,
    ordine_scuola,
    CAST(docenti_totale AS BIGINT)    AS docenti_totale,
    CAST(docenti_maschile AS BIGINT)  AS docenti_maschile,
    CAST(docenti_femminile AS BIGINT) AS docenti_femminile,
    ROUND(100.0 * docenti_femminile / NULLIF(docenti_totale, 0), 2) AS quota_femminile_pct,
    ROUND(
        100.0 * docenti_totale
        / NULLIF(SUM(docenti_totale) OVER (PARTITION BY anno, ordine_scuola), 0),
        2
    ) AS quota_nazionale_pct
FROM base
