# ncaa-stats-sync

`ncaa-stats-sync` is a reusable R package for pulling NCAA leaderboard stats (starting with Division III) on a daily schedule and writing deterministic JSON snapshots.

This package is extracted from the production workflow used in Pitch Tracker, but designed to be portable for any project that needs daily NCAA stat cache files.

## What it does

- Fetches NCAA `season_to_date_stats` pages with a shared Chromote session.
- Retries on transient failures and access-denied challenge pages.
- Parses stat tables and player links from NCAA HTML.
- Writes `pitching-<year>.json`, `batting-<year>.json`, and `meta.json`.
- Supports `full` and `incremental` sync modes.
- Ships with a CLI script and a GitHub Actions workflow template.

## Install (local dev)

```r
install.packages(c(
  "chromote",
  "collegebaseball",
  "jsonlite",
  "rvest",
  "xml2",
  "dplyr",
  "stringr",
  "yaml"
))
```

From this folder:

```r
devtools::load_all(".")
```

## Quickstart

Create a config file:

```r
file.copy("inst/config/example.yml", "config.yml")
```

Run a sync:

```bash
Rscript scripts/sync_ncaa_stats.R --config config.yml --mode incremental
```

Output files:

- `output/college-stats/pitching-2026.json`
- `output/college-stats/batting-2026.json`
- `output/college-stats/meta.json`

## Public repo launch

1. Copy this directory into its own repository.
2. Set `output_dir` in `config.yml`.
3. Add `.github/workflows/sync-ncaa-stats.yml` from `inst/workflows/`.
4. Enable scheduled workflow runs in GitHub Actions.
5. Optionally publish to CRAN or keep as a GitHub package.

See `docs/LAUNCH_CHECKLIST.md` for the full release sequence.
See `docs/PUBLISHING_GUIDE.md` for naming, install/download, and integration options.
