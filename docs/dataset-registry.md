# Dataset Registry

Audience: Maintainers

Catalogo locale dei dataset e dei mart del repo. Il registry pubblico
(`registry/registry.json`) è generato dalla pipeline: questo file è la mappa
leggibile per chi lavora nel repo.

## Dataset

| Slug | Fonte | Anni | Grano |
|---|---|---|---|
| `mim-docenti-titolari` | MIM `DOCTIT` | 2016–2024 (a.s. 2016/17–2024/25) | provincia × ordine × tipo posto × fascia d'età |

## Mart

| Mart | Dataset | Grano | Uso |
|---|---|---|---|
| `mart_sintesi_provincia` | `mim-docenti-titolari` | anno × provincia × ordine | confronto territoriale e quota di genere |
| `mart_trend_ordine` | `mim-docenti-titolari` | anno × ordine (multi-anno) | serie storica e variazioni |
| `mart_fasce_eta` | `mim-docenti-titolari` | anno × ordine × fascia d'età | invecchiamento del corpo docente |

## Colonne chiave

- `anno` — anno di inizio dell'anno scolastico
- `provincia` — denominazione MIM (non codice ISTAT)
- `ordine_scuola` — infanzia, primaria, secondaria I grado, secondaria II grado
- `tipo_posto` — normale / sostegno
- `fascia_eta` — fino a 34, 35–44, 45–54, oltre 54
