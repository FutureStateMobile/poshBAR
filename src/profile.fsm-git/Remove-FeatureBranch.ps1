<#
.SYNOPSIS
This will delete the feature branch you are on, or the feature branch you specify

.DESCRIPTION
This will delete the feature branch you are on, or the feature branch you specify

.PARAMETER issueNumber
If specified, will delete the feature branch associated with this story.  If not specified it will delete the checked out feature branch

.PARAMETER deleteOnServer
If this switch is specified it will delete the Feature branch on the server as well as locally.

.EXAMPLE
Remove-FeatureBranch

.EXAMPLE
Remove-FeatureBranch 3.1.1

.EXAMPLE
Remove-FeatureBranch 3.1.1 -deleteOnServer

#>
Function Remove-FeatureBranch ( [string] $issueNumber = "", [switch] $deleteOnServer ) {
    
    if ($issueNumber.length -eq 0) {
        $branchName = Get-CurrentBranch
        
        if ($branchName -notmatch $FEATUREREGEX)
        {
            throw "Either specify an issue number, or checkout the feature branch you wish to delete"
        }
    }
    else {
        $branchName = "feature/$issueNumber"
    }

    if ($deleteOnServer.isPresent) {
        fb $branchName -deleteOnServer
    }

    rb $branch
}

Set-Alias dfb Remove-FeatureBranch
Set-Alias rfb Remove-FeatureBranch