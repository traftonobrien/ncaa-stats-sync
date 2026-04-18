# ncaa-stats-sync · ncaaStatsSync

[![test-package](https://github.com/traftonobrien/ncaa-stats-sync/actions/workflows/test-package.yml/badge.svg)](https://github.com/traftonobrien/ncaa-stats-sync/actions/workflows/test-package.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

R package and CLI to sync **NCAA Division III** season-to-date player stats and compute **team-level aggregates** (full roster + qualified thresholds), plus **conference baselines and percentiles** for both player and team views.

## Install

```r
install.packages("remotes")
remotes::install_github("traftonobrien/ncaa-stats-sync")
```

## Quickstart

```bash
cp inst/config/example.yml config.yml
Rscript scripts/sync_ncaa_stats.R --config config.yml --mode incremental
```

Check that R packages and (optionally) Chrome/Chromium are visible before a long run:

```bash
Rscript scripts/ncaa_stats_doctor.R
```

CI-friendly connectivity check (single D3 team, pitching only — **hits the live NCAA site**):

```bash
Rscript scripts/sync_ncaa_stats.R --config config.yml --smoke
```

The sync script exits with status **1** on R errors, or when `--smoke` sees parse/access failures or missing expected checksums.

Package checks (Pandoc-independent local gate):

```bash
make check
```

## Outputs

| File | Contents |
|------|----------|
| `pitching-YYYY.json` | Player rows, flat array |
| `batting-YYYY.json` | Player rows, flat array |
| `teams-YYYY.json` | Team stat engine: roster totals + qualified-team slices |
| `meta.json` | Sync metadata, per-file SHA-256 checksums, detailed results |
| `schema/metrics.yml` | Metric catalog (fields, directionality, formulas) |
| `schema/json/*.json` | JSON Schema (draft 2020-12) for validating published artifacts |

## Team stat engine

After player pulls, the package aggregates by `team_id`:

- **Pitching**: summed IP, ER, H, BB, SO, BF, etc.; team ERA and WHIP; optional **qualified** aggregate (default min **5 IP** per pitcher).
- **Batting**: summed PA components; team AVG / OBP / SLG / OPS; optional qualified hitters (default min **15 PA**).

Configure `min_ip_qualified`, `min_pa_qualified`, and `write_team_stats` in `config.yml`.

## Baselines and percentiles

Each player row is enriched with:
- additional derived stats from base data (pitching: `k9`, `bb9`, `h9`, `hr9`, `go_fo_ratio`, `babip`, `lob_pct`, etc.; batting: `iso`, `babip`, `bb_k_ratio`, `sb_pct`, etc.)
- conference baselines (`conference_mean_<metric>`, `conference_sd_<metric>`, `conference_delta_<metric>`)
- percentile ranks (`overall_percentile_<metric>`, `conference_percentile_<metric>`)

Team outputs in `teams-YYYY.json` include matching conference baselines and percentile columns on key team metrics.

## Documentation

- `NEWS.md` — version history
- `schema/metrics.yml` — metric catalog and formulas
- Vignettes (build with `devtools::build_vignettes()` or site with `pkgdown::build_site()`)

### Product boundary (OSS vs hosted)

This repository is the **open-source sync and JSON contract**: scraping helpers, normalization, team engine, schemas, and static JSON outputs for any consumer. A **separate hosted API or commercial add-on** (not part of this repo) would layer auth, multi-tenant hosting, SLAs, and proprietary analytics on top of the same artifacts — the OSS package stays the offline, forkable, verifiable core.

## Repo layout

- `R/` — sync, parse, normalize, team engine
- `scripts/sync_ncaa_stats.R` — CLI entry (supports `--smoke`, non-zero exit on failure)
- `scripts/ncaa_stats_doctor.R` — environment check
- `.github/workflows/` — tests + optional nightly sync template (`inst/workflows/sync-ncaa-stats.yml`)
