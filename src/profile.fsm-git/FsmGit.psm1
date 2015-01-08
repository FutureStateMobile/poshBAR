if (Get-Module FsmGit) { return }

Push-Location $psScriptRoot

. .\Complete-Feature.ps1
. .\Get-Changes.ps1
. .\Get-CurrentBranch.ps1
. .\Get-LocalGitStatus.ps1
. .\Initialize-Git.ps1
. .\Merge-FromBranch.ps1
. .\Merge-ToBranch.ps1
. .\Push-Changes.ps1
. .\Remove-Branch.ps1
. .\Remove-FeatureBranch.ps1
. .\Save-Changes.ps1
. .\Show-Branches.ps1
. .\Show-RemoteBranches.ps1
. .\Show-RemoteTags.ps1
. .\Start-Feature.ps1
. .\FsmTabExpansion.ps1
. .\Use-Branch.ps1
. .\Use-RemoteBranch.ps1

Pop-Location

Export-ModuleMember `
    -Alias @(
        '*') `
    -Function @(
         'Complete-Feature',
         'Get-Changes',
         'Get-CurrentBranch',
         'Get-LocalGitStatus',
         'Initialize-Git',
         'Merge-FromBranch',
         'Merge-ToBranch',
         'Push-Changes',
         'Remove-Branch',
         'Remove-FeatureBranch',
         'Save-Changes',
         'Show-Branches',
         'Show-RemoteBranches',
         'Show-RemoteTags',
         'Start-Feature',
         'TabExpansion',
         'Use-Branch',
         'Use-RemoteBranch')