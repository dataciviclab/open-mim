-- Clean: docenti titolari MIM (DOCTIT)
-- RAW -> CLEAN: normalizza le colonne testuali, tipizza i conteggi e deriva
-- l'anno di inizio dell'anno scolastico (202425 -> 2024).
-- Macro standard: cast_int / normalize_string.

WITH raw AS (
    SELECT
        normalize_string(ANNOSCOLASTICO) AS anno_scolastico,
        normalize_string(PROVINCIA)      AS provincia,
        normalize_string(ORDINESCUOLA)   AS ordine_scuola,
        normalize_string(TIPOPOSTO)      AS tipo_posto,
        normalize_string(FASCIAETA)      AS fascia_eta,
        cast_int(DOCENTITITOLARIMASCHI)  AS docenti_maschile,
        cast_int(DOCENTITITOLARIFEMMINE) AS docenti_femminile
    FROM raw_input
)
SELECT
    CAST(SUBSTR(anno_scolastico, 1, 4) AS INTEGER) AS anno,
    anno_scolastico,
    provincia,
    ordine_scuola,
    tipo_posto,
    fascia_eta,
    docenti_maschile,
    docenti_femminile,
    COALESCE(docenti_maschile, 0) + COALESCE(docenti_femminile, 0) AS docenti_totale
FROM raw
WHERE provincia IS NOT NULL
  AND ordine_scuola IS NOT NULL
  AND fascia_eta IS NOT NULL
