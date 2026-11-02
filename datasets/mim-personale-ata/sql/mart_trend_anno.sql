-- Mart: serie storica multi-anno del personale ATA.
-- Grano: anno. Delta e variazione % sull'anno precedente.

WITH annuale AS (
    SELECT
        anno,
        SUM(ata_totale) AS ata_totale
    FROM clean_input
    GROUP BY anno
),
serie AS (
    SELECT
        anno,
        CAST(ata_totale AS BIGINT) AS ata_totale,
        LAG(ata_totale) OVER (ORDER BY anno) AS ata_anno_precedente
    FROM annuale
)
SELECT
    anno,
    ata_totale,
    CAST(ata_totale - ata_anno_precedente AS BIGINT) AS delta_ata,
    ROUND(
        100.0 * (ata_totale - ata_anno_precedente)
        / NULLIF(ata_anno_precedente, 0),
        2
    ) AS variazione_pct
FROM serie
