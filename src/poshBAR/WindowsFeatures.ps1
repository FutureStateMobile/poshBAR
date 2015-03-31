if(-not $script:dismFeatures){
    $script:dismFeatures = new-object System.Collections.ArrayList
}

function Install-WindowsFeatures{
    [CmdletBinding()]
    param(
        [ValidateScript({Assert-WindowsFeatures})][string[]] $features
    )
    
    Assert($features.Count -ne 0) ($msgs.error_must_supply_a_feature)
    $features | % {
        $__ = $_.Replace('?','')
        $f = Get-WindowsFeatures | ? {$_.feature -eq $__}
        
        if([string]::IsNullOrEmpty($f.feature)){
            Write-Warning "$__ is not a valid feature for this version of Windows."
        } else {        
            Write-Host ($msgs.msg_enabling_windows_feature -f $f.feature) -NoNewline
            if($f.state -ne "enabled"){
                try{
                    Exec{Dism /online /Enable-Feature /FeatureName:$($f.feature) /NoRestart /Quiet} 
                    Write-Host "`tDone" -f Green
                }catch{
                    # Trying again with the All keyword because probably a dependency is missing.
                    Exec{Dism /online /Enable-Feature /FeatureName:$($f.feature) /NoRestart /Quiet /All} 
                    Write-Host "`tDone (with dependencies)" -f Green
                }
            } else {
                Write-Host "`tExists." -f Cyan
            }
        }
    }
}

function Get-WindowsFeatures {
    if($script:dismFeatures.Count -le 0)
    {
        $allFeatures = DISM.exe /ONLINE /Get-Features /FORMAT:List | Where-Object { $_.StartsWith("Feature Name") -OR $_.StartsWith("State") } 
        for($i = 0; $i -lt $allFeatures.length; $i=$i+2) {
            $feature = $allFeatures[$i]
            $state = $allFeatures[$i+1]
            $script:dismFeatures.add(@{feature=$feature.split(":")[1].trim();state=$state.split(":")[1].trim()}) | OUT-NULL
        }
    }
    return $script:dismFeatures
}

#
# Private Methods
#
function Assert-WindowsFeatures {
    $featureList = @()
    Get-WindowsFeatures | %{
        $featureList+=$_.Feature
    }

    if(-not ($featureList -contains $_) -and -not($_.EndsWith("?"))){
        throw $msgs.error_feature_set_invalid -f $_, $($featureList -join ', ')
        Exit 1
    }

    $true
}