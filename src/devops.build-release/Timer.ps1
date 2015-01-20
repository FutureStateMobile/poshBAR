[string]    $script:initialTask

function Set-TaskTimeStamp{
    param(
        [parameter(Mandatory=$true,position=0)] [string] $taskName
    )

    if(-not $global:initialized){ return }

    $global:timeStampOutput += new-object PSObject -property @{ Duration = $global:timer.Elapsed; Name = $global:previousTask}
    [timespan]$global:totalElapsed.Add($global:timer.Elapsed) | out-null
    $global:previousTask = $taskName
    #global:timer.Restart() not supported in PS2
    $global:timer.Reset()
    $global:timer.Start()
}

function Initialize-TaskTimer{
    param(
        [parameter(Mandatory=$true,position=0)] [string] $initialTask
    )
    $script:initialTask = $initialTask
    $global:timer = [System.Diagnostics.Stopwatch]::StartNew()
    [timespan]$global:totalElapsed = 0
    $global:previousTask = "Initialize $initialTask"
    $global:timeStampOutput = @()
    $global:initialized = $true
}

function Clear-TaskTimer {    
    $global:timer.Stop()
    $global:timer.Reset()
    $global:timeStampOutput = @()
    $global:initialized = $false
    $global:previousTask = $null
}

function Write-TaskTimeSummary{
    param(
        [parameter(Mandatory=$true,position=0)] [string] $reportTitle
    )
    $global:timeStampOutput += new-object PSObject -property @{ Duration = $global:timer.Elapsed; Name = $global:previousTask}
    [timespan]$global:totalElapsed.Add($global:timer.Elapsed) | out-null
    $global:timeStampOutput += new-object PSObject -property @{ Name = "Total:"; Duration = $global:totalElapsed}

    Write-Host "$script:initialTask Succeeded!" -f Green
    Write-Host ""
    Write-Host "----------------------------------------------------------------------"
    Write-Host $reportTitle
    Write-Host "----------------------------------------------------------------------"

    $global:timeStampOutput | ft -AutoSize -property Name,Duration | out-string -stream | where-object { $_ }
    #Write-Host $global:timeStampOutput
    Clear-TaskTimer
}