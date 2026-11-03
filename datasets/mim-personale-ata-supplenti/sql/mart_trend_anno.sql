-- Mart: serie storica multi-anno dei supplenti ATA.
-- Grano: anno. Delta e variazione % sull'anno precedente.

WITH annuale AS (
    SELECT
        anno,
        SUM(ata_supplenti_totale) AS ata_supplenti_totale
    FROM clean_input
    GROUP BY anno
),
serie AS (
    SELECT
        anno,
        CAST(ata_supplenti_totale AS BIGINT) AS ata_supplenti_totale,
        LAG(ata_supplenti_totale) OVER (ORDER BY anno) AS ata_supplenti_anno_precedente
    FROM annuale
)
SELECT
    anno,
    ata_supplenti_totale,
    CAST(ata_supplenti_totale - ata_supplenti_anno_precedente AS BIGINT) AS delta_ata_supplenti,
    ROUND(
        100.0 * (ata_supplenti_totale - ata_supplenti_anno_precedente)
        / NULLIF(ata_supplenti_anno_precedente, 0),
        2
    ) AS variazione_pct
FROM serie
