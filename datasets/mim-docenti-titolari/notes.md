# Notes — mim-docenti-titolari

## Fonte e formato

- CSV MIM `DOCTIT`, un file per anno scolastico, delimitatore `,`, UTF-8, header.
- URL base: `https://dati.istruzione.it/opendata/opendata/catalogo/elements1/DOCTIT`
- il nome file non segue un pattern unico: la mappa `url_suffix_by_year` in
  `dataset.yml` elenca esplicitamente il suffisso di ogni anno.
- il 2024/25 ha 3.292 righe, 104 province, 4 ordini, 2 tipi posto, 4 fasce d'età.
- **attenzione al 2020/21**: il file è `DOCTIT20202120200901.csv` (non
  `...20210831.csv`). Gli altri anni finiscono con `0831`.

## Trasformazioni

- `anno` = primi 4 caratteri di `ANNOSCOLASTICO` (`202425` → `2024`).
- `docenti_totale` = maschi + femmine (`COALESCE(..., 0)`).
- nessun valore mancante osservato sul 2024/25; il clean resta difensivo.

## Quirk noti

- **preflight falso negativo**: `toolkit run preflight` non risolve
  `url_suffix_by_year`, quindi segnala la source come `unsupported_format`
  sulla URL base (che non ha estensione). Il run reale funziona (9/9 anni
  validati). Stesso comportamento del candidate `mim-alunni-corso-eta`.
  In CI il preflight è non-blocking; in locale `make check` esce 1.
- **a.s. 2015/16 escluso**: il file è `AS1516DOCTIT20160831.csv`, con prefisso
  diverso dalla base `DOCTIT`. Includerlo richiede una source separata.
- `PROVINCIA` è una stringa (es. `MASSA-CARRARA`, `REGGIO EMILIA`), non un
  codice. Nessun join ISTAT implicito (vedi `docs/decisions.md` D-004).
- `ORDINESCUOLA` include solo 4 ordini; la scuola dell'infanzia è presente.
- `TIPOPOSTO` è `NORMALE` o `SOSTEGNO`.

## Evoluzione possibile

- aggiungere ATA titolari (`ATATIT`) e supplenti (`ATASUP`, `DOCSUPXXV`) come
  dataset separati e poi un `compose/` per l'organico complessivo;
- valutare l'endpoint SPARQL per-dataset come source alternativa;
- mappare le province su codici ISTAT in un mart esplicito, con dizionario.
