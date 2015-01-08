<#
.SYNOPSIS
Pushes local changes for a specified branch to the remote server

.DESCRIPTION
Pushes local changes for a specified branch to the remote server

.EXAMPLE
Push-Changes

.PARAMETER branchName
The branch you wish to push changes for
#>
Function Push-Changes( [string] $branchName ) {
    if ($branchName.length -eq 0) {
        $branchName = Get-CurrentBranch
    }
    #Get-Changes $branchName
    Invoke-ExternalTool { git push origin $branchName } "Error pushing changes to Git Server"
}

Set-Alias push Push-Changes