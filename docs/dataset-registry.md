# Dataset Registry

Audience: Maintainers

Catalogo locale dei dataset, dei support e dei compose del repo. Il registry
pubblico (`registry/registry.json`) è generato dalla pipeline: questo file è la
mappa leggibile per chi lavora nel repo.

## Dataset

| Slug | Fonte | Anni | Grano |
|---|---|---|---|
| `mim-docenti-titolari` | MIM `DOCTIT` | 2016–2024 (a.s. 2016/17–2024/25) | provincia × ordine × tipo posto × fascia d'età |
| `mim-personale-ata` | MIM `ATATIT` | 2016–2024 (a.s. 2016/17–2024/25) | provincia × fascia d'età |
| `mim-alunni-corso-eta` | MIM `ALUCORSOETASTA` | 2016–2025 (a.s. 2015/16–2024/25) | scuola × ordine × anno di corso × fascia d'età |
| `mim-scuola-infanzia` | MIM `INFANZIASTRACITSTA` | 2018–2025 (a.s. 2017/18–2024/25) | scuola × cittadinanza |
| `support/mim-anagrafica-scuole-statali` | MIM `SCUANAGRAFESTAT` | 2024 (a.s. 2024/25) | scuola (`CODICESCUOLA`) |
| `compose/scuola-base` | composizione | 2016–2024 | provincia × ordine / provincia |

## Mart

| Mart | Dataset | Grano | Uso |
|---|---|---|---|
| `mart_sintesi_provincia` | `mim-docenti-titolari` | anno × provincia × ordine | confronto territoriale e quota di genere |
| `mart_trend_ordine` | `mim-docenti-titolari` | anno × ordine (multi-anno) | serie storica e variazioni |
| `mart_fasce_eta` | `mim-docenti-titolari` | anno × ordine × fascia d'età | invecchiamento del corpo docente |
| `mart_sintesi_provincia` | `mim-personale-ata` | anno × provincia | totale ATA, quota di genere, quota nazionale |
| `mart_trend_anno` | `mim-personale-ata` | anno (multi-anno) | serie storica ATA e variazioni |
| `mart_fasce_eta` | `mim-personale-ata` | anno × fascia d'età | invecchiamento del personale ATA |
| `mart_trend_ordine` | `mim-alunni-corso-eta` | anno_scolastico × ordine (multi-anno) | calo iscrizioni per ordine |
| `mart_sintesi_regione` | `mim-alunni-corso-eta` | regione × ordine | quota nazionale alunni |
| `mart_ripetenti_provincia` | `mim-alunni-corso-eta` | provincia × ordine | alunni in età non allineata al corso |
| `mart_comune` | `mim-alunni-corso-eta` | comune × ordine | dettaglio comunale, quota provinciale |
| `mart_trend_cittadinanza` | `mim-scuola-infanzia` | anno_scolastico (multi-anno) | serie italiani/non italiani e quota stranieri |
| `mart_sintesi_regione` | `mim-scuola-infanzia` | regione | divari regionali nella presenza straniera |
| `mart_comune` | `mim-scuola-infanzia` | comune | dettaglio comunale, quota provinciale |
| `mart_scuole_statali_geo` | `support/mim-anagrafica-scuole-statali` | scuola | anagrafica geografica per join |
| `mart_scuola_ordine` | `compose/scuola-base` | anno × provincia × ordine | alunni + docenti, rapporto e quote |
| `mart_scuola_provincia` | `compose/scuola-base` | anno × provincia | alunni + docenti + ATA, rapporti |

## Colonne chiave

- `anno` — anno di inizio a.s. (`mim-docenti-titolari`, `mim-personale-ata`, compose)
- `anno_scolastico` — stringa `AAAABB` (es. `202425`) negli altri dataset
- `codice_scuola` — codice meccanografico MIM (chiave di join)
- `provincia` — denominazione MIM (non codice ISTAT)
- `ordine_scuola` — infanzia, primaria, secondaria I grado, secondaria II grado
- `tipo_posto` — normale / sostegno (docenti)
- `fascia_eta` — fino a 34, 35–44, 45–54, oltre 54 (personale)
