# Changelog for AADConnectDsc

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- New DSC resource `AADSyncRuleCount` that verifies the number of
  Azure AD Connect synchronization rules against an expected value.
  The resource is report-only: it never attempts to remediate count
  drift and instead throws a descriptive error so the LCM marks the
  configuration as failed. Scope is per-connector via `ConnectorName`,
  or across all connectors when `ConnectorName` is empty or `*`.

### Changed

- Updated module dependencies in `RequiredModules.psd1`.
- Updated build scripts (`build.ps1`, `Resolve-Dependency.ps1`) to align
  with the latest version of Sampler.

## [0.5.0] - 2025-10-17

### Changed

- Added `powershell-yaml` to the `RequiredModules` in the module's psd1 file.
- Add Sync-Parameter function for command parameter handling and conversion
  to remove dependency on AutomatedLab.Common.

## [0.4.0] - 2025-10-16

### Fixes

- Update AADSyncRule class to exclude all properties when comparing states for
  standard rules except `Name` and `Disabled`. This is because standard rules
  cannot be changed. A second compare job is executed for reporting on
  differences but without having an effect on the overall test result.
- Fixed of `DscResource.Common`, now `0.24.0-preview0002`.
- Formatting throughout the project.

### Changed

- AADSyncRule
  - Verbose output us suppressed when comparing all properties for standard rules.

## [0.3.2] - 2025-07-22

### Changed

- The `ADSyncRule::Test()` method converts the current and desired state to
  Yaml and back from yaml. This is to have a hierarchy of hashtables. If
  not doing the convertion, the function `Compare-DscParameterState` in
  module `DscResource.Common` cannot compare the information in full depth.
- Excluding property `Precedence` from comparison for standard rules.
- Added more verbose output.

### Fixes

- Remove all whitespace from `Description` otherwise this property may will not
  match due to encoding differences.
- Fixed multiple bugs in 'ADSyncRole::Test()' and 'ADSyncRole::Set()'.  
- `ADSyncRule::Test()` works after changing the states to yaml and back.

### Added

- Verbose output in 'ADSyncRule'.

## [0.3.1] - 2024-10-17

### Fixed

- Fixed multiple bugs in the ADSyncRule class effected the comparing of objects.
- Fixed dealing with standard rules.
- Remove all whitespace from expressions in AttributeFlowMappings, otherwise they
  may not match due to encoding differences.
- Added parameter set 'ByNameAndConnector' to 'Get-ADSyncRule'.
- Added parameter 'ConnectorName' as key in DSC Resource 'AADSyncRule.
- DSC Resource 'AADSyncRule' uses parameter set 'ByNameAndConnector' when
  calling 'Get-ADSyncRule'.

## [0.3.0] - 2024-08-07

### Fixed

- Add check for empty 'Expression' as it is a key and does not allow $null.
- Add check for empty 'Source' as it is a key and does not allow $null.
- Added error handling for non-existing standard rule.
- Set version of GitVersion to 5.*.

## [0.2.2] - 2024-07-05

### Changed

- AttributeFlowMapping:
  - Expression a key property again, otherwise complex rule sets
    are resulting in conflicts.

## [0.2.1] - 2024-07-04

### Changed

- AttributeFlowMapping:
  - Expression is no longer key

### Fixed

- Aligned build task.

## [0.2.0] - 2024-06-10

### Added

Initial Release
