<#
.SYNOPSIS
This will list all the tags on the remote server.

.DESCRIPTION
This will list all the tags on the remote server.

.EXAMPLE
Show-RemoteTags
#>
Function Show-RemoteTags(){
    Invoke-ExternalTool { git ls-remote --tags } "Error showing tags on Git Server"
}


Set-Alias srt Show-RemoteTags