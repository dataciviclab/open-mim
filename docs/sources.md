# Fonti ufficiali - Scuola statale italiana (MIM)

## Fonte primaria

- ente: Ministero dell'Istruzione e del Merito (MIM)
- pagina ufficiale: <https://dati.istruzione.it/opendata/opendata/catalogo/>
- dataset: `DOCTIT` — *Docenti a tempo indeterminato. Scuola statale*
- download: <https://dati.istruzione.it/opendata/opendata/catalogo/elements1/?area=Personale%20Scuola>
- licenza: IODL 2.0 (Italian Open Data License)
- `source_id` in source-observatory: `mim_opendata`

## Serie storica (CSV)

Base URL: `https://dati.istruzione.it/opendata/opendata/catalogo/elements1/`

| Anno (a.s.) | File |
|---|---|
| 2016 (2016/17) | `DOCTIT20161720170831.csv` |
| 2017 (2017/18) | `DOCTIT20171820180831.csv` |
| 2018 (2018/19) | `DOCTIT20181920190831.csv` |
| 2019 (2019/20) | `DOCTIT20192020200831.csv` |
| 2020 (2020/21) | `DOCTIT20202120210831.csv` |
| 2021 (2021/22) | `DOCTIT20212220220831.csv` |
| 2022 (2022/23) | `DOCTIT20222320230831.csv` |
| 2023 (2023/24) | `DOCTIT20232420240831.csv` |
| 2024 (2024/25) | `DOCTIT20242520250831.csv` |

L'a.s. 2015/16 è pubblicato con prefisso diverso (`AS1516DOCTIT20160831.csv`)
ed è escluso dal contratto: da valutare come source aggiuntiva.

## Versioning

- logica versioni: un file per anno scolastico, pubblicato a fine agosto
  dell'anno successivo (data nel nome file, es. `20250831`)
- campi che cambiano nel tempo: la serie `DOCTIT` è stabile dal 2016/17;
  i supplenti (`DOCSUP`) hanno cambiato schema nel 2023/24 (`DOCSUPXXV`)

## Note su qualità e pubblicazione

- CSV con delimitatore `,`, header, encoding UTF-8
- nessun valore mancante sulle colonne usate nel 2024/25
- valori testuali in maiuscolo (`PROVINCIA`, `ORDINESCUOLA`, `FASCIAETA`)
- la provincia è una denominazione, non un codice: nessun join implicito a
  codici ISTAT

## Accesso alternativo

Il portale espone anche un **endpoint SPARQL per dataset**:

```
POST https://dati.istruzione.it/opendata/<DATASET>/query
  query=<SPARQL>   dataTypeTxt=json|csv|xml
```

es. `POST https://dati.istruzione.it/opendata/DOCTIT/query`.
Non è ancora usato dalla pipeline (vedi `docs/decisions.md`).
