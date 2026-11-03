-- Compose: base della scuola statale per provincia x ordine scolastico.
-- Grano: anno x provincia x ordine_scuola, anni 2016-2024.
--
-- Fonti (clean): mim-alunni-corso-eta (primaria e secondaria, per scuola),
-- mim-scuola-infanzia (infanzia, per scuola), mim-docenti-titolari (provincia).
-- L'anno è l'inizio dell'anno scolastico: per alunni/infanzia è derivato da
-- anno_scolastico ("201617" -> 2016), per i docenti è già la colonna anno.
--
-- I nomi provincia (anagrafica storica e docenti) sono normalizzati con il
-- mapping statico mapping/province-mim.csv su ENTRAMBI i lati del join.

WITH province AS (
    SELECT provincia_mim, provincia_normalizzata
    FROM read_csv('{support.province.path}', header=true, delim=',')
),
alunni_raw AS (
    SELECT
        CAST(SUBSTR(a.anno_scolastico, 1, 4) AS INTEGER) AS anno,
        COALESCE(p.provincia_normalizzata, a.provincia) AS provincia,
        a.ordine_scuola,
        a.alunni,
        a.codice_scuola
    FROM read_parquet('{support.alunni.path}/*/*_clean.parquet') a
    LEFT JOIN province p ON a.provincia = p.provincia_mim
    WHERE a.provincia IS NOT NULL
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
        CAST(SUBSTR(i.anno_scolastico, 1, 4) AS INTEGER) AS anno,
        COALESCE(p.provincia_normalizzata, i.provincia) AS provincia,
        'SCUOLA INFANZIA' AS ordine_scuola,
        i.bambini_totale AS alunni,
        i.codice_scuola
    FROM read_parquet('{support.infanzia.path}/*/*_clean.parquet') i
    LEFT JOIN province p ON i.provincia = p.provincia_mim
    WHERE i.provincia IS NOT NULL
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
docenti_raw AS (
    SELECT
        d.anno,
        COALESCE(p.provincia_normalizzata, d.provincia) AS provincia,
        d.ordine_scuola,
        d.docenti_totale,
        d.docenti_femminile,
        d.fascia_eta
    FROM read_parquet('{support.docenti.path}/*/*_clean.parquet') d
    LEFT JOIN province p ON d.provincia = p.provincia_mim
),
docenti AS (
    SELECT
        anno,
        provincia,
        ordine_scuola,
        SUM(docenti_totale)    AS docenti_titolari,
        SUM(docenti_femminile) AS docenti_femminile,
        SUM(CASE WHEN fascia_eta = 'OLTRE 54' THEN docenti_totale ELSE 0 END) AS docenti_over54
    FROM docenti_raw
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
