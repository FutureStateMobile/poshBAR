<#
.SYNOPSIS
Gets the current branch the user is sitting on.

.DESCRIPTION
Gets the current branch the user is sitting on.

.EXAMPLE
Get-CurrentBranch
#>
Function Get-CurrentBranch {
    $status = Get-GitStatus
    return $status.Branch
}