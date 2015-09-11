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
                Write-Host "`tAlready exists, skipping." -f Cyan
            }
        }
    }
}

<#
    .SYNOPSIS
        Get's all windows features available to the current machine. Also allows fuzzy filtering based on feature name.
        
    .EXAMPLE
        Get-WindowsFeatures

    .EXAMPLE
        Get-WindowsFeatures http

    .PARAMETER filter
        Part of the feature name you would like to filter by. (not case sensitive)

    .REMARKS
        Locating Windows Features is done using DISM.exe

    .NOTES
        Windows features are stored in $poshBAR:WindowsFeatures in order to improve future lookup times.
        
#>
function Get-WindowsFeatures {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$false, Position=0)] [string] $filter
    )
    Write-Host
    Write-Host 'Getting Windows Features for the local Operating System.' -NoNewline

    # if the variable is emtpy, go off and populate it with features available to the local operating system
    if(!$global:poshBAR.WindowsFeatures){
        $global:poshBAR.WindowsFeatures = @{}
        
        $allFeatures = DISM.exe /ONLINE /Get-Features /FORMAT:List /English | Where-Object { $_.StartsWith("Feature Name") -OR $_.StartsWith("State") } 
        
        for($i = 0; $i -lt $allFeatures.length; $i=$i+2) {
            $feature = $allFeatures[$i].split(":")[1].trim()
            $state = $allFeatures[$i+1].split(":")[1].trim()
            
            $global:poshBAR.WindowsFeatures.Add($feature, $state)
        }
    }

    # if a filter is passed in, be sure to filter the results
    if($filter) {
        $filter = $filter.ToLower()
        Write-Host "`tFiltered: [ $filter ]" -ForegroundColor DarkCyan
        return $global:poshBAR.WindowsFeatures.GetEnumerator() | ? { $_.Key.ToLower().Contains($filter) }
    }

    Write-Host # carriage return
    # otherwise return all results.
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
        throw $msgs.error_invalid_windows_feature -f $_, $($allFeatures.Keys -join ", ")
        Exit 1
    }

    $true
}