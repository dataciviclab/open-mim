# Fonti ufficiali - Scuola statale italiana (MIM)

## Fonte primaria

- ente: Ministero dell'Istruzione e del Merito (MIM)
- pagina ufficiale: <https://dati.istruzione.it/opendata/opendata/catalogo/>
- licenza: IODL 2.0 (Italian Open Data License)
- `source_id` in source-observatory: `mim_opendata`

Base URL dei file: `https://dati.istruzione.it/opendata/opendata/catalogo/elements1/`

## Dataset e file

### `mim-docenti-titolari` — `DOCTIT`

Docenti a tempo indeterminato, scuola statale, per provincia. Anni di run =
anno di inizio a.s. (2016 → a.s. 2016/17).

| Anno | File |
|---|---|
| 2016 | `DOCTIT20161720170831.csv` |
| 2017 | `DOCTIT20171820180831.csv` |
| 2018 | `DOCTIT20181920190831.csv` |
| 2019 | `DOCTIT20192020200831.csv` |
| 2020 | `DOCTIT20202120200901.csv` |
| 2021 | `DOCTIT20212220220831.csv` |
| 2022 | `DOCTIT20222320230831.csv` |
| 2023 | `DOCTIT20232420240831.csv` |
| 2024 | `DOCTIT20242520250831.csv` |

### `mim-personale-ata` — `ATATIT`

Personale ATA a tempo indeterminato, scuola statale, per provincia e fascia
d'età. Anni di run = anno di inizio a.s. (2016 → a.s. 2016/17).

| Anno | File |
|---|---|
| 2016–2024 | `ATATIT20161720170831.csv` … `ATATIT20242520250831.csv` |

Eccezione: 2020/21 → `ATATIT20202120200901.csv` (non `...20210831.csv`).

### `mim-personale-ata-supplenti` — `ATASUP`

Personale ATA supplente, scuola statale, per provincia, tipo supplenza e fascia
d'età. Anni di run = anno di inizio a.s. (2016 → a.s. 2016/17).

| Anno | File |
|---|---|
| 2016–2024 | `ATASUP20161720170831.csv` … `ATASUP20242520250831.csv` |

Eccezione: 2020/21 → `ATASUP20202120200901.csv`.

### `mim-alunni-corso-eta` — `ALUCORSOETASTA`

Alunni per ordine, anno di corso e fascia d'età, scuola statale. Anni di run =
anno di pubblicazione (fine a.s.).

| Anno | File |
|---|---|
| 2016–2025 | `ALUCORSOETASTA20151620160831.csv` … `ALUCORSOETASTA20242520250831.csv` |

### `mim-scuola-infanzia` — `INFANZIASTRACITSTA`

Bambini italiani e non italiani nella scuola dell'infanzia statale.

| Anno | File |
|---|---|
| 2018–2025 | `INFANZIASTRACITSTA20171820180831.csv` … `INFANZIASTRACITSTA20242520250831.csv` |

2017 non disponibile: il server restituisce HTML invece del CSV.

### `support/mim-anagrafica-scuole-statali` — `SCUANAGRAFESTAT`

Anagrafica degli edifici scolastici statali (chiave `CODICESCUOLA`), uno
snapshot per anno scolastico.

| Anno | File |
|---|---|
| 2015–2024 | `SCUANAGRAFESTAT20151620160831.csv` … `SCUANAGRAFESTAT20242520250831.csv` |

Eccezioni nel nome file: 2017/18 → `...20171820170901.csv`.

## Versioning

- un file per anno scolastico, pubblicato a fine agosto dell'anno successivo
- la mappa `url_suffix_by_year` in ogni `dataset.yml` elenca esplicitamente il
  suffisso per anno: i nomi file non seguono un pattern unico
- `DOCTIT` 2020/21 è l'eccezione nota: `...20200901.csv` (non `...20210831.csv`)

## Note su qualità e pubblicazione

- CSV con delimitatore `,`, header, encoding UTF-8
- valori testuali in maiuscolo (`PROVINCIA`, `ORDINESCUOLA`, `FASCIAETA`)
- la provincia è una denominazione, non un codice ISTAT
- l'anagrafica 2024/25 è completa (50.515 scuole, `CODICESCUOLA` univoco)

## Accesso alternativo

Il portale espone anche un **endpoint SPARQL per dataset**:

```
POST https://dati.istruzione.it/opendata/<DATASET>/query
  query=<SPARQL>   dataTypeTxt=json|csv|xml
```

es. `POST https://dati.istruzione.it/opendata/DOCTIT/query`.
Non è ancora usato dalla pipeline (vedi `docs/decisions.md`).
