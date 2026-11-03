-- Mart: distribuzione dei supplenti docenti per fascia d'età.
-- Grano: anno x fascia_eta.

WITH base AS (
    SELECT
        anno,
        fascia_eta,
        SUM(docenti_supplenti_totale) AS docenti_supplenti_totale
    FROM clean_input
    GROUP BY anno, fascia_eta
)
SELECT
    anno,
    fascia_eta,
    CAST(docenti_supplenti_totale AS BIGINT) AS docenti_supplenti_totale,
    ROUND(
        100.0 * docenti_supplenti_totale
        / NULLIF(SUM(docenti_supplenti_totale) OVER (PARTITION BY anno), 0),
        2
    ) AS quota_pct
FROM base
