# Notes — mim-docenti-supplenti

## Fonte e formato

- due serie MIM, un file per anno scolastico, delimitatore `,`, UTF-8, header:
  - `DOCSUP` (a.s. 2016/17–2022/23): 8 colonne
  - `DOCSUPXXV` (a.s. 2023/24–2024/25): 10 colonne, aggiunge
    `CONTRATTOFINALRUOLO` e `CONTRATTOORARIOINTERO`
- URL base: `https://dati.istruzione.it/opendata/opendata/catalogo/elements1/`
- `url_suffix_by_year` elenca il nome file completo (DOCSUP o DOCSUPXXV) per anno.
- **attenzione al 2020/21**: `DOCSUP20202120200901.csv` (non `...20210831.csv`).
- volumi: 4.606 righe nel 2016/17, 9.989 nel 2024/25.

## Unione degli schemi

- `clean.read` usa `normalize_rows_to_columns: true` + `align_by_header: true`
  con `columns` che dichiara tutte e 10 le colonne raw.
- per gli anni 2016–2022 le due colonne contratto mancano nell'header e vengono
  riempite con **NULL**; il clean le espone comunque.
- `mart_contratti` filtra `contratto_finalizzato_ruolo IS NOT NULL` ed è vuoto
  per il 2016–2022 (`min_rows: 0`).

## Trasformazioni

- `anno` = primi 4 caratteri di `ANNOSCOLASTICO` (`202425` → `2024`).
- `docenti_supplenti_totale` = maschi + femmine (`COALESCE(..., 0)`).

## Comparabilità

- dal 2022/23 la fonte conta già finalizzati al ruolo e spezzoni (nota MIM):
  la serie 2015/16–2022/23 non è perfettamente comparabile con 2023/24–2024/25.
  Va dichiarato nelle analisi che attraversano il 2023.
- `TIPOSUPPLENZA`: `ANNUALE`, `FINO AL TERMINE`.
- `TIPOPOSTO`: `NORMALE`, `SOSTEGNO`.

## Quirk noti

- **preflight falso negativo**: `toolkit run preflight` non risolve
  `url_suffix_by_year` (vedi `docs/decisions.md` D-006).
- `PROVINCIA` è una stringa, non un codice; il compose `personale-scuola`
  applica `mapping/province-mim.csv`.
