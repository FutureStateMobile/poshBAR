<#
.SYNOPSIS
This will merge the specified branch with the current branch

.DESCRIPTION
This will merge the specified branch with the current branch

.PARAMETER branchName
The branch you wish to merge into the current branch

.EXAMPLE
Merge-BranchWith master
#>
Function Merge-FromBranch( [string] $branchName = $(throw "Please enter a branch to merge the current branch with") )
{
    $currentBranch = Get-CurrentBranch

    Invoke-ExternalTool { git checkout $branchName } "Error checking out $branchName"
    Get-Changes
    Invoke-ExternalTool { git checkout $currentBranch } "Error checking out $currentBranch"

    if ($currentBranch -ne $WORKINGBRANCH){
        Invoke-ExternalTool { git merge $branchName } "Error merging $currentBranch to $branchName"
    } else {
        Invoke-ExternalTool { git merge $branchName --no-ff } "Error merging $currentBranch to $branchName"
    }
}

Set-Alias mfb Merge-FromBranch