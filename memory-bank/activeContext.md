# Active Context: AADConnectDsc

_Last updated: 2026-05-18 (UTC). Owner: software-engineer agent._

## Current Focus

No active feature work. Repository is on eature/RuleCountResource but the
branch is identical to `main` (HEAD `9033220`); the name appears to be a
placeholder for a future `AADSyncRuleCount` / rule-inventory resource that
has not been started.

Most recent shipped change (PR #30, May 2026): refreshed `build.ps1`,
`Resolve-Dependency.ps1` and `RequiredModules.psd1` to current Sampler
conventions. Captured in `CHANGELOG.md` under `[Unreleased]`.

## Open Decisions

- **RuleCountResource scope** — undecided. Likely a read-only/inventory DSC
  resource or a public function returning sync-rule counts per connector. No
  spec drafted; do not implement speculatively.
- **Next release cut** — `[Unreleased]` only contains a build-system refresh.
  Decide whether to ship as `0.5.1` (patch) or fold into the next feature
  release. Default: patch, since user-visible surface is unchanged.

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
