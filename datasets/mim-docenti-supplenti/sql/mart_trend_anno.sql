-- Mart: serie storica multi-anno dei supplenti docenti.
-- Grano: anno. Delta e variazione % sull'anno precedente.

WITH annuale AS (
    SELECT
        anno,
        SUM(docenti_supplenti_totale) AS docenti_supplenti_totale
    FROM clean_input
    GROUP BY anno
),
serie AS (
    SELECT
        anno,
        CAST(docenti_supplenti_totale AS BIGINT) AS docenti_supplenti_totale,
        LAG(docenti_supplenti_totale) OVER (ORDER BY anno) AS docenti_supplenti_anno_precedente
    FROM annuale
)
SELECT
    anno,
    docenti_supplenti_totale,
    CAST(docenti_supplenti_totale - docenti_supplenti_anno_precedente AS BIGINT) AS delta_docenti_supplenti,
    ROUND(
        100.0 * (docenti_supplenti_totale - docenti_supplenti_anno_precedente)
        / NULLIF(docenti_supplenti_anno_precedente, 0),
        2
    ) AS variazione_pct
FROM serie
