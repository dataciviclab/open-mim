# mim-personale-ata

Personale ATA (amministrativo, tecnico e ausiliario) a tempo indeterminato della
scuola statale italiana, per provincia e fascia d'età.

- **Fonte:** MIM — `ATATIT` (portale unico dei dati della scuola)
- **Anni:** a.s. 2016/17 → 2024/25 (`anno` = anno di inizio a.s.)
- **Grano:** provincia × fascia d'età
- **Licenza fonte:** IODL 2.0

## Cosa contiene

Completa il quadro del personale scolastico insieme a `mim-docenti-titolari`:
quanti ATA ci sono, come si distribuiscono per età e genere, e come cambia
l'organico nel tempo.

## Mart

| Mart | Grano | Uso |
|---|---|---|
| `mart_sintesi_provincia` | anno × provincia | totale ATA, quota di genere, quota nazionale |
| `mart_trend_anno` | anno (multi-anno) | serie storica, delta e variazione % |
| `mart_fasce_eta` | anno × fascia d'età | invecchiamento del personale ATA |

## Limiti

- aggregazione **provinciale**: nessun dettaglio per scuola o ordine scolastico
- `provincia` è una denominazione testuale, non un codice ISTAT
- copre i titolari, non i supplenti (`ATASUP`, roadmap)

## Comandi

```bash
toolkit run --config datasets/mim-personale-ata/dataset.yml
```
