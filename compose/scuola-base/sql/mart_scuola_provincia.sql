-- Compose: base della scuola statale per provincia.
-- Grano: anno x provincia, anni 2016-2024.
--
-- Fonti (clean): mim-alunni-corso-eta (primaria+secondaria),
-- mim-scuola-infanzia (infanzia), mim-docenti-titolari, mim-personale-ata.
-- Il rapporto alunni/personale usa docenti + ATA, entrambi provinciali.

WITH alunni_raw AS (
    SELECT
        CAST(SUBSTR(anno_scolastico, 1, 4) AS INTEGER) AS anno,
        provincia,
        alunni
    FROM read_parquet('{support.alunni.path}/*/*_clean.parquet')
    WHERE provincia IS NOT NULL
),
infanzia_raw AS (
    SELECT
        CAST(SUBSTR(anno_scolastico, 1, 4) AS INTEGER) AS anno,
        provincia,
        bambini_totale AS alunni
    FROM read_parquet('{support.infanzia.path}/*/*_clean.parquet')
    WHERE provincia IS NOT NULL
),
domanda AS (
    SELECT * FROM alunni_raw
    UNION ALL
    SELECT * FROM infanzia_raw
),
alunni AS (
    SELECT
        anno,
        provincia,
        SUM(alunni) AS alunni
    FROM domanda
    WHERE anno BETWEEN 2016 AND 2024
    GROUP BY anno, provincia
),
docenti AS (
    SELECT
        anno,
        provincia,
        SUM(docenti_totale) AS docenti_titolari
    FROM read_parquet('{support.docenti.path}/*/*_clean.parquet')
    GROUP BY anno, provincia
),
ata AS (
    SELECT
        anno,
        provincia,
        SUM(ata_totale) AS ata_titolari
    FROM read_parquet('{support.ata.path}/*/*_clean.parquet')
    GROUP BY anno, provincia
)
SELECT
    d.anno,
    d.provincia,
    CAST(a.alunni AS BIGINT) AS alunni,
    CAST(d.docenti_titolari AS BIGINT) AS docenti_titolari,
    CAST(COALESCE(t.ata_titolari, 0) AS BIGINT) AS ata_titolari,
    ROUND(a.alunni / NULLIF(d.docenti_titolari, 0), 2) AS rapporto_alunni_docenti,
    ROUND(
        a.alunni / NULLIF(d.docenti_titolari + COALESCE(t.ata_titolari, 0), 0),
        2
    ) AS rapporto_alunni_personale
FROM docenti d
LEFT JOIN alunni a USING (anno, provincia)
LEFT JOIN ata t USING (anno, provincia)
