# Active Context: AADConnectDsc

_Last updated: 2026-05-18 (UTC). Owner: software-engineer agent._

## Current Focus

Shipped `AADSyncRuleCount` DSC resource on branch
`ai/aadsyncrulecount-resource` (replaces the reserved
`feature/RuleCountResource` placeholder). Report-only resource: compares
expected vs. actual sync-rule count per connector (or across all
connectors when `ConnectorName` is empty/`*`), throws from `Set()` on
drift, never remediates. New event IDs 1100/1101/1102.

Most recent shipped change (PR #30, May 2026): refreshed `build.ps1`,
`Resolve-Dependency.ps1` and `RequiredModules.psd1` to current Sampler
conventions.

## Open Decisions

- **Unit tests for AADSyncRuleCount** — not yet written. ADSync cmdlets
  cannot run on a build agent, so tests must mock `Get-ADSyncRule`. Mirror
  the pattern used by existing class tests (none exist yet under `tests/`
  for the resource classes, only `tests/QA/module.tests.ps1`).
- **Next release cut** — `[Unreleased]` now contains the new resource
  plus the earlier build-system refresh; bump to `0.6.0` (minor) for the
  new public surface.

## Next Steps (when work resumes)

1. Confirm intent of `feature/RuleCountResource` with the maintainer before
   writing any code.
2. Validate the refreshed build works end-to-end: `./build.ps1 -ResolveDependency -Tasks build,test`.
3. Address the remaining Phase 4 doc tasks tracked in `progress.md`
   (markdown lint, link validation).

## Recent Memory-Bank Maintenance

- 2026-05-18: Rewrote the memory bank to match the current agent spec
  (lean working/episodic files, added `promptHistory.md`). Older
  phase-by-phase narratives moved into condensed summaries in
  `progress.md`.
