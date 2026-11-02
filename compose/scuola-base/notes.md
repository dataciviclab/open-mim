# Notes — scuola-base

## Contratto compose

- mart-only: nessun `raw`, nessun `clean`
- `support` di tipo `file` sulle directory clean dei dataset; i placeholder
  `{support.<name>.path}` puntano alla dir e il SQL legge
  `<dir>/*/*_clean.parquet` (tutti gli anni)
- il `path` del support `file` è risolto dal loader rispetto alla dir del
  compose (`../../out/...`), non al `root` del dataset
- `dataset.years: [2024]` è solo l'anno di run: i mart aggregano 2016-2024

## Perché `file` e non `dataset`

Il support `dataset` esegue un check "tutti gli output del support esistono
nella dir dell'anno": per i mart multi-anno (es. `mart_trend_ordine`) il file
sta alla root del dataset, non in `<anno>/`, quindi il check fallisce. È un
limite del toolkit (presente anche su `main`). Workaround: `file` sui clean,
con il Makefile che esegue i dataset prima del compose. Da sostituire con
`dataset` quando il toolkit risolverà i mart multi-anno (vedi decisions D-011).

## Allineamento anni

- `mim-alunni-corso-eta` e `mim-scuola-infanzia` usano l'anno di pubblicazione
  (fine a.s.); il compose deriva l'inizio a.s. da `anno_scolastico`
  (`201617` → `2016`)
- `mim-docenti-titolari` e `mim-personale-ata` hanno già `anno` = inizio a.s.
- filtro esplicito `anno BETWEEN 2016 AND 2024`

## Scelte

- il mart per ordine parte dai **docenti** (4 ordini): così l'infanzia è
  inclusa e il totale docenti coincide con DOCTIT
- l'infanzia usa `bambini_totale` come `alunni`, con `ordine_scuola =
  'SCUOLA INFANZIA'`
- niente ATA spalmato per ordine: il rapporto alunni/personale è provinciale
  (`mart_scuola_provincia`), mentre il rapporto per ordine è solo alunni/docenti
- `quota_docenti_over54_pct` usa la fascia `OLTRE 54` del clean docenti

## Verifica (2024/25)

- `mart_scuola_ordine`: 3.768 righe (9 anni × ~104 province × 4 ordini)
- `mart_scuola_provincia`: ~925 righe (9 anni × ~103 province)
- totale docenti 2024 = 739.581, allineato a `mim-docenti-titolari`
- totale alunni 2024 = 6.940.973 (include infanzia ~768k)
- rapporto alunni/docenti aggregato 2024 = 9,39
- 2016/17 non confrontabile: infanzia assente (alunni NULL)
