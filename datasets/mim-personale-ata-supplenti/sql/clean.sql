-- Clean: personale ATA supplente MIM (ATASUP)
-- RAW -> CLEAN: normalizza le colonne testuali, tipizza i conteggi e deriva
-- l'anno di inizio dell'anno scolastico (202425 -> 2024).
-- Macro standard: cast_int / normalize_string.

WITH raw AS (
    SELECT
        normalize_string(ANNOSCOLASTICO)   AS anno_scolastico,
        normalize_string(PROVINCIA)        AS provincia,
        normalize_string(TIPOSUPPLENZA)    AS tipo_supplenza,
        normalize_string(FASCIAETA)        AS fascia_eta,
        cast_int(ATASUPPLENTIMASCHI)       AS ata_supplenti_maschile,
        cast_int(ATASUPPLENTIFEMMINE)      AS ata_supplenti_femminile
    FROM raw_input
)
SELECT
    CAST(SUBSTR(anno_scolastico, 1, 4) AS INTEGER) AS anno,
    anno_scolastico,
    provincia,
    tipo_supplenza,
    fascia_eta,
    ata_supplenti_maschile,
    ata_supplenti_femminile,
    COALESCE(ata_supplenti_maschile, 0) + COALESCE(ata_supplenti_femminile, 0) AS ata_supplenti_totale
FROM raw
WHERE provincia IS NOT NULL
  AND tipo_supplenza IS NOT NULL
  AND fascia_eta IS NOT NULL
