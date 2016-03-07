<#
    .DESCRIPTION
        Tests if this powershell responds to verbose messages

    .EXAMPLE
        Test-Verbose

    .SYNOPSIS
        Tests if this powershell has been called with '-Verbose'.  
        This will detect the Verbose setting even if iherits from its parent scope.
#>

function Test-Verbose{
    [CmdletBinding()]
    param()

    [System.Management.Automation.ActionPreference]::SilentlyContinue -ne $VerbosePreference
}
