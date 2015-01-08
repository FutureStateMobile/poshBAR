<#
.SYNOPSIS
Will commit your changes to your current branch and tag the commit with the issue number you are working on.

.DESCRIPTION
Will commit your changes to your current branch and tag the commit with the issue number you are working on.

.EXAMPLE
Save-Changes "This is my commit message"

.PARAMETER message
This is the commit message.

.PARAMETER initials
This is a non required field indicating the initials of who worked on this commit

.PARAMETER push
This is a switch when specified pushes the changes up to the Git server
#>
Function Save-Changes() {
    param (
        [string] $message = $(throw "A commit message is required"),
        [string] $initials,
        [switch] $push
    )
    
    $branchName = Get-CurrentBranch
        
    if ($branchName -match $FEATUREREGEX)
    {
        $issueNumber = $matches[2].ToString()
        $message = "(Story $issueNumber) $message"
    }

    if ($initials.length -gt 0) {
        $message = "[$initials] $message"
    }

    Invoke-ExternalTool { git add -A } "Error staging changes for commit."
    Invoke-ExternalTool { git commit -am $message } "Error commiting changes to Git."
    
    if ($push.isPresent) {
        Push-Changes $branchName
    }
}

Set-Alias save Save-Changes