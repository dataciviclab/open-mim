-- Compose: base della scuola statale per provincia x ordine scolastico.
-- Grano: anno x provincia x ordine_scuola, anni 2016-2024.
--
-- Fonti (clean): mim-alunni-corso-eta (primaria e secondaria, per scuola),
-- mim-scuola-infanzia (infanzia, per scuola), mim-docenti-titolari (provincia).
-- L'anno è l'inizio dell'anno scolastico: per alunni/infanzia è derivato da
-- anno_scolastico ("201617" -> 2016), per i docenti è già la colonna anno.
--
-- Il join parte dai docenti (4 ordini): l'infanzia copre 2017/18-2024/25,
-- quindi nel 2016/17 la riga infanzia ha alunni NULL.

WITH alunni_raw AS (
    SELECT
        CAST(SUBSTR(anno_scolastico, 1, 4) AS INTEGER) AS anno,
        provincia,
        ordine_scuola,
        alunni,
        codice_scuola
    FROM read_parquet('{support.alunni.path}/*/*_clean.parquet')
    WHERE provincia IS NOT NULL
),
alunni AS (
    SELECT
        anno,
        provincia,
        ordine_scuola,
        SUM(alunni) AS alunni,
        COUNT(DISTINCT codice_scuola) AS n_scuole
    FROM alunni_raw
    WHERE anno BETWEEN 2016 AND 2024
    GROUP BY anno, provincia, ordine_scuola
),
infanzia_raw AS (
    SELECT
        CAST(SUBSTR(anno_scolastico, 1, 4) AS INTEGER) AS anno,
        provincia,
        'SCUOLA INFANZIA' AS ordine_scuola,
        bambini_totale AS alunni,
        codice_scuola
    FROM read_parquet('{support.infanzia.path}/*/*_clean.parquet')
    WHERE provincia IS NOT NULL
),
infanzia AS (
    SELECT
        anno,
        provincia,
        ordine_scuola,
        SUM(alunni) AS alunni,
        COUNT(DISTINCT codice_scuola) AS n_scuole
    FROM infanzia_raw
    WHERE anno BETWEEN 2016 AND 2024
    GROUP BY anno, provincia, ordine_scuola
),
domanda AS (
    SELECT * FROM alunni
    UNION ALL
    SELECT * FROM infanzia
),
docenti AS (
    SELECT
        anno,
        provincia,
        ordine_scuola,
        SUM(docenti_totale)    AS docenti_titolari,
        SUM(docenti_femminile) AS docenti_femminile,
        SUM(CASE WHEN fascia_eta = 'OLTRE 54' THEN docenti_totale ELSE 0 END) AS docenti_over54
    FROM read_parquet('{support.docenti.path}/*/*_clean.parquet')
    GROUP BY anno, provincia, ordine_scuola
)
SELECT
    d.anno,
    d.provincia,
    d.ordine_scuola,
    CAST(a.alunni AS BIGINT) AS alunni,
    CAST(d.docenti_titolari AS BIGINT) AS docenti_titolari,
    ROUND(a.alunni / NULLIF(d.docenti_titolari, 0), 2) AS rapporto_alunni_docenti,
    ROUND(100.0 * d.docenti_femminile / NULLIF(d.docenti_titolari, 0), 2) AS quota_femminile_docenti_pct,
    ROUND(100.0 * d.docenti_over54 / NULLIF(d.docenti_titolari, 0), 2) AS quota_docenti_over54_pct,
    CAST(a.n_scuole AS BIGINT) AS n_scuole
FROM docenti d
LEFT JOIN domanda a USING (anno, provincia, ordine_scuola)
