# MIM alunni per corso ed età

## Domanda

- Quali territori mostrano il calo più forte di iscritti nelle scuole primarie statali?
- Qual è la pressione demografica scolastica per ordine e regione?

## Dataset

- fonte principale: MIM `Alunni per corso ed età`
- support dataset: `SCUANAGRAFESTAT` (anagrafica scuole statali)
- download: automatizzato via `url_suffix_by_year` in `dataset.yml`
- anni disponibili: **2016-2025** (10 anni scolastici)
- URL list page: `https://dati.istruzione.it/opendata/opendata/catalogo/elements1/leaf/?area=Studenti&datasetId=DS0010ALUCORSOETASTA`
- licenza dichiarata: `IODL 2.0`

## Perché vale

- granularità a livello scuola + join con anagrafica scuole
- 10 anni di serie storica — trend demografico solido
- forte leggibilità civica sul calo iscrizioni
- join con anagrafica scuole direttamente in clean layer

## Schema clean

| Colonna | Descrizione |
|---|---|
| `anno_scolastico` | Anno scolastico (es. 202324) |
| `codice_scuola` | Codice meccanografico scuola |
| `denominazione_scuola` | Nome della scuola |
| `ordine_scuola` | Primaria / Secondaria I / II |
| `grado_istruzione_scuola` | Classificazione ministeriale |
| `caratteristica_scuola` | Tipologia (statale, paritaria, ecc.) |
| `anno_corso` | Anno di corso |
| `fascia_eta` | Fascia d'età |
| `alunni` | Numero alunni |
| `area_geografica` | Nord / Centro / Sud |
| `regione` | Regione |
| `provincia` | Provincia (sigla) |
| `comune` | Comune |
| `codice_comune_scuola` | Codice ISTAT comune |
| `cap_scuola` | CAP |
| `denominazione_istituto_riferimento` | Istituto di riferimento |

## Output

- **Raw**: CSV per anno scolastico (2016-2025)
- **Clean**: ~300-330k righe/anno, 16 colonne, ~93% copertura join con anagrafica scuole
- **Mart**: 4 tabelle esplicite (vedi tabella in fondo); la gerarchia automatica
  `mart.hierarchy` è stata abbandonata per questo dataset (non calcola metriche derivate)

## Stato

`runnable` — 2016-2025 run completo, clean arricchito con join, mart a gerarchia unica.

## QC

- Clean join: 93% righe con regione (7% scuole non in anagrafica — scuole chiuse/private)
- Mart: 68k righe per livello territoriale + orine scuola + fascia eta
- Tutti gli anni superano validate ✅

## Mart

| Mart | Descrizione |
|---|---|
| `mart_trend_ordine` | Alunni per ordine scolastico × anno (multi-year): delta e variazione % — risponde al calo iscrizioni per ordine |
| `mart_sintesi_regione` | Quota nazionale alunni per regione × ordine |
| `mart_ripetenti_provincia` | Alunni in età non allineata al corso per provincia (ripetenti/anticipatari) — età attesa = corso + offset per ordine |
| `mart_comune` | Dettaglio comunale con quota provinciale |

Le mart rispondono alle domande del README (calo iscrizioni, pressione demografica per ordine/regione) e della mappa domande-risposte (#162 alunni per ordine, #163 province con più ripetenti).
