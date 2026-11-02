-- Mart: serie storica multi-anno del corpo docente per ordine scolastico.
-- Grano: anno x ordine_scuola. Delta e variazione % sull'anno precedente.

WITH annuale AS (
    SELECT
        anno,
        ordine_scuola,
        SUM(docenti_totale) AS docenti_totale
    FROM clean_input
    GROUP BY anno, ordine_scuola
),
serie AS (
    SELECT
        anno,
        ordine_scuola,
        CAST(docenti_totale AS BIGINT) AS docenti_totale,
        LAG(docenti_totale) OVER (
            PARTITION BY ordine_scuola ORDER BY anno
        ) AS docenti_anno_precedente
    FROM annuale
)
SELECT
    anno,
    ordine_scuola,
    docenti_totale,
    CAST(docenti_totale - docenti_anno_precedente AS BIGINT) AS delta_docenti,
    ROUND(
        100.0 * (docenti_totale - docenti_anno_precedente)
        / NULLIF(docenti_anno_precedente, 0),
        2
    ) AS variazione_pct
FROM serie
