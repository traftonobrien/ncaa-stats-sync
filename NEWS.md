# ncaaStatsSync 0.3.0

## Added

- Full player enrichment pass now runs across the combined season dataset (not per-team), so league-relative metrics are internally consistent.
- Expanded derived metrics from base columns:
  - Pitching: `k9`, `bb9`, `h9`, `hr9`, `go_fo_ratio`, `gb_pct`, `fb_pct`, `hr_fb_pct`, `so_bb`, `babip`, `lob_pct`.
  - Batting: `singles`, `xbh`, `iso`, `babip`, `bb_k_ratio`, `sb_pct`.
- Conference context for players and teams:
  - `conference_mean_*`, `conference_sd_*`, `conference_delta_*`.
  - `overall_percentile_*` and `conference_percentile_*`.
- Sync metadata now includes `player_count`, `row_team_count`, and `conference_count` per stat type.
- Added regression tests for contextual benchmarks and percentile columns.

# ncaaStatsSync 0.2.0

## Added

- Production-aligned HTML parsing and player row extraction (`extract_pitching_rows`, `extract_batting_rows`) with derived metrics (FIP, xFIP, wRC+, etc.) matching Pitch Tracker logic.
- **Team stat engine**: `teams-YYYY.json` with roster-wide team totals plus qualified-team slices (`min_ip` / `min_pa` thresholds, default 5 IP / 15 PA).
- `schema_version` field in sync metadata.
- Unit tests for team aggregation (`testthat`).
- GitHub Actions workflow to run `devtools::test()` on push/PR.
