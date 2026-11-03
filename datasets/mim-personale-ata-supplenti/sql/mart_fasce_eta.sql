-- Mart: distribuzione dei supplenti ATA per fascia d'età.
-- Grano: anno x fascia_eta. Quota della fascia sul totale dell'anno.

WITH base AS (
    SELECT
        anno,
        fascia_eta,
        SUM(ata_supplenti_totale) AS ata_supplenti_totale
    FROM clean_input
    GROUP BY anno, fascia_eta
)
SELECT
    anno,
    fascia_eta,
    CAST(ata_supplenti_totale AS BIGINT) AS ata_supplenti_totale,
    ROUND(
        100.0 * ata_supplenti_totale
        / NULLIF(SUM(ata_supplenti_totale) OVER (PARTITION BY anno), 0),
        2
    ) AS quota_pct
FROM base
