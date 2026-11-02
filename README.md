# open-mim — DataCivicLab

Questo repository raccoglie **dataset sulla scuola statale italiana** pubblicati
dal Ministero dell'Istruzione e del Merito (MIM), per rispondere a domande
civiche: **chi insegna, dove, con quali contratti, e come cambia nel tempo?**

È un repo **multi-dataset**: ogni dataset vive in `datasets/<slug>/`, le
anagrafiche condivise in `support/`.

- **Stato:** alpha
- **Copertura:** a.s. 2016/17 → 2024/25 (in espansione)
- **Unità di analisi:** provincia × ordine scolastico

## La domanda civica

**Chi compone il corpo docente della scuola statale italiana, e come cambiano
età, genere e distribuzione territoriale nel tempo?**

Le domande secondarie emergono in Discussions e diventano issue operative.

## Dataset

| Slug | Cosa contiene | Anni | Stato |
|---|---|---|---|
| [`datasets/mim-docenti-titolari`](datasets/mim-docenti-titolari/) | Docenti a tempo indeterminato per provincia, ordine scolastico, tipo posto e fascia d'età | 2016/17–2024/25 | alpha |

Roadmap (non ancora in contratto):

- `mim-personale-ata` — ATA titolari e supplenti
- `mim-docenti-supplenti` — supplenti per tipo supplenza e contratto
- `support/mim-anagrafica-scuole` — anagrafica scuole statali
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
