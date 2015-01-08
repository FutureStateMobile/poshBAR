<#
.SYNOPSIS
This completes the branch you are working on and merges the changes back into the develop branch.

.DESCRIPTION
This completes the branch you are working on and merges the changes back into the develop branch.

.PARAMETER deleteOnServer
If this switch is specified it will delete the Feature branch on the server as well as locally once the merge is complete.

.EXAMPLE
Complete-Feature
#>
Function Complete-Feature ( [switch] $deleteOnServer ) {
    $status = Get-GitStatus
    $branchName = Get-CurrentBranch

    if ($branchName -match $FEATUREREGEX) {

        if ($status.BehindBy -gt 0 -or $status.AheadBy -gt 0 -or $status.HasUntracked -or $status.HasIndex -or $status.HasWorking) {
            throw "You must commit all changes to the server before completing the story"
        } else {
            Invoke-ExternalTool { git checkout $WORKINGBRANCH } "Error checking out $WORKINGBRANCH"
            Get-Changes
            Invoke-ExternalTool { git merge $branchName --no-ff } "Error merging $branchName to $WORKINGBRANCH"
            
            if ($LastExitCode -eq 0){
                if ($deleteOnServer.isPresent) {
                    Remove-Branch $branchName -deleteOnServer
                }
                else {
                    Remove-Branch $branchName
                }
            }
        }
    } else {
        throw "You must be on a feature branch in order to complete the feature."
    }
}

Set-Alias cf Complete-Feature