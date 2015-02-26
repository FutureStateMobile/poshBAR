function Invoke-Deployment {
    $currentContext = $fsmbr.context.Peek()
    $deploymentStopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    $stepList = $currentContext.steps
    if ($stepList) {
        $stepList.Keys | %{
            Invoke-Step $_
        }
    }
    WriteStepTimeSummary $deploymentStopWatch.Elapsed
    $fsmbr = $null
}

function Invoke-Step{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)] [string]$stepName
    )

    $stepKey = $stepName.ToLower()
    $currentContext = $fsmbr.context.Peek()
    $step = $currentContext.steps.$stepKey
    
    Format-TaskNameToHost $step.Name

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    & $step.Action
    $step.Duration = $stopwatch.Elapsed
}

function Initialize-Context{
    $script:fsmbr = @{}
    $fsmbr.context = new-object system.collections.stack
    $fsmbr.context.push(@{
        "steps" = New-Object System.Collections.Specialized.OrderedDictionary}
    )
}

function Assert
{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)]$conditionToCheck,
        [Parameter(Position=1,Mandatory=1)]$failureMessage
    )
    if (!$conditionToCheck) {
        throw ("Assert: " + $failureMessage)
    }
}

function WriteStepTimeSummary($totalDeploymentDuration) {
    if ($fsmbr.context.count -gt 0) {
        Write-Host "Deployment Complete" -f Green
        "-" * 70
        "Deployment Report"
        "-" * 70
        $list = @()
        $currentContext = $fsmbr.context.Peek()

        $stepList = $currentContext.steps
        if ($stepList) {
            $stepList.Keys | %{
                $stepForReport = $currentContext.steps.$_
                $list += new-object PSObject -property @{
                    Name = $stepForReport.Name;
                    Duration = $stepForReport.Duration
                }
            }
        }

        $list += new-object PSObject -property @{
            Name = "Total:";
            Duration = $totalDeploymentDuration
        }
        # using "out-string | where-object" to filter out the blank line that format-table prepends
        $list | format-table -autoSize -property Name,Duration | out-string -stream | where-object { $_ }
    }
}

function RequiredFeatures {
    param([string[]] $script:features)
    Step InstallRequiredWindowsFeatures {
        Install-WindowsFeatures $script:features
    }
}

function Step{
    param(
        [parameter(Mandatory=$true,position=0)] [string] $name,
        [parameter(Mandatory=$true,position=1)] [scriptblock] $action
    )
    $newStep = @{
        Name = $name
        Action = $action
    }

    $stepKey = $name.ToLower()
    
    if(!$fsmbr){
        Initialize-Context
    }

    $currentContext = $fsmbr.context.Peek()
    #Assert (!$currentContext.steps.ContainsKey($stepKey)) ($msgs.error_duplicate_step_name -f $name)
        
    $currentContext.steps.$stepKey = $newStep
}