# Decision log - Scuola statale italiana (MIM)

Qui registriamo scelte tecniche che cambiano il significato dei dati.

## D-001 — Primo perimetro: docenti titolari (DOCTIT)

- decisione: il primo dataset del repo è `mim-docenti-titolari`, basato sulla
  serie MIM `DOCTIT` (docenti a tempo indeterminato, scuola statale).
- motivo: serie continua e stabile dal 2016/17, schema semplice, alto valore
  civico (genere, età, territorio); gli altri filoni (ATA, supplenti) hanno
  schemi multipli e si aggiungono in passi successivi.
- impatto: il repo nasce con un solo dataset; la roadmap è nel README.

## D-002 — Anno = inizio dell'anno scolastico

- decisione: la colonna `anno` è l'anno di inizio dell'a.s., derivato da
  `ANNOSCOLASTICO` (`202425` → `2024`).
- motivo: allinea `dataset.years` al nome file MIM e rende confrontabili le
  serie tra fonti diverse.
- impatto: l'a.s. 2016/17 ha `anno = 2016`.

## D-003 — Esclusione dell'a.s. 2015/16

- decisione: la serie parte dall'a.s. 2016/17; il file `AS1516DOCTIT20160831.csv`
  non è nel contratto.
- motivo: il prefisso file è diverso (`AS1516`), non componibile con
  `url_suffix_by_year` sulla base `.../DOCTIT`. Richiederebbe una source
  separata.
- impatto: copertura 2016/17 → 2024/25. Da rivalutare se serve la serie completa.

## D-004 — Provincia come testo, nessun join ISTAT implicito

- decisione: `provincia` resta la denominazione MIM normalizzata (trim), senza
  conversione a codice ISTAT nel clean.
- motivo: nessuna corrispondenza univoca dichiarata dalla fonte; un join
  implicito introdurrebbe errori silenziosi (es. province soppresse, città
  metropolitane).
- impatto: eventuali join territoriali vanno fatti in un mart esplicito con
  mapping documentato.

## D-005 — CSV invece di SPARQL (per ora)

- decisione: il raw usa `http_file` sui CSV annuali, non l'endpoint SPARQL
  per-dataset.
- motivo: i CSV sono il formato pubblicato e versionato per anno; l'endpoint
  SPARQL è utile per query ad hoc ma non è ancora un contratto di ingestion
  stabile nel Lab.
- impatto: da valutare come evoluzione (source-observatory protocollo `sparql`).

## D-006 — `make check` non è bloccante su `url_suffix_by_year`

- decisione: si accetta il falso negativo di `toolkit run preflight` sulle
  source MIM con `url_suffix_by_year`; la verifica end-to-end è `toolkit run`.
- motivo: il preflight valida la URL base (senza estensione) e non applica la
  mappa dei suffissi; il run reale applica il suffisso e scarica il CSV.
  Il candidate `mim-alunni-corso-eta` ha lo stesso comportamento.
- impatto: in CI `dataset-config-check-reusable` tratta il preflight come
  non-blocking; in locale `make check` esce 1 e va letto come avviso noto.
  Quando il toolkit risolverà i suffissi in preflight, rimuovere questa deroga.

## D-007 — Migrazione dei dataset MIM da dataset-incubator

- decisione: `mim-alunni-corso-eta`, `mim-scuola-infanzia` e il support
  `mim-anagrafica-scuole-statali` sono migrati da `dataset-incubator`
  (`candidates/` + `support_datasets/`) a questo repo (`datasets/` + `support/`).
- motivo: DI è un repo di intake; a dataset maturi serve un repo dataset
  dedicato, con registry e pipeline propri. I nomi dataset e gli slug mart
  restano invariati, quindi i path GCS pubblicati non cambiano.
- impatto: il support passa da `../../support_datasets/...` a
  `../../support/...`; aggiunto `output.artifacts: standard` e completate le
  validazioni del support (prima vuote). La rimozione da DI avviene nello
  stesso giro: directory eliminate e `registry/registry.json` ripulito dalle
  entry MIM (la pipeline lo rigenererà al prossimo run).

## D-008 — Anni di run non omogenei tra dataset

- decisione: non si armonizza in questa migrazione la semantica di
  `dataset.years`.
- motivo: `mim-docenti-titolari` usa l'anno di **inizio** a.s.
  (2016 → a.s. 2016/17); `mim-alunni-corso-eta` e `mim-scuola-infanzia` usano
  l'anno di **pubblicazione** (fine a.s.: 2016 → file `...20160831.csv`).
  Cambiarla ora modificherebbe i path degli artifact pubblicati.
- impatto: i `dataset.years` non sono confrontabili tra dataset; la colonna
  `anno` / `anno_scolastico` nel clean è la fonte corretta per i confronti.
  Da rivalutare se si crea un `compose/` che unisce più dataset.

## D-009 — Pacchetto base: scuole, studenti, personale

- decisione: il pacchetto base del repo è formato da anagrafica scuole
  (support), alunni, docenti titolari, personale ATA e scuola dell'infanzia,
  più il compose `scuola-base`.
- motivo: copre i tre pilastri (scuole, studenti, personale) e permette una
  prima uscita civica verificabile (rapporto alunni/docenti e
  alunni/personale per provincia) senza aggiungere fonti.
- impatto: i supplenti (`DOCSUP`/`ATASUP`) e i domini edilizia/bilancio/PON
  restano fuori dal base (v0.2/v0.3).

## D-010 — Allineamento anni nel compose

- decisione: nel compose `scuola-base` l'anno è sempre l'**inizio** dell'anno
  scolastico; per gli alunni è derivato da `anno_scolastico` (`201617` → `2016`).
- motivo: i tre dataset usano convenzioni diverse (D-008); senza derivazione il
  join alunni/docenti sarebbe sfalsato di un anno.
- impatto: il compose filtra `anno BETWEEN 2016 AND 2024`, escludendo il
  2015/16 degli alunni che non ha controparte docenti/ATA.

## D-011 — Compose con support `file` (limite del toolkit)

- decisione: `compose/scuola-base` dichiara i dataset di input come support
  `file` sulle directory clean, non come support `dataset`.
- motivo: l'ensure del support `dataset` cerca ogni tabella mart nella dir
  dell'anno, ma i mart multi-anno (`mart_trend_ordine`, `mart_trend_anno`)
  sono scritti alla root del dataset. Il check fallisce con
  "Support dataset output mancante". Il limite è nel toolkit (anche su `main`).
- impatto: il compose legge `<dir>/*/*_clean.parquet`; il Makefile esegue i
  dataset prima del compose. Da riportare a support `dataset` quando il
  toolkit gestirà i mart multi-anno nell'ensure.

## D-012 — Infanzia nel compose e nomi provincia storici

- decisione: il compose include l'infanzia (da `mim-scuola-infanzia`) come
  quarto ordine, con `bambini_totale` come `alunni`.
- motivo: `mim-alunni-corso-eta` copre solo primaria e secondaria; senza
  infanzia il totale docenti del compose perdeva ~85k docenti/anno
  (il 10-11%).
- impatto: nel 2016/17 l'infanzia non esiste (serie dal 2017/18), quindi le
  righe infanzia hanno `alunni` NULL e il totale aggregato 2016/17 non è
  confrontabile. Inoltre 9 nomi provincia storici nei docenti (2016-17, ~2,7%)
  non coincidono con l'anagrafica 2024/25: per quelle province `alunni` è NULL.
  Una mappatura province è rinviata a v0.2.

## D-013 — v0.2: supplenti

- decisione: la fase 2 parte da `mim-personale-ata-supplenti` (ATASUP),
  poi `mim-docenti-supplenti` (DOCSUP + DOCSUPXXV).
- motivo: ATASUP è un clone semplice di `mim-personale-ata` (stesso periodo,
  stesso pattern file, in più `TIPOSUPPLENZA`); DOCSUP richiede l'unione di due
  serie con schema diverso ed è il pezzo più delicato.
- impatto: la quota supplenti sul totale ATA per provincia arriverà con il
  compose `personale-scuola`; `DOCSUP` 2016-2022 vs 2023-2024 non è
  perfettamente comparabile (la fonte cambia il conteggio di spezzoni e
  finalizzati al ruolo) e andrà dichiarato.
