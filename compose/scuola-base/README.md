# scuola-base

Compose mart-only che unisce i dataset MIM in una **base analitica** della
scuola statale: alunni, docenti e personale ATA per provincia e ordine
scolastico, anni 2016-2024.

## Mart

| Mart | Grano | Contenuto |
|---|---|---|
| `mart_scuola_ordine` | anno × provincia × ordine | alunni, docenti titolari, rapporto alunni/docenti, quota femminile e over 54 tra i docenti, n. scuole |
| `mart_scuola_provincia` | anno × provincia | alunni, docenti, ATA, rapporto alunni/docenti e rapporto alunni/personale |

## Fonti

- `mim-alunni-corso-eta` (clean) — primaria e secondaria per scuola
- `mim-scuola-infanzia` (clean) — infanzia per scuola
- `mim-docenti-titolari` (clean) — docenti per provincia × ordine
- `mim-personale-ata` (clean) — ATA per provincia

## Nota sull'anno

`anno` è l'anno di **inizio** dell'anno scolastico. Per gli alunni è derivato da
`anno_scolastico` (`201617` → `2016`); per docenti e ATA è già la colonna `anno`.
Così le tre fonti si allineano sullo stesso anno scolastico.

## Limiti

- docenti e ATA sono **provinciali**: non esiste un rapporto per singola scuola
- il rapporto alunni/personale include ATA, quindi non è un rapporto
  alunni/docenti (quello è nella colonna dedicata)
- l'infanzia parte dal 2017/18: nel 2016/17 le righe infanzia hanno `alunni`
  NULL e il totale aggregato non è confrontabile con gli anni successivi
- 9 nomi provincia storici nei docenti (2016-17, ~2,7% dei docenti) non
  coincidono con l'anagrafica 2024/25; per quelle province `alunni` è NULL

## Comandi

```bash
toolkit run --config compose/scuola-base/dataset.yml
```
