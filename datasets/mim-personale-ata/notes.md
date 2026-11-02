# Notes — mim-personale-ata

## Fonte e formato

- CSV MIM `ATATIT`, un file per anno scolastico, delimitatore `,`, UTF-8, header.
- URL base: `https://dati.istruzione.it/opendata/opendata/catalogo/elements1/ATATIT`
- **attenzione al 2020/21**: il file è `ATATIT20202120200901.csv` (non
  `...20210831.csv`). Gli altri anni finiscono con `0831`.
- il 2024/25 ha 416 righe (104 province × 4 fasce d'età), 179.295 ATA titolari.

## Trasformazioni

- `anno` = primi 4 caratteri di `ANNOSCOLASTICO` (`202425` → `2024`).
- `ata_totale` = maschi + femmine (`COALESCE(..., 0)`).
- nessun valore mancante osservato sul 2024/25; il clean resta difensivo.

## Quirk noti

- **preflight falso negativo**: `toolkit run preflight` non risolve
  `url_suffix_by_year` (stesso caveat di `mim-docenti-titolari`, vedi
  `docs/decisions.md` D-006).
- `PROVINCIA` è una stringa (es. `MASSA-CARRARA`, `REGGIO EMILIA`), non un codice.
- nessuna dimensione `ORDINESCUOLA` né `TIPOPOSTO`: il dataset è più semplice
  di quello dei docenti.

## Evoluzione possibile

- aggiungere ATA supplenti (`ATASUP`) per il precariato;
- usare il dataset nel compose `scuola-base` per il rapporto alunni/personale.
