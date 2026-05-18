[DscResource()]
class AADSyncRuleCount
{
    <#
        .SYNOPSIS
            Verifies the number of Azure AD Connect synchronization rules.

        .DESCRIPTION
            Read-only / report-only DSC resource that compares the expected
            number of AAD Connect sync rules against the current state and
            reports a drift if they differ. The resource never attempts to
            remediate drift because creating or removing rules to match a
            count is not a meaningful operation; the user must investigate
            and reconcile manually.

            Use `ConnectorName` to scope the count to a specific connector.
            Leave `ConnectorName` empty (or set it to `*`) to count every
            sync rule across all connectors.
    #>

    # `ConnectorName` is the key. Empty string or '*' means "all connectors".
    [DscProperty(Key = $true)]
    [string]$ConnectorName

    [DscProperty(Mandatory = $true)]
    [uint32]$RuleCount

    [DscProperty(NotConfigurable)]
    [uint32]$CurrentRuleCount

    [bool]Test()
    {
        $currentState = $this.Get()
        $scope = $this.GetScopeDescription()

        if ($currentState.CurrentRuleCount -eq $this.RuleCount)
        {
            Write-Verbose -Message "AADSyncRuleCount: $scope has the expected $($this.RuleCount) sync rule(s)."
            $this.TryWriteEventLog('Information', 1100, "AADSyncRuleCount in desired state for $scope (count=$($this.RuleCount)).")
            return $true
        }

        Write-Verbose -Message "AADSyncRuleCount: $scope has $($currentState.CurrentRuleCount) sync rule(s) but expected $($this.RuleCount)."
        $this.TryWriteEventLog('Warning', 1101, "AADSyncRuleCount drift for $scope. Expected=$($this.RuleCount); Current=$($currentState.CurrentRuleCount).")
        return $false
    }

    [AADSyncRuleCount]Get()
    {
        $currentState = [AADSyncRuleCount]::new()
        $currentState.ConnectorName = $this.ConnectorName
        $currentState.RuleCount = $this.RuleCount

        $rules = if ([string]::IsNullOrEmpty($this.ConnectorName) -or $this.ConnectorName -eq '*')
        {
            Get-ADSyncRule
        }
        else
        {
            Get-ADSyncRule -ConnectorName $this.ConnectorName
        }

        # Get-ADSyncRule may return $null when no rules match; coerce to 0.
        $currentState.CurrentRuleCount = if ($null -eq $rules) { 0 } else { @($rules).Count }

        return $currentState
    }

    [void]Set()
    {
        # This resource is report-only. Adjusting the rule count automatically
        # is not safe and not meaningful — the operator must investigate which
        # rules are missing or extra. Throw a clear error so the LCM marks the
        # configuration as failed.

        $currentState = $this.Get()
        $scope = $this.GetScopeDescription()
        $message = "AADSyncRuleCount drift detected for $scope. Expected $($this.RuleCount) sync rule(s) but found $($currentState.CurrentRuleCount). This resource does not remediate count drift; investigate the AAD Connect configuration manually."

        $this.TryWriteEventLog('Error', 1102, $message)
        throw $message
    }

    hidden [string]GetScopeDescription()
    {
        if ([string]::IsNullOrEmpty($this.ConnectorName) -or $this.ConnectorName -eq '*')
        {
            return "all connectors"
        }

        return "connector '$($this.ConnectorName)'"
    }

    hidden [void]TryWriteEventLog([string]$EventType, [int]$EventId, [string]$Message)
    {
        try
        {
            Write-AADConnectEventLog -EventType $EventType -EventId $EventId -Message $Message -ConnectorName $this.ConnectorName
        }
        catch
        {
            Write-Verbose -Message "Failed to write event log entry: $($_.Exception.Message)"
        }
    }
}
