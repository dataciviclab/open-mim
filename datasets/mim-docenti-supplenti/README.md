# mim-docenti-supplenti

Docenti supplenti della scuola statale italiana, per provincia, ordine
scolastico, tipo posto, tipo supplenza e fascia d'età.

- **Fonte:** MIM — `DOCSUP` (a.s. 2015/16–2022/23) + `DOCSUPXXV` (a.s. 2023/24–2024/25)
- **Anni:** a.s. 2016/17 → 2024/25 (`anno` = anno di inizio a.s.)
- **Grano:** provincia × ordine × tipo posto × tipo supplenza × fascia d'età
- **Licenza fonte:** IODL 2.0

## Cosa contiene

Quanti supplenti docenti ci sono, dove, con che tipo di supplenza e in quale
fascia d'età. Insieme a `mim-personale-ata-supplenti` e `mim-docenti-titolari`
permette di leggere il peso del precariato sul totale del personale scolastico.

## Mart

| Mart | Grano | Uso |
|---|---|---|
| `mart_sintesi_provincia` | anno × provincia × ordine | totale supplenti, quota di genere, quota nazionale |
| `mart_trend_anno` | anno (multi-anno) | serie storica, delta e variazione % |
| `mart_tipologia` | anno × tipo supplenza | annuale vs fino al termine |
| `mart_fasce_eta` | anno × fascia d'età | età dei supplenti |
| `mart_contratti` | anno × contratto finalizzato al ruolo × orario intero | solo dal 2023/24 |

## Limiti

- due schemi uniti: `CONTRATTOFINALRUOLO` e `CONTRATTOORARIOINTERO` esistono solo dal 2023/24 (NULL prima)
- dal 2022/23 la fonte include già finalizzati al ruolo e spezzoni: la serie 2015/16–2022/23 **non è perfettamente comparabile** con 2023/24–2024/25
- aggregazione **provinciale**: nessun dettaglio per scuola
- `provincia` è una denominazione testuale, non un codice ISTAT

## Comandi

```bash
toolkit run --config datasets/mim-docenti-supplenti/dataset.yml
```
