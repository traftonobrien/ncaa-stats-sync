## Summary

## Test plan

- [ ] `devtools::test()`
- [ ] `Rscript scripts/sync_ncaa_stats.R --config inst/config/example.yml --team-name Babson --limit 1` (smoke)

## Checklist

- [ ] `NEWS.md` updated for user-visible changes
- [ ] Player JSON remains a **flat array** (`pitching-YYYY.json`, `batting-YYYY.json`) for downstream compatibility
