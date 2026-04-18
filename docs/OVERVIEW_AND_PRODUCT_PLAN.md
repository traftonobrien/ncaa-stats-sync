# NCAA Sync Skill Overview and Product Plan

## Current skill strengths (from Pitch Tracker)

1. **Operationally mature fetch loop**
   - Shared Chromote browser session.
   - Retry + backoff on access-denied and transient parse failures.
   - Supports both full and incremental sync modes.

2. **Production-safe publish behavior**
   - Degraded-leg strategy: keep prior JSON on partial failure.
   - Structured `meta.json` with per-type outcomes and failures.
   - Nightly GitHub Actions automation with manual trigger support.

3. **Data contract already consumed by app**
   - `pitching-<year>.json`, `batting-<year>.json`, `meta.json`.
   - Cached artifact model avoids runtime scraping in web requests.

## What needs to change to become a free package

1. **Decouple from repo-specific assumptions**
   - No hardcoded `web/public/college-stats`.
   - No Pitch Tracker-specific validation rules beyond configurable defaults.

2. **Formalize package API**
   - Exported functions (`ncaa_sync_daily`, `ncaa_sync_type`, config helpers).
   - CLI wrapper for non-R users and GitHub Actions.

3. **Add package quality gates**
   - Test coverage, static checks, reproducible fixtures, release notes.

4. **Document scope clearly**
   - v0.1 target: Division III only, season-to-date stats pages.
   - Future versions: multi-division, alternate providers, schema adapters.

## Proposed public package strategy

## Phase 1 (this scaffold)
- Package skeleton, config, CLI, workflow template, launch docs.

## Phase 2 (stability)
- Add `testthat` suite with fixture HTML snapshots.
- Add parser contract tests for NCAA table shape drift.
- Add output schema version field in `meta.json`.

## Phase 3 (adoption)
- Publish GitHub releases with changelog.
- Add optional output adapters (CSV, Parquet).
- Add watch-list presets for conferences.

## Phase 4 (ecosystem)
- Add a companion Python wrapper for non-R pipelines.
- Add a tiny docs site with setup guides.
- Add optional cloud storage publishing (S3/R2/GCS).

## Recommended repository structure (public)

```
ncaa-stats-sync/
  R/
  scripts/
  inst/config/
  inst/workflows/
  tests/testthat/
  docs/
  README.md
  DESCRIPTION
  NAMESPACE
```

## Success criteria for v0.1

- One-command local run writes all three output files.
- Scheduled GitHub workflow runs daily with deterministic commits.
- Parsing failure in one type does not destroy last known good file.
- New user can install + run in under 15 minutes.
