<#
.SYNOPSIS
This will delete the branch you specify

.DESCRIPTION
This will delete the you specify

.PARAMETER branchName
Will delete the specified branch.

.PARAMETER deleteOnServer
If this switch is specified it will delete the branch on the server as well as locally.

.EXAMPLE
Remove-Branch MyBranchName

.EXAMPLE
Remove-Branch MyBranchName -deleteOnServer
#>
Function Remove-Branch ([string] $branchName, [switch] $deleteOnServer) {
    if ($branchName.length -eq 0){
        $branchName = Get-CurrentBranch
    }

    if ($branchName.compareTo($WORKINGBRANCH) -eq 0){
        throw "You cannot delete the $WORKINGBRANCH branch!"
    } else {
        Invoke-ExternalTool { git checkout $WORKINGBRANCH } "Error checking out $WORKINGBRANCH"
        Invoke-ExternalTool { git branch -D $branchName } "Error deleting branch $branchName"

        if ($deleteOnServer.isPresent) {
            Invoke-ExternalTool { git push origin --delete $branchName } "Error deleting branch on Git Server"
        }

        Invoke-ExternalTool { git fetch -p } "Error fetching changes from Git Server"
    }
}

Set-Alias db Remove-Branch
Set-Alias rb Remove-Branch
