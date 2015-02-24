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
        Write-Host "`nDeployment Complete`n" -f Green
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

$script:dismFeatures = new-object System.Collections.ArrayList
function Get-WindowsFeatures {
    
    if(!$dismFeatures)
    {
        $allFeatures = DISM.exe /ONLINE /Get-Features /FORMAT:List | Where-Object { $_.StartsWith("Feature Name") -OR $_.StartsWith("State") } 
        for($i = 0; $i -lt $allFeatures.length; $i=$i+2) {
            $feature = $allFeatures[$i]
            $state = $allFeatures[$i+1]
            $dismFeatures.add(@{feature=$feature.split(":")[1].trim();state=$state.split(":")[1].trim()}) | OUT-NULL
        }
    }
    return $dismFeatures
}

function RequiredFeatures {
    param(
        [ValidateScript({$f = @();Get-WindowsFeatures | %{$f+=$_.Feature};if($f -contains $_){$true}else{throw $msgs.error_feature_set_invalid -f $_, $($f -join ', ')}})][string[]] $script:features
)
    Assert($features.Count -ne 0) ($msgs.error_must_supply_a_feature)
    Step InstallRequiredWindowsFeatures {
        $features | % {
            $tempVal = $_
            $f = Get-WindowsFeatures | ? {$_.feature -eq $tempVal}
            Write-Host "Enabling Feature $($f.feature)" -NoNewline
            if($f.state -ne "enabled"){
                try{
                    Exec{Dism /online /Enable-Feature /FeatureName:$($f.feature) /NoRestart /Quiet} 
                    Write-Host "`tDone" -f Green
                }catch{
                    # Trying again with the All keyword because probably a dependency is missing.
                    Exec{Dism /online /Enable-Feature /FeatureName:$($f.feature) /NoRestart /Quiet /All} 
                    Write-Host "`Done (with dependencies)" -f Green
                }
            } else {
                Write-Host "`tAlready Available." -f Cyan
            }
        }
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

DATA msgs {
convertfrom-stringdata @'
    error_duplicate_step_name = Step {0} has already been defined.
    error_must_supply_a_feature = You must supply at least one Windows Feature.
    error_feature_set_invalid = The argument `"{0}`" does not belong to the set `"{1}`".
'@
}