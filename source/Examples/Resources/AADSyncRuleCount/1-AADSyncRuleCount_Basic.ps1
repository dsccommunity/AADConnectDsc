<#
.EXAMPLE 1

Verifies that the 'contoso.com' connector has exactly 42 sync rules.
If the actual count differs, the resource throws an error during Set
and the LCM marks the configuration as failed. The resource never
attempts to add or remove rules to reach the expected count.
#>

configuration Example_AADSyncRuleCount_Basic
{
    Import-DscResource -ModuleName AADConnectDsc

    node localhost
    {
        AADSyncRuleCount 'ContosoRuleCount'
        {
            ConnectorName = 'contoso.com'
            RuleCount     = 42
        }

        # Verify the total number of rules across all connectors.
        AADSyncRuleCount 'TotalRuleCount'
        {
            ConnectorName = '*'
            RuleCount     = 168
        }
    }
}
