# Overview - Scuola statale italiana (MIM)

## Cos'è il progetto

Questo progetto organizza i dati pubblici del Ministero dell'Istruzione e del
Merito (MIM) sulla scuola statale italiana. Copre tre filoni: **docenti**,
**alunni per corso ed età**, **bambini della scuola dell'infanzia per
cittadinanza**, con un'**anagrafica scuole** condivisa come chiave di join.

## Dataset

| Dataset | Unità di analisi | Anni |
|---|---|---|
| `mim-docenti-titolari` | provincia × ordine × tipo posto × fascia d'età | 2016/17–2024/25 |
| `mim-personale-ata` | provincia × fascia d'età | 2016/17–2024/25 |
| `mim-personale-ata-supplenti` | provincia × tipo supplenza × fascia d'età | 2016/17–2024/25 |
| `mim-alunni-corso-eta` | scuola × ordine × anno di corso × fascia d'età | 2016/17–2024/25 |
| `mim-scuola-infanzia` | scuola × cittadinanza | 2017/18–2024/25 |
| `support/mim-anagrafica-scuole-statali` | scuola (anagrafica) | 2024/25 |
| `compose/scuola-base` | provincia × ordine / provincia | 2016/17–2024/25 |

## Copertura

- anni coperti: a.s. 2016/17 → 2024/25 (docenti e alunni), 2017/18 → 2024/25 (infanzia)
- territorio: nazionale, con dettaglio regionale/provinciale; alunni e infanzia
  scendono al singolo edificio scolastico (via `CODICESCUOLA`)
- note: la scuola dell'infanzia 2017/18 non è disponibile sul portale (il server
  restituisce HTML); l'anagrafica è l'unico anno 2024/25

## Domande civiche che puoi esplorare

- il calo demografico: quali ordini e territori perdono più alunni
- chi insegna: età, genere e distribuzione territoriale di docenti e ATA
- il rapporto alunni/docenti e alunni/personale per provincia
- la presenza di bambini non italiani nella scuola dell'infanzia, per regione e comune
- gli alunni in età non allineata al corso (ripetenti/anticipatari) per provincia
- il confronto del proprio territorio con la media nazionale

## Limiti e caveat

- i dati dipendono dalla qualità e dalla tempestività delle fonti ufficiali
- `provincia` è una denominazione testuale, non un codice ISTAT
- il join scuola→territorio copre ~93% delle scuole (il resto: scuole chiuse,
  paritarie o non presenti nell'anagrafica dell'anno)
- `anno_scolastico` è una stringa `AAAABB` (es. `202425`); l'anno di inizio è
  derivato dove serve
- i docenti sono aggregati per provincia: nessun dettaglio per singola scuola

## Metodo

Raccolta del CSV ufficiale MIM, pulizia e normalizzazione (clean), produzione di
tabelle finali (mart) per analisi e output pubblici. Per dettagli tecnici, vedi
il repository Toolkit DataCivicLab.
