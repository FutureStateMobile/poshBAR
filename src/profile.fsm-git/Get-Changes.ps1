<#
.SYNOPSIS
Gets changes from the remote server for the specified branch.

.DESCRIPTION
Gets changes from the remote server for the specified branch.

.EXAMPLE
Get-Changes

.PARAMETER branchName
The branch you wish to pull changes for
#>
Function Get-Changes ( [string] $branchName ) {
    if ($branchName.length -eq 0) {
        $branchName = Get-CurrentBranch
    }
    Invoke-ExternalTool { git pull origin $branchName } "Error getting changes from Git Server"
    Invoke-ExternalTool { git fetch origin $branchName } "Error fetching changes from Git Server"
}

Set-Alias pull Get-Changes