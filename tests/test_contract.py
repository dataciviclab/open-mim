"""Contract test per repo dataset multi-dataset (ADR-001).

Verifica la struttura del repo, non il motore del toolkit:
  - layout multi-dataset (datasets/ + support/)
  - ogni dataset espone un contratto minimo (dataset.yml, SQL dichiarati)
  - i path dichiarati sono relativi e POSIX
  - ogni anno dichiarato ha un suffisso URL (serie storica MIM)
  - non si committano output di run (out/)

Markers: contract (contratto pubblico, artifact format).
"""

from __future__ import annotations

import re
import subprocess
from pathlib import Path

import pytest
import yaml

REPO_ROOT = Path(__file__).resolve().parents[1]
REQUIRED_FILES = [
    REPO_ROOT / "Makefile",
    REPO_ROOT / "pyproject.toml",
    REPO_ROOT / "conftest.py",
    REPO_ROOT / "LICENSE",
    REPO_ROOT / "README.md",
    REPO_ROOT / "docs" / "sources.md",
    REPO_ROOT / "docs" / "decisions.md",
    REPO_ROOT / "docs" / "data_dictionary.md",
    REPO_ROOT / ".github" / "workflows" / "ci.yml",
    REPO_ROOT / ".github" / "workflows" / "pipeline.yml",
]


def _iter_dataset_configs() -> list[Path]:
    configs: list[Path] = []
    for dirname in ("datasets", "support"):
        base = REPO_ROOT / dirname
        if base.exists():
            configs.extend(sorted(base.glob("*/dataset.yml")))
    return configs


EXPECTED_DATASETS = {
    "mim-alunni-corso-eta",
    "mim-docenti-titolari",
    "mim-personale-ata",
    "mim-personale-ata-supplenti",
    "mim-scuola-infanzia",
}
EXPECTED_SUPPORT = {"mim-anagrafica-scuole-statali"}
EXPECTED_COMPOSE = {"scuola-base"}


def _iter_compose_configs() -> list[Path]:
    base = REPO_ROOT / "compose"
    return sorted(base.glob("*/dataset.yml")) if base.exists() else []


@pytest.fixture(scope="module")
def dataset_configs() -> list[Path]:
    configs = _iter_dataset_configs()
    assert configs, "Il repo deve dichiarare almeno un dataset in datasets/ o support/"
    return configs


@pytest.mark.contract
def test_required_files_exist() -> None:
    missing = [str(p.relative_to(REPO_ROOT)) for p in REQUIRED_FILES if not p.exists()]
    assert not missing, f"Missing required template files: {missing}"


@pytest.mark.contract
def test_layout_is_multidataset() -> None:
    assert (REPO_ROOT / "datasets").is_dir(), "datasets/ è obbligatoria nel modello multi-dataset"
    assert not (REPO_ROOT / "dataset.yml").exists(), "Nel modello multi-dataset non esiste dataset.yml in root"


@pytest.mark.contract
def test_each_dataset_declares_minimum_contract(dataset_configs: list[Path]) -> None:
    for cfg in dataset_configs:
        dataset = yaml.safe_load(cfg.read_text(encoding="utf-8"))
        rel = str(cfg.relative_to(REPO_ROOT))
        assert dataset.get("schema_version") == 1, f"{rel}: schema_version != 1"
        assert "root" in dataset, f"{rel}: manca root (path relativo a out/)"
        assert "dataset" in dataset, f"{rel}: manca blocco dataset"
        assert dataset["dataset"].get("name"), f"{rel}: manca dataset.name"
        assert isinstance(dataset["dataset"].get("years"), list), f"{rel}: years deve essere una lista"
        assert dataset["dataset"]["years"], f"{rel}: years non deve essere vuota"
        assert "raw" in dataset and dataset["raw"].get("sources"), f"{rel}: manca raw.sources"
        assert dataset["raw"]["sources"][0].get("primary") is True, f"{rel}: la prima source deve essere primary"
        assert dataset["clean"]["sql"], f"{rel}: manca clean.sql"
        assert dataset["clean"].get("required_columns"), f"{rel}: manca clean.required_columns"
        assert dataset["clean"]["validate"].get("primary_key"), f"{rel}: manca clean.validate.primary_key"
        assert dataset["clean"]["validate"].get("not_null"), f"{rel}: manca clean.validate.not_null"
        assert dataset["clean"]["validate"].get("min_rows") >= 1, f"{rel}: min_rows deve essere >= 1"
        assert dataset["mart"]["tables"], f"{rel}: manca mart.tables"
        assert dataset["mart"].get("required_tables"), f"{rel}: manca mart.required_tables"
        assert dataset["mart"]["validate"].get("table_rules"), f"{rel}: manca mart.validate.table_rules"
        assert dataset["validation"]["fail_on_error"] is True, f"{rel}: fail_on_error deve essere true"
        assert dataset["output"]["artifacts"] in {"minimal", "standard", "debug"}, f"{rel}: artifacts non valido"


@pytest.mark.contract
def test_each_year_has_url_suffix(dataset_configs: list[Path]) -> None:
    for cfg in dataset_configs:
        dataset = yaml.safe_load(cfg.read_text(encoding="utf-8"))
        rel = str(cfg.relative_to(REPO_ROOT))
        for source in dataset["raw"]["sources"]:
            suffix_map = source.get("args", {}).get("url_suffix_by_year")
            if not suffix_map:
                continue
            years = set(dataset["dataset"]["years"])
            missing = years - set(suffix_map)
            assert not missing, f"{rel}: anni senza url_suffix_by_year: {sorted(missing)}"


def _iter_path_values(node: object):
    if isinstance(node, dict):
        for key, value in node.items():
            if isinstance(value, str) and key in {"root", "source", "sql", "target", "dir", "path", "filename"}:
                yield key, value
            yield from _iter_path_values(value)
    elif isinstance(node, list):
        for item in node:
            yield from _iter_path_values(item)


@pytest.mark.contract
def test_dataset_paths_are_relative_and_posix(dataset_configs: list[Path]) -> None:
    for cfg in dataset_configs:
        dataset = yaml.safe_load(cfg.read_text(encoding="utf-8"))
        rel = str(cfg.relative_to(REPO_ROOT))
        for key, value in _iter_path_values(dataset):
            if value.startswith("http://") or value.startswith("https://"):
                continue
            assert value, f"{rel}: path vuoto per '{key}'"
            assert "\\" not in value, f"{rel}: path '{key}' deve usare separatori POSIX: {value}"
            assert not value.startswith("/"), f"{rel}: path assoluto POSIX per '{key}': {value}"
            assert not value.startswith("~"), f"{rel}: path home-relative per '{key}': {value}"
            assert not re.match(r"^[A-Za-z]:[\\/]", value), f"{rel}: path Windows per '{key}': {value}"


@pytest.mark.contract
def test_declared_sql_files_exist(dataset_configs: list[Path]) -> None:
    for cfg in dataset_configs:
        dataset = yaml.safe_load(cfg.read_text(encoding="utf-8"))
        cfg_dir = cfg.parent
        rel = str(cfg.relative_to(REPO_ROOT))

        clean_sql = (cfg_dir / dataset["clean"]["sql"]).resolve()
        assert clean_sql.is_file(), f"{rel}: manca clean SQL dichiarato: {dataset['clean']['sql']}"

        for table in dataset["mart"]["tables"]:
            assert table.get("name"), f"{rel}: ogni mart table deve dichiarare un name"
            assert table.get("sql"), f"{rel}: mart '{table['name']}' deve dichiarare un path SQL"
            sql_path = (cfg_dir / table["sql"]).resolve()
            assert sql_path.is_file(), f"{rel}: manca SQL mart dichiarato: {table['sql']}"


@pytest.mark.contract
def test_mart_table_names_are_unique(dataset_configs: list[Path]) -> None:
    for cfg in dataset_configs:
        dataset = yaml.safe_load(cfg.read_text(encoding="utf-8"))
        names = [t["name"] for t in dataset["mart"]["tables"]]
        rel = str(cfg.relative_to(REPO_ROOT))
        assert len(names) == len(set(names)), f"{rel}: nomi mart duplicati: {names}"


@pytest.mark.contract
def test_required_tables_and_rules_match_declared_marts(dataset_configs: list[Path]) -> None:
    for cfg in dataset_configs:
        dataset = yaml.safe_load(cfg.read_text(encoding="utf-8"))
        rel = str(cfg.relative_to(REPO_ROOT))
        names = {t["name"] for t in dataset["mart"]["tables"]}
        required = set(dataset["mart"]["required_tables"])
        rules = set(dataset["mart"]["validate"]["table_rules"].keys())
        assert required <= names, f"{rel}: mart.required_tables non riferisce tabelle dichiarate"
        assert rules <= names, f"{rel}: mart.validate.table_rules non riferisce tabelle dichiarate"


@pytest.mark.contract
def test_dataset_docs_present(dataset_configs: list[Path]) -> None:
    for cfg in dataset_configs:
        base = cfg.parent
        rel = str(base.relative_to(REPO_ROOT))
        assert (base / "README.md").is_file(), f"{rel}: manca README.md"
        assert (base / "notes.md").is_file(), f"{rel}: manca notes.md"


@pytest.mark.contract
def test_base_package_present() -> None:
    datasets = {p.name for p in (REPO_ROOT / "datasets").iterdir() if p.is_dir()}
    support = {p.name for p in (REPO_ROOT / "support").iterdir() if p.is_dir()}
    compose = {p.name for p in (REPO_ROOT / "compose").iterdir() if p.is_dir()}
    assert datasets == EXPECTED_DATASETS, f"Dataset inattesi: {datasets ^ EXPECTED_DATASETS}"
    assert support == EXPECTED_SUPPORT, f"Support inattesi: {support ^ EXPECTED_SUPPORT}"
    assert compose == EXPECTED_COMPOSE, f"Compose inattesi: {compose ^ EXPECTED_COMPOSE}"


@pytest.fixture(scope="module")
def compose_configs() -> list[Path]:
    configs = _iter_compose_configs()
    assert configs, "Il repo deve dichiarare almeno un compose in compose/"
    return configs


@pytest.mark.contract
def test_compose_declares_minimum_contract(compose_configs: list[Path]) -> None:
    for cfg in compose_configs:
        dataset = yaml.safe_load(cfg.read_text(encoding="utf-8"))
        rel = str(cfg.relative_to(REPO_ROOT))
        assert dataset.get("schema_version") == 1, f"{rel}: schema_version != 1"
        assert "root" in dataset, f"{rel}: manca root"
        assert dataset["dataset"].get("name"), f"{rel}: manca dataset.name"
        assert isinstance(dataset["dataset"].get("years"), list) and dataset["dataset"]["years"], f"{rel}: years non valido"
        assert dataset.get("support"), f"{rel}: compose senza support"
        for source in dataset["support"]:
            assert source.get("name"), f"{rel}: support senza name"
            assert source.get("type") in {"dataset", "codelist", "file", "external"}, f"{rel}: support.type non valido"
            if source["type"] == "dataset":
                assert source.get("config"), f"{rel}: support dataset senza config"
            if source["type"] == "file":
                assert source.get("path"), f"{rel}: support file senza path"
        assert dataset["mart"]["tables"], f"{rel}: manca mart.tables"
        assert dataset["mart"].get("required_tables"), f"{rel}: manca mart.required_tables"
        assert dataset["mart"]["validate"].get("table_rules"), f"{rel}: manca mart.validate.table_rules"
        assert dataset["validation"]["fail_on_error"] is True, f"{rel}: fail_on_error deve essere true"
        assert dataset["output"]["artifacts"] in {"minimal", "standard", "debug"}, f"{rel}: artifacts non valido"


@pytest.mark.contract
def test_compose_sql_and_support_exist(compose_configs: list[Path]) -> None:
    for cfg in compose_configs:
        dataset = yaml.safe_load(cfg.read_text(encoding="utf-8"))
        base = cfg.parent
        rel = str(base.relative_to(REPO_ROOT))
        for table in dataset["mart"]["tables"]:
            assert table.get("name") and table.get("sql"), f"{rel}: mart senza name/sql"
            assert (base / table["sql"]).is_file(), f"{rel}: manca SQL {table['sql']}"
        for source in dataset["support"]:
            if source.get("type") == "dataset":
                assert (base / source["config"]).resolve().is_file(), f"{rel}: support config inesistente {source['config']}"


@pytest.mark.contract
def test_compose_docs_present(compose_configs: list[Path]) -> None:
    for cfg in compose_configs:
        base = cfg.parent
        rel = str(base.relative_to(REPO_ROOT))
        assert (base / "README.md").is_file(), f"{rel}: manca README.md"
        assert (base / "notes.md").is_file(), f"{rel}: manca notes.md"


@pytest.mark.contract
def test_province_mapping_present() -> None:
    mapping = REPO_ROOT / "mapping" / "province-mim.csv"
    assert mapping.is_file(), "manca mapping/province-mim.csv"
    lines = mapping.read_text(encoding="utf-8").strip().splitlines()
    assert len(lines) >= 12, "mapping province: attese header + almeno 11 varianti"
    assert lines[0].split(",")[:2] == ["provincia_mim", "provincia_normalizzata"]


@pytest.mark.contract
def test_no_run_outputs_committed() -> None:
    """Nessun output di run deve essere tracciato da git (out/ è gitignored)."""
    try:
        tracked = subprocess.run(
            ["git", "ls-files", "out"],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            check=True,
        ).stdout.splitlines()
    except (OSError, subprocess.CalledProcessError):
        pytest.skip("git non disponibile: controllo output committati saltato")
    offenders = [path for path in tracked if not path.endswith(".gitkeep")]
    assert not offenders, f"Non committare output di run in out/: {offenders}"
