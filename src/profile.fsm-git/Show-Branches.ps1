<#
.SYNOPSIS
This will list all the branches stored locally

.DESCRIPTION
This will list all the branches stored locally

.EXAMPLE
Show-RemoteTags
#>
Function Show-Branches(){
    Invoke-ExternalTool { git branch } "Error showing local branches"
}

Set-Alias sb Show-Branches