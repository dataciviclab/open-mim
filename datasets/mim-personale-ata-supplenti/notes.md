# Notes — mim-personale-ata-supplenti

## Fonte e formato

- CSV MIM `ATASUP`, un file per anno scolastico, delimitatore `,`, UTF-8, header.
- URL base: `https://dati.istruzione.it/opendata/opendata/catalogo/elements1/ATASUP`
- **attenzione al 2020/21**: il file è `ATASUP20202120200901.csv` (non
  `...20210831.csv`).
- il 2024/25 ha 828 righe (104 province × 2 tipologie × 4 fasce), 56.463
  supplenti ATA.
- `TIPOSUPPLENZA`: `ANNUALE`, `FINO AL TERMINE`.

## Trasformazioni

- `anno` = primi 4 caratteri di `ANNOSCOLASTICO` (`202425` → `2024`).
- `ata_supplenti_totale` = maschi + femmine (`COALESCE(..., 0)`).
- nessun valore mancante osservato sul 2024/25; il clean resta difensivo.

## Quirk noti

- **preflight falso negativo**: `toolkit run preflight` non risolve
  `url_suffix_by_year` (vedi `docs/decisions.md` D-006).
- `PROVINCIA` è una stringa (es. `MASSA-CARRARA`, `REGGIO EMILIA`), non un codice.

## Evoluzione possibile

- quota supplenti sul totale ATA per provincia: join con `mim-personale-ata`
  nel compose `personale-scuola`;
- confronto supplenti docenti (`mim-docenti-supplenti`) per il quadro completo.
