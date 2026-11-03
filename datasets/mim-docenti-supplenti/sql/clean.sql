-- Clean: docenti supplenti MIM (DOCSUP 2016-2022 + DOCSUPXXV 2023-2024)
-- RAW -> CLEAN: unifica i due schemi (le colonne contratto sono NULL prima del
-- 2023/24, grazie a align_by_header), tipizza i conteggi e deriva l'anno di
-- inizio dell'anno scolastico (202425 -> 2024).
-- Macro standard: cast_int / normalize_string.

WITH raw AS (
    SELECT
        normalize_string(ANNOSCOLASTICO)         AS anno_scolastico,
        normalize_string(PROVINCIA)              AS provincia,
        normalize_string(ORDINESCUOLA)           AS ordine_scuola,
        normalize_string(TIPOPOSTO)              AS tipo_posto,
        normalize_string(TIPOSUPPLENZA)          AS tipo_supplenza,
        normalize_string(FASCIAETA)              AS fascia_eta,
        normalize_string(CONTRATTOFINALRUOLO)    AS contratto_finalizzato_ruolo,
        normalize_string(CONTRATTOORARIOINTERO)  AS contratto_orario_intero,
        cast_int(DOCENTISUPPLENTIMASCHI)         AS docenti_supplenti_maschile,
        cast_int(DOCENTISUPPLENTIFEMMINE)        AS docenti_supplenti_femminile
    FROM raw_input
)
SELECT
    CAST(SUBSTR(anno_scolastico, 1, 4) AS INTEGER) AS anno,
    anno_scolastico,
    provincia,
    ordine_scuola,
    tipo_posto,
    tipo_supplenza,
    fascia_eta,
    contratto_finalizzato_ruolo,
    contratto_orario_intero,
    docenti_supplenti_maschile,
    docenti_supplenti_femminile,
    COALESCE(docenti_supplenti_maschile, 0) + COALESCE(docenti_supplenti_femminile, 0) AS docenti_supplenti_totale
FROM raw
WHERE provincia IS NOT NULL
  AND ordine_scuola IS NOT NULL
  AND fascia_eta IS NOT NULL
