# Technical Context: AADConnectDsc

_Last updated: 2026-05-18 (UTC). Semantic memory — stack, layout, constraints._

## Stack

- **PowerShell 5.1+** (class-based DSC; PowerShell 7.x supported for build/test).
- **PowerShell DSC** (class-based resources, `PSDesiredStateConfiguration`).
- **ADSync** module from Azure AD Connect (runtime dependency on target nodes).
- **Sampler** build framework (`build.yaml`, `build.ps1`, `Resolve-Dependency.ps1`,
  `RequiredModules.psd1`). The build pipeline was refreshed in May 2026 (PR #30)
  to align with the current Sampler templates.

## Runtime Dependencies

| Module             | Why |
|--------------------|-----|
| `ADSync`           | Native Azure AD Connect cmdlets, ships with AAD Connect. |
| `powershell-yaml`  | `AADSyncRule::Test()` serialises state to YAML for full-depth comparison via `Compare-DscParameterState`. Added in 0.5.0. |
| `DscResource.Common` | `Compare-DscParameterState`, common helpers. Pinned >= 0.24.0. |

## Build / Test Dependencies (RequiredModules)

`InvokeBuild`, `ModuleBuilder`, `Pester` (v5), `PSScriptAnalyzer`,
`DscResource.Test`, `DscResource.AnalyzerRules`, `DscResource.DocGenerator`,
`ChangelogManagement`, `MarkdownLinkCheck`, `Sampler`, `Sampler.GitHubTasks`,
`xDSCResourceDesigner`, `Plaster`, `PSDepend`, `PowerShellGet`,
`Microsoft.PowerShell.PSResourceGet`. Resolved to `output/RequiredModules/`.

## Source Layout

```text
source/
├── AADConnectDsc.psd1 / .psm1 / Init.psm1 / Prefix.ps1
├── Classes/
│   ├── AADSyncRule.ps1                          # main DSC resource
│   ├── AADConnectDirectoryExtensionAttribute.ps1
│   ├── AttributeFlowMapping.ps1
│   ├── JoinCondition.ps1 / JoinConditionGroup.ps1
│   └── ScopeCondition.ps1 / ScopeConditionGroup.ps1
├── Public/
│   ├── Get-ADSyncRule.ps1
│   ├── Add-AADConnectDirectoryExtensionAttribute.ps1
│   ├── Get-AADConnectDirectoryExtensionAttribute.ps1
│   ├── Remove-AADConnectDirectoryExtensionAttribute.ps1
│   ├── Convert-ObjectToHashtable.ps1
│   └── Write-AADConnectEventLog.ps1             # MUST stay in Public/ so classes can call it
├── Private/
│   ├── New-Guid2.ps1
│   └── Sync-Parameter.ps1                       # replaces AutomatedLab.Common dep (0.5.0)
├── Enum/
│   ├── Ensure.ps1
│   ├── AttributeMappingFlowType.ps1
│   ├── AttributeValueMergeType.ps1
│   └── ComparisonOperator.ps1
├── Examples/Resources/...
└── en-US/about_AADSyncDsc.help.txt
```

Tests live in `tests/QA/module.tests.ps1` (QA suite only — no unit tests yet).

## Build Commands

- `./build.ps1 -ResolveDependency -Tasks build` — install deps + build module.
- `./build.ps1 -AutoRestore -Tasks test` — run Pester (also exposed as the
  VS Code `test` task).
- `./build.ps1 -Tasks build` — incremental build once dependencies resolved.

Output: `output/module/AADConnectDsc/<version>/`. Test results:
`output/testResults/`. Current built version on disk: **0.5.1-fix0001**.

## Constraints

- **Target OS**: Windows Server with Azure AD Connect installed. The ADSync
  module is not available elsewhere.
- **Event log writes** require local Administrator on first write to register
  the source. `Write-AADConnectEventLog` degrades gracefully (verbose warning,
  no exception) when permissions are missing.
- **Standard sync rules** are immutable on the wire; only `Name` and
  `Disabled` are part of DSC compliance. All other properties are excluded
  from the primary `Test()` comparison.
- **YAML round-trip in `Test()`** is intentional — without it,
  `Compare-DscParameterState` flattens nested hashtables and produces false
  positives. Do not "optimise" it away.

## Pipeline

Azure Pipelines (`azure-pipelines.yml`) driven by Sampler. GitVersion 5.x
(pinned). Publishes to PowerShell Gallery on tagged release.
