<#
    .DESCRIPTION
        Returns the current Git branch and sha1 short identifier.  
	If no executable is given, then it will assume the git executable 
	exists in the path

    .EXAMPLE
        Get-CurrentGitBranchAndSha1  
        Returns:  'master: d9213455'
            
    .PARAMETER gitExe
        Optional location of the Git executable 

    .SYNOPSIS
        This is info can be added into the assembly to link the source with a release

    .NOTES
#>
function Get-CurrentGitBranchAndSha1{ 
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$false,position=0)] [string] $gitExe
    )
    
    if (!$gitExe){
        $gitExe = 'git'
    }

    $gitBranch = exec {Invoke-Expression "$gitExe status -b"} ($msgs.error_failed_execution -f "git status")
    $gitBranch = $gitBranch[0].split()[-1]
    $gitBranch = $gitBranch.TrimEnd([Environment]::NewLine)

    $lastSha1 = exec {Invoke-Expression "$gitExe rev-parse --verify --short HEAD"} ($msgs.error_failed_execution -f "git rev-parse")
    $lastSha1 = $lastSha1.TrimEnd([Environment]::NewLine)
    "$($gitBranch): $lastSha1"
}

