<#
.SYNOPSIS
This will list all the branches on the remote server.

.DESCRIPTION
This will list all the branches on the remote server.

.EXAMPLE
Show-RemoteTags
#>
Function Show-RemoteBranches(){
    Invoke-ExternalTool { git fetch } "Error fetching from Git Server"
    Invoke-ExternalTool { git branch -r } "Error showing branches on Git Server"
}

Set-Alias srb Show-RemoteBranches