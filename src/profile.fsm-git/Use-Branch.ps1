<#
.SYNOPSIS
This will switch your local branch to the specified branch

.DESCRIPTION
This will switch your local branch to the specified branch

.PARAMETER branchName
The specified branch to checkout

.EXAMPLE
Use-Branch mybranchname
#>
Function Use-Branch( [string] $branchName = $(throw "Please enter a branch name to use") ){
    Invoke-ExternalTool { git checkout $branchName } "Error checking out $branchName"
}

Set-Alias ub Use-Branch
Set-Alias co Use-Branch