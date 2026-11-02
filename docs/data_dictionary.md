# Data Dictionary

Audience: Maintainers

Schema sintetico dei dataset gestiti dal progetto.

## Raw — `mim-docenti-titolari`

CSV MIM `DOCTIT` (delimitatore `,`, UTF-8, header).

| Column | Type | Description | Nullable |
| --- | --- | --- | --- |
| ANNOSCOLASTICO | string | Anno scolastico in forma `AAAABB` (es. `202425`) | no |
| PROVINCIA | string | Denominazione della provincia | no |
| ORDINESCUOLA | string | Ordine scolastico | no |
| TIPOPOSTO | string | Tipo posto: `NORMALE` / `SOSTEGNO` | no |
| FASCIAETA | string | Fascia d'età del docente | no |
| DOCENTITITOLARIMASCHI | int | Docenti titolari maschi | no |
| DOCENTITITOLARIFEMMINE | int | Docenti titolari femmine | no |

## Clean — `mim_docenti_titolari`

| Column | Type | Description | Nullable | Validation |
| --- | --- | --- | --- | --- |
| anno | int | Anno di inizio a.s. (es. `2024`) | no | not_null, primary_key |
| anno_scolastico | string | Anno scolastico originale (es. `202425`) | no | — |
| provincia | string | Denominazione provincia | no | not_null, primary_key |
| ordine_scuola | string | Ordine scolastico | no | not_null, primary_key |
| tipo_posto | string | `NORMALE` / `SOSTEGNO` | no | primary_key |
| fascia_eta | string | Fascia d'età | no | not_null, primary_key |
| docenti_maschile | int | Docenti titolari maschi | yes | — |
| docenti_femminile | int | Docenti titolari femmine | yes | — |
| docenti_totale | int | Somma maschi + femmine | yes | — |

## Mart

### `mart_sintesi_provincia` — anno × provincia × ordine

| Column | Type | Description | Nullable |
| --- | --- | --- | --- |
| anno | int | Anno di inizio a.s. | no |
| provincia | string | Provincia | no |
| ordine_scuola | string | Ordine scolastico | no |
| docenti_totale | int | Docenti titolari totali | no |
| docenti_maschile | int | Docenti titolari maschi | yes |
| docenti_femminile | int | Docenti titolari femmine | yes |
| quota_femminile_pct | double | Percentuale docenti donne | yes |
| quota_nazionale_pct | double | Quota sul totale nazionale dell'ordine | yes |

### `mart_trend_ordine` — anno × ordine (multi-anno)

| Column | Type | Description | Nullable |
| --- | --- | --- | --- |
| anno | int | Anno di inizio a.s. | no |
| ordine_scuola | string | Ordine scolastico | no |
| docenti_totale | int | Docenti titolari totali | no |
| delta_docenti | int | Differenza rispetto all'anno precedente | yes |
| variazione_pct | double | Variazione percentuale sull'anno precedente | yes |

### `mart_fasce_eta` — anno × ordine × fascia d'età

| Column | Type | Description | Nullable |
| --- | --- | --- | --- |
| anno | int | Anno di inizio a.s. | no |
| ordine_scuola | string | Ordine scolastico | no |
| fascia_eta | string | Fascia d'età | no |
| docenti_totale | int | Docenti titolari nella fascia | no |
| quota_pct | double | Quota della fascia sul totale dell'ordine | yes |
