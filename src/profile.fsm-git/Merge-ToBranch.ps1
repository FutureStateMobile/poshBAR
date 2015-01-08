<#
.SYNOPSIS
This will merge the current branch with the specified branch

.DESCRIPTION
This will merge the current branch with the specified branch

.PARAMETER branchName
The branch you wish to merge the current branch with

.EXAMPLE
Merge-BranchWith master
#>
Function Merge-ToBranch( [string] $branchName = $(throw "Please enter a branch to merge the current branch with") )
{
    $currentBranch = Get-CurrentBranch

    Invoke-ExternalTool { git checkout $branchName } "Error checking out $branchName"

    if ($branchName -ne $WORKINGBRANCH){
        Invoke-ExternalTool { git merge $currentBranch } "Error merging $currentBranch to $branchName"
    } else {
        Invoke-ExternalTool { git merge $currentBranch --no-ff } "Error merging $currentBranch to $branchName"
    }

    Push-Changes
    Invoke-ExternalTool { git checkout $currentBranch } "Error checking out $currentBranch"
}

Set-Alias mtb Merge-ToBranch