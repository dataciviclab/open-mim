# mim-personale-ata-supplenti

Personale ATA supplente della scuola statale italiana, per provincia, tipo di
supplenza e fascia d'età.

- **Fonte:** MIM — `ATASUP` (portale unico dei dati della scuola)
- **Anni:** a.s. 2016/17 → 2024/25 (`anno` = anno di inizio a.s.)
- **Grano:** provincia × tipo supplenza × fascia d'età
- **Licenza fonte:** IODL 2.0

## Cosa contiene

Quanti supplenti ATA ci sono, dove, con che tipo di supplenza (annuale o fino al
termine) e con quale età. Insieme a `mim-personale-ata` permette di leggere il
peso del precariato sul totale del personale ATA.

## Mart

| Mart | Grano | Uso |
|---|---|---|
| `mart_sintesi_provincia` | anno × provincia | totale supplenti, quota di genere, quota nazionale |
| `mart_trend_anno` | anno (multi-anno) | serie storica, delta e variazione % |
| `mart_fasce_eta` | anno × fascia d'età | età dei supplenti |
| `mart_tipologia` | anno × tipo supplenza | annuale vs fino al termine |

## Limiti

- aggregazione **provinciale**: nessun dettaglio per scuola o ordine scolastico
- `provincia` è una denominazione testuale, non un codice ISTAT
- la quota sul totale ATA richiede il join con `mim-personale-ata` (compose)

## Comandi

```bash
toolkit run --config datasets/mim-personale-ata-supplenti/dataset.yml
```
