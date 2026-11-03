# open-mim — DataCivicLab

Questo repository raccoglie **dataset sulla scuola statale italiana** pubblicati
dal Ministero dell'Istruzione e del Merito (MIM), per rispondere a domande
civiche: **chi insegna, dove, con quali contratti, e come cambia nel tempo?**

È un repo **multi-dataset**: ogni dataset vive in `datasets/<slug>/`, le
anagrafiche condivise in `support/`.

- **Stato:** alpha
- **Copertura:** a.s. 2016/17 → 2024/25
- **Unità di analisi:** scuola, provincia, regione (per dataset)

## La domanda civica

**Chi compone il corpo docente della scuola statale italiana, e come cambiano
età, genere e distribuzione territoriale nel tempo?**

Le domande secondarie emergono in Discussions e diventano issue operative.

## Dataset

| Slug | Cosa contiene | Anni | Stato |
|---|---|---|---|
| [`datasets/mim-docenti-titolari`](datasets/mim-docenti-titolari/) | Docenti a tempo indeterminato per provincia, ordine scolastico, tipo posto e fascia d'età | 2016/17–2024/25 | alpha |
| [`datasets/mim-personale-ata`](datasets/mim-personale-ata/) | Personale ATA a tempo indeterminato per provincia e fascia d'età | 2016/17–2024/25 | alpha |
| [`datasets/mim-personale-ata-supplenti`](datasets/mim-personale-ata-supplenti/) | Personale ATA supplente per provincia, tipo supplenza e fascia d'età | 2016/17–2024/25 | alpha |
| [`datasets/mim-alunni-corso-eta`](datasets/mim-alunni-corso-eta/) | Alunni per ordine, anno di corso ed età, per singola scuola e territorio | 2016/17–2024/25 | alpha |
| [`datasets/mim-scuola-infanzia`](datasets/mim-scuola-infanzia/) | Bambini italiani e non italiani nella scuola dell'infanzia, per scuola e territorio | 2017/18–2024/25 | alpha |
| [`support/mim-anagrafica-scuole-statali`](support/mim-anagrafica-scuole-statali/) | Anagrafica scuole statali per anno: chiave di join geografico | 2015/16–2024/25 | support |

Mapping province storiche/varianti: [`mapping/province-mim.csv`](mapping/province-mim.csv) (file statico, non un dataset).
| [`compose/scuola-base`](compose/scuola-base/) | Base analitica: alunni + docenti + ATA per provincia/ordine, con rapporti e quote | 2016/17–2024/25 | alpha |

Roadmap (non ancora in contratto):

- `mim-docenti-supplenti` — supplenti per tipo supplenza e contratto
- `mim-personale-ata-supplenti` — ATA supplenti
- edilizia scolastica e bilancio integrato delle scuole

Definizioni dettagliate: [`docs/data_dictionary.md`](docs/data_dictionary.md)

## Perché fidarsi

- fonte ufficiale e verificabile: portale unico dei dati della scuola MIM
  ([`docs/sources.md`](docs/sources.md))
- trasformazioni documentate ([`docs/decisions.md`](docs/decisions.md))
- controlli automatici prima della pubblicazione (CI + contract test)
- standard condivisi del DataCivicLab ([`.github`](https://github.com/dataciviclab/.github))

## Partecipa

- **Discussions** → domande civiche, interpretazioni, proposte di metriche
- **Issues** → bug, problemi tecnici, miglioramenti della pipeline

```
domanda civica → Discussion → Issue → analisi / notebook / output
```

## Cos'è questa repo

È il repo operativo che nasce da `project-template` (modello multi-dataset,
ADR-001):

- `datasets/` + `support/` — contratti dei dataset (`dataset.yml` + `sql/`)
- `Makefile` — interfaccia stabile: `make check`, `make run`, `make test`
- `pyproject.toml` — dipendenze e config (nessun `requirements.txt` duplicato)
- `docs/` — documentazione locale
- `tests/` — contract test minimi
- `.github/` — workflow condivisi (CI, pipeline)

## Confine con il toolkit

Il motore della pipeline vive nel repository `toolkit`. Questa repo non replica
la logica di esecuzione: definisce input, regole e output attesi per ogni dataset.

- bug o feature di CLI, runner, validazioni runtime → repo `toolkit`
- bug o modifiche a fonti, mapping, SQL, mart, docs → questa repo

## Esecuzione tecnica

```bash
pip install -e ".[dev,pipeline]"
make check        # valida tutti i dataset.yml (preflight)
make run-all      # esegue i support dataset e i dataset (RAW → CLEAN → MART)
make test         # contract test della repo
```

Nota di contratto:

- i path relativi in `dataset.yml` sono risolti rispetto alla directory del
  file (ogni dataset ha `root: "../../out"`), non al cwd
- `metadata.json` è il payload ricco del layer; `manifest.json` il summary stabile
- `out/data/_runs/.../<run_id>.json` è il run record letto da `status`

Per dettagli più profondi su CLI e contratti: repo `toolkit`.

## Dove andare per il resto

- contesto del Lab, mappa delle repo, catalogo dataset: `dataciviclab`
- policy comuni, onboarding GitHub, template: `.github`
- motore tecnico della pipeline: `toolkit`

Riferimenti rapidi: [`docs/lab_links.md`](docs/lab_links.md)
