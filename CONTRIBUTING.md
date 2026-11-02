# Contribuire a open-mim

## Come contribuire

1. Crea un branch (`feat/...` o `fix/...`)
2. Fai le modifiche
3. Apri una PR — la CI valida config e test

## Struttura

```
datasets/<slug>/    dataset.yml + sql/ + notes.md + README.md
support/<slug>/     anagrafiche/dizionari condivisi
docs/               overview, fonti, data dictionary, decisioni
registry/           registry.json (generato dalla pipeline)
tests/              contract test del repo
out/                output pipeline (gitignored)
```

## Aggiungere o modificare un dataset

1. Crea/modifica `datasets/<slug>/dataset.yml` e `sql/`.
2. Documenta fonti in `docs/sources.md` e scelte in `docs/decisions.md`.
3. Aggiorna `docs/data_dictionary.md` e `docs/dataset-registry.md`.
4. Esegui `make check`, `make run-all`, `make test`.
5. Apri una PR con il template del repo.

## Standard

- [Repo](https://github.com/dataciviclab/lab-ops/blob/main/standards/repo.md)
- [Pipeline](https://github.com/dataciviclab/lab-ops/blob/main/standards/pipeline.md)
- [Test](https://github.com/dataciviclab/lab-ops/blob/main/standards/tests.md)
- [Pyproject](https://github.com/dataciviclab/lab-ops/blob/main/standards/pyproject.md)

## Regole

- non committare output di run (`out/`, parquet, csv generati, run record);
- non fondere basi o definizioni diverse;
- documenta ogni cambio di significato in `docs/decisions.md`;
- usa path relativi e POSIX nei contratti (`dataset.yml`).
