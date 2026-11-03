-- Mart: sintesi territoriale dei supplenti docenti per provincia x ordine.
-- Grano: anno x provincia x ordine_scuola.

WITH base AS (
    SELECT
        anno,
        provincia,
        ordine_scuola,
        SUM(docenti_supplenti_totale)    AS docenti_supplenti_totale,
        SUM(docenti_supplenti_maschile)  AS docenti_supplenti_maschile,
        SUM(docenti_supplenti_femminile) AS docenti_supplenti_femminile
    FROM clean_input
    GROUP BY anno, provincia, ordine_scuola
)
SELECT
    anno,
    provincia,
    ordine_scuola,
    CAST(docenti_supplenti_totale AS BIGINT)    AS docenti_supplenti_totale,
    CAST(docenti_supplenti_maschile AS BIGINT)  AS docenti_supplenti_maschile,
    CAST(docenti_supplenti_femminile AS BIGINT) AS docenti_supplenti_femminile,
    ROUND(100.0 * docenti_supplenti_femminile / NULLIF(docenti_supplenti_totale, 0), 2) AS quota_femminile_pct,
    ROUND(
        100.0 * docenti_supplenti_totale
        / NULLIF(SUM(docenti_supplenti_totale) OVER (PARTITION BY anno, ordine_scuola), 0),
        2
    ) AS quota_nazionale_pct
FROM base
