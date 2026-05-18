# Progress: AADConnectDsc

_Last updated: 2026-05-18 (UTC). Episodic memory — current state + recent
shipped work. Older milestones are summarised; full detail lives in
``CHANGELOG.md`` and Git history._

## Current State

- **Released**: ``0.5.0`` (2025-10-17) — published to PowerShell Gallery via
  the standard Sampler/Azure Pipelines flow.
- **In ``[Unreleased]``**: Build-system refresh only (``build.ps1``,
  ``Resolve-Dependency.ps1``, ``RequiredModules.psd1`` aligned to current
  Sampler). No user-visible behaviour change.
- **Branch**: ``feature/RuleCountResource`` exists but contains zero commits
  beyond ``main``. Treat as a name reservation, not work-in-progress.
- **Open work**: none active. Remaining doc-quality items (markdown lint,
  link validation) are tracked below.

## Remaining Tasks

1. **Markdown lint sweep** across ``docs/`` — minor formatting drift.
2. **Link validation** for internal/external links in ``README.md`` and
   ``docs/``.
3. **Decide RuleCountResource scope** before any code lands on the
   feature branch.

## Recent Releases (newest first)

| Version | Date       | Headline |
|---------|------------|----------|
| 0.5.0   | 2025-10-17 | Added ``Sync-Parameter`` (removes ``AutomatedLab.Common`` dependency); added ``powershell-yaml`` to ``RequiredModules``. |
| 0.4.0   | 2025-10-16 | Standard-rule comparison excludes all properties except ``Name`` / ``Disabled``; ``Write-AADConnectEventLog`` shipped with permission-aware diagnostics and event IDs 1000–1003 / 2000–2003. |
| 0.3.2   | 2025-07-22 | ``AADSyncRule::Test()`` round-trips state via YAML so ``Compare-DscParameterState`` sees full hierarchy; ``Precedence`` excluded for standard rules. |
| 0.3.1   | 2024-10-17 | ``Get-ADSyncRule`` now honours connector; added ``ByNameAndConnector`` parameter set; ``ConnectorName`` is a DSC key on ``AADSyncRule``. |
| 0.3.0   | 2024-08-07 | Null-handling for ``Expression`` / ``Source`` keys; error handling for missing standard rules; pinned GitVersion to 5.*. |
| 0.2.x   | 2024-06–07 | Initial public releases; ``AttributeFlowMapping.Expression`` made a key. |

## Capability Summary (what ships today)

- **DSC resources**: ``AADSyncRule``, ``AADConnectDirectoryExtensionAttribute``.
- **Public functions**: ``Get-ADSyncRule``, ``Add/Get/Remove-AADConnectDirectoryExtensionAttribute``,
  ``Convert-ObjectToHashtable``, ``Write-AADConnectEventLog``.
- **Private helpers**: ``New-Guid2``, ``Sync-Parameter``.
- **Event logging**: dedicated ``AADConnectDsc`` log, compliance IDs
  1000–1003, operational IDs 2000–2003, non-breaking on permission failure.
- **Docs**: ``README.md`` plus ``docs/{Architecture,BestPractices,Migration,Functions,Troubleshooting,EventLoggingGuide,EventLogExamples,AADSyncRule,AADConnectDirectoryExtensionAttribute}.md``.

## Historical Milestones (condensed)

- **Documentation overhaul (Aug–Oct 2025)**: Phases 1–3 completed —
  foundation docs, full resource reference, architecture / best-practices /
  migration / troubleshooting guides, example library, README hub.
  Phase 4 (lint + link validation) is the only outstanding item.
- **Event logging feature (Aug 2025, shipped in 0.4.0)**: function moved
  from ``Private/`` to ``Public/`` so DSC classes can call it; added
  permission-aware error messages, verbose diagnostics, and the event-ID
  schema. Integrated with ``AADSyncRule.Test()`` so every evaluation emits
  either a compliance (1000) or drift (1001–1003) event.
- **Standard-rule handling (Jul 2025, shipped in 0.4.0)**: ``Test()`` now
  compares only ``Name`` and ``Disabled`` for standard rules; secondary
  full-property comparison runs for informational logging only.
- **State-comparison rewrite (Jul 2025, shipped in 0.3.2)**: ``Test()``
  serialises current/desired state to YAML and back so
  ``Compare-DscParameterState`` traverses the full hierarchy of hashtables.
- **Dependency cleanup (Oct 2025, shipped in 0.5.0)**: replaced
  ``AutomatedLab.Common`` use with the internal ``Sync-Parameter``
  function; added ``powershell-yaml`` as a first-class dependency.
