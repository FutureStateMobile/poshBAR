Function Get-LocalGitStatus() {
    Invoke-ExternalTool { git status } "Error running Git Status"
}

Set-Alias st Get-LocalGitStatus