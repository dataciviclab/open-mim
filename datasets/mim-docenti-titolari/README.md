# mim-docenti-titolari

Docenti a tempo indeterminato della scuola statale italiana, per provincia,
ordine scolastico, tipo posto e fascia d'età.

- **Fonte:** MIM — `DOCTIT` (portale unico dei dati della scuola)
- **Anni:** a.s. 2016/17 → 2024/25 (`anno` = anno di inizio a.s.)
- **Grano:** provincia × ordine × tipo posto × fascia d'età
- **Licenza fonte:** IODL 2.0

## Cosa contiene

Il dataset risponde a domande come: quante docenti donne ci sono in ogni
provincia? Quanto è invecchiato il corpo docente? Dove pesa di più il sostegno?

## Mart

| Mart | Grano | Uso |
|---|---|---|
| `mart_sintesi_provincia` | anno × provincia × ordine | confronto territoriale, quota di genere, quota nazionale |
| `mart_trend_ordine` | anno × ordine | serie storica, delta e variazione % |
| `mart_fasce_eta` | anno × ordine × fascia d'età | invecchiamento del corpo docente |

## Limiti

- aggregazione **provinciale**: nessun dettaglio per scuola o comune
- `provincia` è una denominazione testuale, non un codice ISTAT
- copre i titolari, non i supplenti (vedi roadmap nel README del repo)
- escluso l'a.s. 2015/16 (prefisso file diverso)

## Comandi

```bash
toolkit run --config datasets/mim-docenti-titolari/dataset.yml
```
