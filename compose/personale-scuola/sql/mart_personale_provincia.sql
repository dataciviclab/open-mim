-- Compose: personale scolastico per provincia.
-- Grano: anno x provincia, anni 2016-2024.
--
-- Fonti (clean): mim-docenti-titolari, mim-docenti-supplenti,
-- mim-personale-ata, mim-personale-ata-supplenti.
-- I nomi provincia sono normalizzati con mapping/province-mim.csv.

WITH province AS (
    SELECT provincia_mim, provincia_normalizzata
    FROM read_csv('{support.province.path}', header=true, delim=',')
),
docenti_titolari_raw AS (
    SELECT
        d.anno,
        COALESCE(p.provincia_normalizzata, d.provincia) AS provincia,
        d.docenti_totale
    FROM read_parquet('{support.docenti_titolari.path}/*/*_clean.parquet') d
    LEFT JOIN province p ON d.provincia = p.provincia_mim
    WHERE d.anno BETWEEN 2016 AND 2024
),
docenti_titolari AS (
    SELECT anno, provincia, SUM(docenti_totale) AS docenti_titolari
    FROM docenti_titolari_raw
    GROUP BY 1, 2
),
docenti_supplenti_raw AS (
    SELECT
        s.anno,
        COALESCE(p.provincia_normalizzata, s.provincia) AS provincia,
        s.docenti_supplenti_totale
    FROM read_parquet('{support.docenti_supplenti.path}/*/*_clean.parquet') s
    LEFT JOIN province p ON s.provincia = p.provincia_mim
    WHERE s.anno BETWEEN 2016 AND 2024
),
docenti_supplenti AS (
    SELECT anno, provincia, SUM(docenti_supplenti_totale) AS docenti_supplenti
    FROM docenti_supplenti_raw
    GROUP BY 1, 2
),
ata_titolari_raw AS (
    SELECT
        a.anno,
        COALESCE(p.provincia_normalizzata, a.provincia) AS provincia,
        a.ata_totale
    FROM read_parquet('{support.ata_titolari.path}/*/*_clean.parquet') a
    LEFT JOIN province p ON a.provincia = p.provincia_mim
    WHERE a.anno BETWEEN 2016 AND 2024
),
ata_titolari AS (
    SELECT anno, provincia, SUM(ata_totale) AS ata_titolari
    FROM ata_titolari_raw
    GROUP BY 1, 2
),
ata_supplenti_raw AS (
    SELECT
        a.anno,
        COALESCE(p.provincia_normalizzata, a.provincia) AS provincia,
        a.ata_supplenti_totale
    FROM read_parquet('{support.ata_supplenti.path}/*/*_clean.parquet') a
    LEFT JOIN province p ON a.provincia = p.provincia_mim
    WHERE a.anno BETWEEN 2016 AND 2024
),
ata_supplenti AS (
    SELECT anno, provincia, SUM(ata_supplenti_totale) AS ata_supplenti
    FROM ata_supplenti_raw
    GROUP BY 1, 2
),
chiavi AS (
    SELECT anno, provincia FROM docenti_titolari
    UNION
    SELECT anno, provincia FROM docenti_supplenti
    UNION
    SELECT anno, provincia FROM ata_titolari
    UNION
    SELECT anno, provincia FROM ata_supplenti
)
SELECT
    k.anno,
    k.provincia,
    CAST(COALESCE(dt.docenti_titolari, 0) AS BIGINT) AS docenti_titolari,
    CAST(COALESCE(ds.docenti_supplenti, 0) AS BIGINT) AS docenti_supplenti,
    CAST(COALESCE(dt.docenti_titolari, 0) + COALESCE(ds.docenti_supplenti, 0) AS BIGINT) AS docenti_totali,
    CAST(COALESCE(ata_t.ata_titolari, 0) AS BIGINT) AS ata_titolari,
    CAST(COALESCE(asup.ata_supplenti, 0) AS BIGINT) AS ata_supplenti,
    CAST(COALESCE(ata_t.ata_titolari, 0) + COALESCE(asup.ata_supplenti, 0) AS BIGINT) AS ata_totali,
    ROUND(
        100.0 * COALESCE(ds.docenti_supplenti, 0)
        / NULLIF(COALESCE(dt.docenti_titolari, 0) + COALESCE(ds.docenti_supplenti, 0), 0),
        2
    ) AS quota_supplenti_docenti_pct,
    ROUND(
        100.0 * COALESCE(asup.ata_supplenti, 0)
        / NULLIF(COALESCE(ata_t.ata_titolari, 0) + COALESCE(asup.ata_supplenti, 0), 0),
        2
    ) AS quota_supplenti_ata_pct,
    ROUND(
        100.0 * (COALESCE(ds.docenti_supplenti, 0) + COALESCE(asup.ata_supplenti, 0))
        / NULLIF(
            COALESCE(dt.docenti_titolari, 0) + COALESCE(ds.docenti_supplenti, 0)
            + COALESCE(ata_t.ata_titolari, 0) + COALESCE(asup.ata_supplenti, 0),
            0
        ),
        2
    ) AS quota_supplenti_personale_pct,
    ROUND(
        (COALESCE(dt.docenti_titolari, 0) + COALESCE(ata_t.ata_titolari, 0)) * 1.0
        / NULLIF(COALESCE(ds.docenti_supplenti, 0) + COALESCE(asup.ata_supplenti, 0), 0),
        2
    ) AS rapporto_titolari_supplenti
FROM chiavi k
LEFT JOIN docenti_titolari dt USING (anno, provincia)
LEFT JOIN docenti_supplenti ds USING (anno, provincia)
LEFT JOIN ata_titolari ata_t USING (anno, provincia)
LEFT JOIN ata_supplenti asup USING (anno, provincia)
