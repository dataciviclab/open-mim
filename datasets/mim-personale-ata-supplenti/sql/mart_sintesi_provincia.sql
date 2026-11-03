-- Mart: sintesi territoriale dei supplenti ATA per provincia.
-- Grano: anno x provincia.

WITH base AS (
    SELECT
        anno,
        provincia,
        SUM(ata_supplenti_totale)    AS ata_supplenti_totale,
        SUM(ata_supplenti_maschile)  AS ata_supplenti_maschile,
        SUM(ata_supplenti_femminile) AS ata_supplenti_femminile
    FROM clean_input
    GROUP BY anno, provincia
)
SELECT
    anno,
    provincia,
    CAST(ata_supplenti_totale AS BIGINT)    AS ata_supplenti_totale,
    CAST(ata_supplenti_maschile AS BIGINT)  AS ata_supplenti_maschile,
    CAST(ata_supplenti_femminile AS BIGINT) AS ata_supplenti_femminile,
    ROUND(100.0 * ata_supplenti_femminile / NULLIF(ata_supplenti_totale, 0), 2) AS quota_femminile_pct,
    ROUND(
        100.0 * ata_supplenti_totale
        / NULLIF(SUM(ata_supplenti_totale) OVER (PARTITION BY anno), 0),
        2
    ) AS quota_nazionale_pct
FROM base
