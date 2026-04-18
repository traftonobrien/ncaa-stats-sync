# ncaaStatsSync 0.2.0

## Added

- Production-aligned HTML parsing and player row extraction (`extract_pitching_rows`, `extract_batting_rows`) with derived metrics (FIP, xFIP, wRC+, etc.) matching Pitch Tracker logic.
- **Team stat engine**: `teams-YYYY.json` with roster-wide team totals plus qualified-team slices (`min_ip` / `min_pa` thresholds, default 5 IP / 15 PA).
- `schema_version` field in sync metadata.
- Unit tests for team aggregation (`testthat`).
- GitHub Actions workflow to run `devtools::test()` on push/PR.
