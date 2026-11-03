-- Compose: personale scolastico per provincia x ordine scolastico.
-- Grano: anno x provincia x ordine_scuola, anni 2016-2024.
--
-- Fonti (clean): mim-docenti-titolari e mim-docenti-supplenti.
-- I nomi provincia sono normalizzati con mapping/province-mim.csv.

WITH province AS (
    SELECT provincia_mim, provincia_normalizzata
    FROM read_csv('{support.province.path}', header=true, delim=',')
),
titolari_raw AS (
    SELECT
        d.anno,
        COALESCE(p.provincia_normalizzata, d.provincia) AS provincia,
        d.ordine_scuola,
        d.docenti_totale
    FROM read_parquet('{support.docenti_titolari.path}/*/*_clean.parquet') d
    LEFT JOIN province p ON d.provincia = p.provincia_mim
    WHERE d.anno BETWEEN 2016 AND 2024
),
titolari AS (
    SELECT
        anno,
        provincia,
        ordine_scuola,
        SUM(docenti_totale) AS docenti_titolari
    FROM titolari_raw
    GROUP BY 1, 2, 3
),
supplenti_raw AS (
    SELECT
        s.anno,
        COALESCE(p.provincia_normalizzata, s.provincia) AS provincia,
        s.ordine_scuola,
        s.docenti_supplenti_totale
    FROM read_parquet('{support.docenti_supplenti.path}/*/*_clean.parquet') s
    LEFT JOIN province p ON s.provincia = p.provincia_mim
    WHERE s.anno BETWEEN 2016 AND 2024
),
supplenti AS (
    SELECT
        anno,
        provincia,
        ordine_scuola,
        SUM(docenti_supplenti_totale) AS docenti_supplenti
    FROM supplenti_raw
    GROUP BY 1, 2, 3
),
chiavi AS (
    SELECT anno, provincia, ordine_scuola FROM titolari
    UNION
    SELECT anno, provincia, ordine_scuola FROM supplenti
)
SELECT
    k.anno,
    k.provincia,
    k.ordine_scuola,
    CAST(COALESCE(t.docenti_titolari, 0) AS BIGINT) AS docenti_titolari,
    CAST(COALESCE(s.docenti_supplenti, 0) AS BIGINT) AS docenti_supplenti,
    CAST(COALESCE(t.docenti_titolari, 0) + COALESCE(s.docenti_supplenti, 0) AS BIGINT) AS docenti_totali,
    ROUND(
        100.0 * COALESCE(s.docenti_supplenti, 0)
        / NULLIF(COALESCE(t.docenti_titolari, 0) + COALESCE(s.docenti_supplenti, 0), 0),
        2
    ) AS quota_supplenti_docenti_pct,
    ROUND(
        COALESCE(t.docenti_titolari, 0) * 1.0
        / NULLIF(COALESCE(s.docenti_supplenti, 0), 0),
        2
    ) AS rapporto_titolari_supplenti
FROM chiavi k
LEFT JOIN titolari t USING (anno, provincia, ordine_scuola)
LEFT JOIN supplenti s USING (anno, provincia, ordine_scuola)
