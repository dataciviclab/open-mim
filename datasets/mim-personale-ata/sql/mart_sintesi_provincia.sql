-- Mart: sintesi territoriale del personale ATA per provincia.
-- Grano: anno x provincia.

WITH base AS (
    SELECT
        anno,
        provincia,
        SUM(ata_totale)    AS ata_totale,
        SUM(ata_maschile)  AS ata_maschile,
        SUM(ata_femminile) AS ata_femminile
    FROM clean_input
    GROUP BY anno, provincia
)
SELECT
    anno,
    provincia,
    CAST(ata_totale AS BIGINT)    AS ata_totale,
    CAST(ata_maschile AS BIGINT)  AS ata_maschile,
    CAST(ata_femminile AS BIGINT) AS ata_femminile,
    ROUND(100.0 * ata_femminile / NULLIF(ata_totale, 0), 2) AS quota_femminile_pct,
    ROUND(
        100.0 * ata_totale
        / NULLIF(SUM(ata_totale) OVER (PARTITION BY anno), 0),
        2
    ) AS quota_nazionale_pct
FROM base
