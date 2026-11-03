# Notes — personale-scuola

## Contratto compose

- mart-only: nessun `raw`, nessun `clean`
- `support` di tipo `file` sulle directory clean dei dataset; i placeholder
  `{support.<name>.path}` puntano alla dir e il SQL legge
  `<dir>/*/*_clean.parquet` (tutti gli anni)
- `dataset.years: [2024]` è solo l'anno di run: i mart aggregano 2016-2024
- il mapping `mapping/province-mim.csv` è un support `file` ed è applicato a
  tutti i dataset di personale

## Grano e join

- `mart_personale_ordine`: chiavi = unione di docenti titolari e supplenti per
  anno × provincia × ordine; ATA esclusi (non hanno ordine)
- `mart_personale_provincia`: chiavi = unione di docenti/ATA titolari e
  supplenti per anno × provincia; LEFT JOIN delle quattro fonti aggregate
- anni 2016-2024 (il 2015/16 non è nella fonte DOCSUP)

## Scelte

- `quota_supplenti_*_pct` = supplenti / (titolari + supplenti) × 100
- `rapporto_titolari_supplenti` = titolari / supplenti, NULL se supplenti 0
- `quota_supplenti_personale_pct` = (supplenti docenti + supplenti ATA) /
  (titolari + supplenti totali) × 100
- nessuna aggregazione a scuola: le fonti sono provinciali

## Verifica

- `mart_personale_ordine`: 3.744 righe (9 anni × 104 province × 4 ordini)
- `mart_personale_provincia`: 939 righe
- quota supplenti docenti: 14,6% (2016/17) → 24,3% (2024/25)
- il 2023/24 è l'anno di discontinuità della fonte docenti supplenti
  (finalizzati al ruolo e spezzoni): non leggere il salto come trend puro
