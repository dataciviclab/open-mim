-- Clean: personale ATA titolare MIM (ATATIT)
-- RAW -> CLEAN: normalizza le colonne testuali, tipizza i conteggi e deriva
-- l'anno di inizio dell'anno scolastico (202425 -> 2024).
-- Macro standard: cast_int / normalize_string.

WITH raw AS (
    SELECT
        normalize_string(ANNOSCOLASTICO)  AS anno_scolastico,
        normalize_string(PROVINCIA)       AS provincia,
        normalize_string(FASCIAETA)       AS fascia_eta,
        cast_int(ATATITOLARIMASCHI)       AS ata_maschile,
        cast_int(ATATITOLARIFEMMINE)      AS ata_femminile
    FROM raw_input
)
SELECT
    CAST(SUBSTR(anno_scolastico, 1, 4) AS INTEGER) AS anno,
    anno_scolastico,
    provincia,
    fascia_eta,
    ata_maschile,
    ata_femminile,
    COALESCE(ata_maschile, 0) + COALESCE(ata_femminile, 0) AS ata_totale
FROM raw
WHERE provincia IS NOT NULL
  AND fascia_eta IS NOT NULL
