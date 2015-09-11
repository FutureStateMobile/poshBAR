param (
    [alias("t")]  [string] $task = "Default",
    [alias("bn")] [string] $buildNumber = "0.1.1.1",
    [alias("pt")] [string] $pesterTestName,
    [alias("p")]  [switch] $projectHelp    
)

$currentDir = Split-Path $script:MyInvocation.MyCommand.Path
if (-not (Get-Module Invoke-PSake)) {
    Import-Module "$currentDir\packages\psake.*\tools\psake.psm1" -Force
}

$psake.use_exit_on_error = $true

if ($projectHelp.isPresent) {
    Invoke-PSake ".\build\build.ps1" -docs
} else {
    $buildNumberParts = $buildNumber.split(".")

    if ($buildNumberParts.length -ne 4) {
        throw "Incorrectly formatted Build Number, it must be formatted (n.n.n.n)"
    }
    
    $version = "$($buildNumberParts[0]).$($buildNumberParts[1]).$($buildNumberParts[2])";
    $buildNumber = $($buildNumberParts[3]);

    Invoke-PSake ".\build\build.ps1" $task -parameters @{
        version = $version;
        buildNumber = $buildNumber;
        pesterTestName = $pesterTestName;
    }

    if ($psake.build_success -eq $false) {
        exit 1
    }
}
