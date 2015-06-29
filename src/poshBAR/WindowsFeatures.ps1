<#
    .SYNOPSIS
        Ensures all Windows Features listed within the $features arrray are installed
        
    .PARAMETER features
        The collection of Windows Features to install
        
    .EXAMPLE
        Install-WindowsFeatures @('IIS-WebServer','IIS-WebServerRole','IIS-ISAPIFilter',  'IIS-ISAPIExtensions',  'IIS-NetFxExtensibility','IIS-ASPNET')
        
    .EXAMPLE
        Install-WindowsFeatures 'IIS-ASPNET45?'
        
    .NOTES
        Optional features can be passed in with a trailing `?` (see Example 2).
#>
function Install-WindowsFeatures{
    [CmdletBinding()]
    param(
        [ValidateScript({Assert-WindowsFeatures})][string[]] $features
    )
    
    Assert($features.Count -ne 0) ($msgs.error_must_supply_a_feature)
    $features | % {
        $key = $_.Replace('?','')    
        $state = (Get-WindowsFeatures)[$key]
        $feature = @{$key = $state}
        
        if(!$state){
            Write-Warning "$key is not a valid feature for this version of Windows."
        } else {    
            $value = $feature[$key]    
            Write-Host ($msgs.msg_enabling_windows_feature -f $key) -NoNewline

            if($value -ne "enabled"){
                if($poshBAR.DisableWindowsFeaturesAdministration){
                    Write-Host # inserts a break
                    throw ($msgs.error_windows_features_admin_disabled -f $key) 
                }
                
                try{
                    Exec{Dism /online /Enable-Feature /FeatureName:$($key) /NoRestart /Quiet /English} 
                    Write-Host "`tDone" -f Green
                }catch{
                    # Trying again with the All keyword because probably a dependency is missing.
                    Exec{Dism /online /Enable-Feature /FeatureName:$($key) /NoRestart /Quiet /All /English} 
                    Write-Host "`tDone (with dependencies)" -f Green
                }
            } else {
                Write-Host "`tExists." -f Cyan
            }
        }
    }
}

<#
    .SYNOPSIS
        Get's all windows features available to the current machine and stores them in $env:TEMP
        
    .EXAMPLE
        Get-WindowsFeatures
    .NOTES
        Windows features are stored in $env:TEMP in order to improve future lookup times.
        The lookup is done using DISM.exe
#>
function Get-WindowsFeatures {
    
    if(!$global:poshBAR.WindowsFeatures){
        $global:poshBAR.WindowsFeatures = @{}
        
        $allFeatures = DISM.exe /ONLINE /Get-Features /FORMAT:List /English | Where-Object { $_.StartsWith("Feature Name") -OR $_.StartsWith("State") } 
        
        for($i = 0; $i -lt $allFeatures.length; $i=$i+2) {
            $feature = $allFeatures[$i].split(":")[1].trim()
            $state = $allFeatures[$i+1].split(":")[1].trim()
            
            $global:poshBAR.WindowsFeatures.Add($feature, $state)
        }
    }
    return $global:poshBAR.WindowsFeatures
}

#
# Private Methods
#
function Assert-WindowsFeatures {
    $feature = $_
    $allFeatures = Get-WindowsFeatures
    $ht = $allFeatures | ? {$_[$feature]}

    if(-not ($ht) -and -not($_.EndsWith("?"))){
        throw "{0} is not a member of {1}" -f $_, $($allFeatures.Keys -join ", ")
        Exit 1
    }

    $true
}