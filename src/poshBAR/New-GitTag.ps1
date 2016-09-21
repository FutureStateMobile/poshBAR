<#
    .DESCRIPTION
        Creates and pushes a new Git annotated tag in the current repository.  
        If no Git executable is provided, then it assumes the git executable exists
        in the path.  It fails if the currrent repository has local changes or 
        is not in sync with the remote repostory.

    .EXAMPLE 
        New-GitTag "v1.0.0.6" 

    .EXAMPLE 
        New-GitTag "v1.10"  -$PreviousCommitChecksum "f6aa182"
        This will tag a previous commit.

    .PARAMETER TagName 
        Name of the tag 

    .PARAMETER Branch
        Branch of the git repository to tag with.  Defaults to master.

    .PARAMETER PreviousCommitChecksum
        Include the ability to tag a prevous commit.  This can be the shortened
        form of the commit sha1 checksum.

    .PARAMETER GitExe
        Path of the Git executable.  This defaults to 'git" and assumes it is in 
        the environment path.
#>
function New-GitTag {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)][string]  $TagName,
        [parameter(Mandatory=$false,position=1)][string] $Branch = "master",
        [parameter(Mandatory=$false,position=2)][string] $PreviousCommitChecksum,
        [parameter(Mandatory=$false,position=3)][string] $gitExe = "git"
    )

    # all committed?
    $gitOutput = exec {Invoke-Expression "$gitExe status -s"} ($msgs.error_failed_execution -f "git status")
    if ($gitOutput) {
        throw "You have uncommitted local changes.  Commit and push to remote"
    }

    # In sync with remote?
    exec {Invoke-Expression "$gitExe fetch"} ($msgs.error_failed_execution -f "git fetch")
    $gitOutput = exec {Invoke-Expression "$gitExe log HEAD..origin/$Branch"} ($msgs.error_failed_execution -f "git log HEAD..origin/$Branch")
    if ($gitOutput) {
        throw "Your local repository is out of sync with the remote.  Rebase and try again"
    }

    $gitOutput = exec {Invoke-Expression "$gitExe log '@{u}..' --oneline"} ($msgs.error_failed_execution -f "git log '@{u}..'")
    if ($gitOutput) {
        throw "Your local repository has commits that have not been pushed to the remote.  Push these and try again"
    }

    # Create and push new tag
    $commitMessage = "Tagged $TagName on $Branch"
    exec {Invoke-Expression "$gitExe tag -a $TagName -m '$commitMessage' $PreviousCommitChecksum"} ($msgs.error_failed_execution -f "git tag -a $TagName")
    exec {Invoke-Expression "$gitExe push origin --tags" } ($msgs.error_failed_execution -f "git push origin --tags")

    Write-Host "Tagged $TagName on $Branch $PreviousCommitChecksum"
}
