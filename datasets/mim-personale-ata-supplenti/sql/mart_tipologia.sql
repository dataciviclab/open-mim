-- Mart: distribuzione dei supplenti ATA per tipo di supplenza.
-- Grano: anno x tipo_supplenza. Quota sul totale dell'anno.

WITH base AS (
    SELECT
        anno,
        tipo_supplenza,
        SUM(ata_supplenti_totale) AS ata_supplenti_totale
    FROM clean_input
    GROUP BY anno, tipo_supplenza
)
SELECT
    anno,
    tipo_supplenza,
    CAST(ata_supplenti_totale AS BIGINT) AS ata_supplenti_totale,
    ROUND(
        100.0 * ata_supplenti_totale
        / NULLIF(SUM(ata_supplenti_totale) OVER (PARTITION BY anno), 0),
        2
    ) AS quota_pct
FROM base
