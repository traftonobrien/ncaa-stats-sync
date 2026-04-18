# ncaa-stats-sync · ncaaStatsSync

[![test-package](https://github.com/traftonobrien/ncaa-stats-sync/actions/workflows/test-package.yml/badge.svg)](https://github.com/traftonobrien/ncaa-stats-sync/actions/workflows/test-package.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

R package and CLI to sync **NCAA Division III** season-to-date player stats and compute **team-level aggregates** (full roster + qualified thresholds) into deterministic JSON.

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

## Outputs

| File | Contents |
|------|----------|
| `pitching-YYYY.json` | Player rows, flat array (Pitch Tracker–compatible) |
| `batting-YYYY.json` | Player rows, flat array |
| `teams-YYYY.json` | Team stat engine: roster totals + qualified-team slices |
| `meta.json` | Sync metadata |

## Team stat engine

After player pulls, the package aggregates by `team_id`:

- **Pitching**: summed IP, ER, H, BB, SO, BF, etc.; team ERA and WHIP; optional **qualified** aggregate (default min **5 IP** per pitcher), aligned with Pitch Tracker’s `computeQualifiedAggregate` idea.
- **Batting**: summed PA components; team AVG / OBP / SLG / OPS; optional qualified hitters (default min **15 PA**).

Configure `min_ip_qualified`, `min_pa_qualified`, and `write_team_stats` in `config.yml`.

## Documentation

- `docs/PUBLISHING_GUIDE.md` — naming, download, CI, plugins
- `docs/LAUNCH_CHECKLIST.md` — release checklist
- `NEWS.md` — version history

## Repo layout

- `R/` — sync, parse, normalize, team engine
- `scripts/sync_ncaa_stats.R` — CLI entry
- `.github/workflows/` — tests + optional nightly sync template (`inst/workflows/sync-ncaa-stats.yml`)
