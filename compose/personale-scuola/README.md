# personale-scuola

Compose mart-only che unisce titolari e supplenti (docenti e ATA) in una base
del personale scolastico, anni 2016-2024.

## Mart

| Mart | Grano | Contenuto |
|---|---|---|
| `mart_personale_ordine` | anno × provincia × ordine | docenti titolari e supplenti, totale, quota supplenti, rapporto titolari/supplenti |
| `mart_personale_provincia` | anno × provincia | docenti e ATA, titolari e supplenti, totali, quote supplenti, rapporto titolari/supplenti |

## Fonti

- `mim-docenti-titolari` (clean)
- `mim-docenti-supplenti` (clean)
- `mim-personale-ata` (clean)
- `mim-personale-ata-supplenti` (clean)

## Note

- ATA non hanno `ordine_scuola`: il mart per ordine copre solo i docenti; il
  mart per provincia aggrega tutto.
- i nomi provincia sono normalizzati con `mapping/province-mim.csv`.

## Limiti

- docenti e ATA sono **provinciali**: non esiste un rapporto per singola scuola
- la quota supplenti docenti attraversa il 2023/24, dove la fonte cambia il
  conteggio di spezzoni e finalizzati al ruolo (`mim-docenti-supplenti`)
- `rapporto_titolari_supplenti` è NULL quando i supplenti sono 0

## Comandi

```bash
toolkit run --config compose/personale-scuola/dataset.yml
```
