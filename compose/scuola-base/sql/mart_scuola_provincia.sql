-- Compose: base della scuola statale per provincia.
-- Grano: anno x provincia, anni 2016-2024.
--
-- Fonti (clean): mim-alunni-corso-eta (primaria+secondaria),
-- mim-scuola-infanzia (infanzia), mim-docenti-titolari, mim-personale-ata.
-- Il rapporto alunni/personale usa docenti + ATA, entrambi provinciali.
-- I nomi provincia (anagrafica storica e personale) sono normalizzati con il
-- mapping statico mapping/province-mim.csv su ENTRAMBI i lati del join.

WITH province AS (
    SELECT provincia_mim, provincia_normalizzata
    FROM read_csv('{support.province.path}', header=true, delim=',')
),
alunni_raw AS (
    SELECT
        CAST(SUBSTR(a.anno_scolastico, 1, 4) AS INTEGER) AS anno,
        COALESCE(p.provincia_normalizzata, a.provincia) AS provincia,
        a.alunni
    FROM read_parquet('{support.alunni.path}/*/*_clean.parquet') a
    LEFT JOIN province p ON a.provincia = p.provincia_mim
    WHERE a.provincia IS NOT NULL
),
infanzia_raw AS (
    SELECT
        CAST(SUBSTR(i.anno_scolastico, 1, 4) AS INTEGER) AS anno,
        COALESCE(p.provincia_normalizzata, i.provincia) AS provincia,
        i.bambini_totale AS alunni
    FROM read_parquet('{support.infanzia.path}/*/*_clean.parquet') i
    LEFT JOIN province p ON i.provincia = p.provincia_mim
    WHERE i.provincia IS NOT NULL
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
docenti_raw AS (
    SELECT
        d.anno,
        COALESCE(p.provincia_normalizzata, d.provincia) AS provincia,
        d.docenti_totale
    FROM read_parquet('{support.docenti.path}/*/*_clean.parquet') d
    LEFT JOIN province p ON d.provincia = p.provincia_mim
),
docenti AS (
    SELECT
        anno,
        provincia,
        SUM(docenti_totale) AS docenti_titolari
    FROM docenti_raw
    GROUP BY anno, provincia
),
ata_raw AS (
    SELECT
        a.anno,
        COALESCE(p.provincia_normalizzata, a.provincia) AS provincia,
        a.ata_totale
    FROM read_parquet('{support.ata.path}/*/*_clean.parquet') a
    LEFT JOIN province p ON a.provincia = p.provincia_mim
),
ata AS (
    SELECT
        anno,
        provincia,
        SUM(ata_totale) AS ata_titolari
    FROM ata_raw
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
