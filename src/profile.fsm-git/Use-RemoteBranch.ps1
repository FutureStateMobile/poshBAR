<#
.SYNOPSIS
This will checkout locally a branch on the remote server

.DESCRIPTION
This will checkout locally a branch on the remote server

.PARAMETER branchName
The specified branch to checkout

.EXAMPLE
Use-RemoteBranch mybranchname
#>
Function Use-RemoteBranch( [string] $branchName = $(throw "Please enter a branch name to use") ){
    Invoke-ExternalTool { git fetch } "Error fetching from Git Server"
    Invoke-ExternalTool { git checkout -b $branchName origin/$branchName } "Error checking out remote branch origin/$branchName locally"
}

Set-Alias urb Use-RemoteBranch