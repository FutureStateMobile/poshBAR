param( [hashtable] $poshBAR )

if (Test-Path env:TEAMCITY_VERSION) {
# Setup the buffer size for teamcity output
try {
    $rawUI = (Get-Host).UI.RawUI
    $m = $rawUI.MaxPhysicalWindowSize.Width
    $rawUI.BufferSize = New-Object Management.Automation.Host.Size ([Math]::max($m, 500), $rawUI.BufferSize.Height)
    $rawUI.WindowSize = New-Object Management.Automation.Host.Size ($m, $rawUI.WindowSize.Height)
} catch {}

# Create a variable that states we're running on TeamCity. (Will be used in Format-TaskNameToHost
$poshBAR.IsRunningOnTeamCity = $true
}