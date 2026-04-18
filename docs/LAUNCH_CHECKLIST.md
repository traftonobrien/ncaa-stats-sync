# Launch Checklist

## 1) Package hardening

- [ ] Move `tools/ncaa-stats-sync` into a dedicated public repository.
- [ ] Replace placeholder email in `DESCRIPTION`.
- [ ] Add unit tests (`testthat`) for fetch parsing and normalization.
- [ ] Add `R CMD check` workflow.
- [ ] Confirm license and README badges.

## 2) User-facing defaults

- [ ] Choose default `years` (single season or rolling window).
- [ ] Confirm default `division` (D3 for v1).
- [ ] Finalize output schema version and backward compatibility policy.
- [ ] Add `NEWS.md` and semantic versioning policy.

## 3) GitHub automation

- [ ] Copy `inst/workflows/sync-ncaa-stats.yml` into `.github/workflows/`.
- [ ] Enable Actions permissions to write contents.
- [ ] Run one manual `workflow_dispatch` dry run.
- [ ] Validate updated JSON files commit and push correctly.

## 4) Distribution

- [ ] Publish GitHub release `v0.1.0`.
- [ ] Add installation instructions (`remotes::install_github`).
- [ ] Optional: prepare CRAN submission (`devtools::check()`, `rhub::check_for_cran()`).

## 5) Operations

- [ ] Define stale-data policy (when to keep previous file).
- [ ] Define access-denied retry policy and max tolerated failures.
- [ ] Add issue templates for parse regressions and schema breakages.
