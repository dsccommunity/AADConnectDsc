# System Patterns: AADConnectDsc

_Last updated: 2026-05-18 (UTC). Procedural memory — architecture and reusable patterns._

## Architecture

Four-layer stack:

```text
External config (Datum / AADConnectConfig / Azure Automation)
        │
        ▼
AADConnectDsc module  ── Classes (DSC) + Public/Private functions
        │
        ▼
ADSync PowerShell module (Microsoft)
        │
        ▼
Azure AD Connect synchronization engine + DB
```

The module is a **wrapper-with-enhancement** layer over `ADSync`. It never
talks to the sync engine directly; everything goes through `Get-ADSyncRule`,
`Add-ADSyncRule`, etc. This bounds the blast radius of Microsoft API changes
to the Public functions and the two DSC classes.

## DSC Resources

### `AADSyncRule` (Classes/AADSyncRule.ps1)

- **Keys**: `Name`, `ConnectorName`.
- **Mandatory**: `TargetObjectType`, `SourceObjectType`, `Direction`, `LinkType`.
- **Complex props**: `ScopeFilter` (ScopeConditionGroup[]),
  `JoinFilter` (JoinConditionGroup[]), `AttributeFlowMappings` (AttributeFlowMapping[]).
- **NotConfigurable**: `Identifier`, `Version`.
- **Methods**: `Get()` reads via enhanced `Get-ADSyncRule`; `Test()` compares
  state via the YAML round-trip pattern below; `Set()` applies via
  `New-ADSyncRule` + `Add-ADSyncRule` (or `Set-ADSyncRule` for disable-toggle
  on standard rules).

### `AADConnectDirectoryExtensionAttribute` (Classes/...)

CRUD wrapper around schema extensions. Backed by the three
`*-AADConnectDirectoryExtensionAttribute` public functions.

## Reusable Patterns

### YAML round-trip in `Test()`

`Compare-DscParameterState` does not recurse into nested hashtables/objects.
Serialising current and desired state to YAML and parsing back produces a
uniform hashtable tree that compares correctly. This is why `powershell-yaml`
is a hard runtime dependency. **Do not remove.**

### Standard-rule differential comparison

```powershell
$param.ExcludeProperties = if ($this.IsStandardRule) {
    # Standard rules: only Name + Disabled are actionable
    ($this | Get-Member -MemberType Property).Name |
        Where-Object { $_ -notin 'Name', 'Disabled' }
} else {
    'Connector', 'Version', 'Identifier'
}

if ($this.IsStandardRule) {
    # Secondary pass: full compare, output-only, does not affect $compare
    $infoParam = $param.Clone()
    $infoParam.ExcludeProperties = 'Connector', 'Version', 'Identifier', 'Precedence'
    $null = Test-DscParameterState @infoParam -ReverseCheck
}
```

Result: standard rules never trigger spurious `Set()` calls, but operators
still see drift in verbose output.

### Whitespace normalisation

`Description` and every `AttributeFlowMapping.Expression` have all whitespace
stripped before comparison. Encoding/line-ending differences between
PowerShell, MOF, and the sync DB otherwise produce phantom drift.

### Connector-name resolution

Configurations reference connectors by **name**, not GUID. `Get-ADSyncRule`
exposes a `ByNameAndConnector` parameter set; `AADSyncRule` always uses it.
Benefits: portable across environments, human-readable, no GUID hunts.

### Precedence

Custom-rule precedence is assigned automatically. Standard-rule precedence is
read-only and excluded from comparison.

## Event Logging Pattern

Dedicated Windows event log named `AADConnectDsc`, source `AADConnectDsc`,
written by `Write-AADConnectEventLog` (Public function — must stay in
`source/Public/` so class methods can resolve it after module compilation).

| ID range | Kind        | Meaning |
|----------|-------------|---------|
| 1000     | Information | Rule in desired state |
| 1001     | Warning     | Rule absent, should be present |
| 1002     | Warning     | Rule present, should be absent |
| 1003     | Warning     | Configuration drift detected |
| 2000     | Information | Rule created |
| 2001     | Information | Rule updated |
| 2002     | Information | Standard rule disabled-state toggled |
| 2003     | Information | Rule removed |

Design rules:

- **Auto-register** log and source on first write.
- **Non-breaking**: permission failure logs a verbose warning and returns;
  it never throws into the DSC pipeline.
- **Always emit** verbose diagnostics ("Attempting…", "✅"/"❌") regardless
  of write success, for low-privilege troubleshooting.

## Error Handling Layers

1. **Parameter validation** at function entry (`[ValidateSet]`, types).
2. **Business validation** against ADSync constraints (e.g. connector exists)
   before calling `Set()`.
3. **ADSync wrapping**: every `Add-/Set-/Remove-ADSyncRule` call is wrapped
   in try/catch; failures are rethrown as DSC-meaningful errors.
4. **System errors** caught at the class boundary and logged via event log
   (where possible) before propagating.

## Testing Patterns

- **QA suite** (`tests/QA/module.tests.ps1`) — manifest, help, script
  analyzer. This is the only test layer that runs today.
- **Unit tests for classes**: not yet implemented. Pattern when added: mock
  `Get-ADSyncRule` / `Add-ADSyncRule`, drive each class method
  (Get/Test/Set) independently, assert state transitions and event-log
  side effects.
- **Integration tests**: require a real Azure AD Connect installation; run
  manually on a lab VM, not in CI.
