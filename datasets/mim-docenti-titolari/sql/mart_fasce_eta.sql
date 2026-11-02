-- Mart: distribuzione del corpo docente per fascia d'età.
-- Grano: anno x ordine_scuola x fascia_eta. Quota della fascia sull'ordine.

WITH base AS (
    SELECT
        anno,
        ordine_scuola,
        fascia_eta,
        SUM(docenti_totale) AS docenti_totale
    FROM clean_input
    GROUP BY anno, ordine_scuola, fascia_eta
)
SELECT
    anno,
    ordine_scuola,
    fascia_eta,
    CAST(docenti_totale AS BIGINT) AS docenti_totale,
    ROUND(
        100.0 * docenti_totale
        / NULLIF(SUM(docenti_totale) OVER (PARTITION BY anno, ordine_scuola), 0),
        2
    ) AS quota_pct
FROM base
