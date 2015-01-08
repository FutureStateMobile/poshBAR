<#
.SYNOPSIS
Starts a feature branch based on the story that you are working on.

.DESCRIPTION
This will configure a feature branch for you so you can have a personal build on the teamcity server and not break the trunk until you are finished.

.EXAMPLE
Start-Feature "3.1.17"

.PARAMETER issueNumber
This is the issue number for the story or task you are working on.
#>
Function Start-Feature( [string] $featureNumber = $(throw "A feature number is required") ) {
    $branchName = Get-CurrentBranch
    
    if ($branchName -ne $WORKINGBRANCH)
    {
        throw "You must start a feature branch from the $WORKINGBRANCH branch."
    }

    $branchName = "feature/$featureNumber"
    
    if ($branchName -notmatch $FEATUREREGEX)
    {
        throw "The feature number must match the format 1.1.1(.1)"
    }

    Invoke-ExternalTool { git checkout -b $branchName } "Error creating branch $branchName"
}

Set-Alias sf Start-Feature