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
