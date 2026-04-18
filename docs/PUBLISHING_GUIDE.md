# Publishing Guide

## Recommended package name

- GitHub repo: `ncaa-stats-sync`
- R package name (already set): `ncaaStatsSync`
- CLI command entrypoint: `scripts/sync_ncaa_stats.R`

## Download and install options for users

## 1) GitHub install (fastest)

```r
install.packages("remotes")
remotes::install_github("<your-username>/ncaa-stats-sync")
```

## 2) Clone and run CLI

```bash
git clone https://github.com/<your-username>/ncaa-stats-sync.git
cd ncaa-stats-sync
cp inst/config/example.yml config.yml
Rscript scripts/sync_ncaa_stats.R --config config.yml --mode incremental
```

## 3) Optional CRAN release

Once stable, submit to CRAN so users can:

```r
install.packages("ncaaStatsSync")
```

## Plugin/integration options

## A) GitHub Actions integration (included)
- Use `.github/workflows/sync-ncaa-stats.yml`.
- Runs daily and commits updated JSON snapshots.

## B) Data-pipeline plugin pattern
- Treat this package as a "stats source plugin" for downstream apps.
- Downstream systems read deterministic outputs:
  - `output/college-stats/pitching-YYYY.json`
  - `output/college-stats/batting-YYYY.json`
  - `output/college-stats/meta.json`

## C) Posit Connect / cron integration
- Wrap `Rscript scripts/sync_ncaa_stats.R ...` in scheduled jobs.

## Required setup before public launch

1. Update `DESCRIPTION` author/email.
2. Replace `<your-username>` placeholders in docs/workflow.
3. Add repo topics: `r`, `ncaa`, `baseball`, `sports-analytics`, `data-pipeline`.
4. Enable GitHub Actions write permissions for workflow commits.
5. Create first release tag `v0.1.0`.

## Suggested first release notes

- Shared-browser NCAA fetch strategy.
- Full and incremental sync modes.
- Retry and degraded-output protections.
- Deterministic JSON outputs for downstream web apps.
