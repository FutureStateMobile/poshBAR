<#
    .DESCRIPTION
       Will register asp.net into IIS

    .EXAMPLE
        Invoke-AspNetRegIIS -i

    .EXAMPLE 
        aspnet_regiis -iru -framework 3.5

    .PARAMETER $siteName
        Install ASP.NET to a specific site only (recommended). 

    .PARAMETER i
        Install ASP.NET and updates existing applications to use the specified version of the application pool.

    .PARAMETER ir
        Installs and registers ASP.NET. This option is the same as the -i option except that it does not change the CLR version associated with any existing application pools.

    .PARAMETER iru
        If ASP.NET is not currently registered with IIS, performs the tasks of -i. If a previous version of ASP.NET is already registered with IIS, performs the tasks of -ir.

    .PARAMETER framework
        The framework version to register.
        Defaults to 4.0

    .PARAMETER noRestart
        Tells aspnet_regiis.exe to NOT restart IIS.

#>
function Invoke-AspNetRegIIS {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true, ParameterSetName='-s')] [string] [alias('s')] $siteName,
        [parameter(Mandatory=$true, ParameterSetName='-i', Position=0)] [switch] $i,
        [parameter(Mandatory=$true, ParameterSetName='-ir', Position=0)] [switch] $ir,
        [parameter(Mandatory=$true, ParameterSetName='-iru', Position=0)] [switch] $iru,
        
        [parameter(Mandatory=$false, ParameterSetName='-s')] [ValidateSet(2.0,3.0,3.5,4.0,4.5)] [double] 
        [parameter(Mandatory=$false, ParameterSetName='-i')] [ValidateSet(2.0,3.0,3.5,4.0,4.5)] [double] 
        [parameter(Mandatory=$false, ParameterSetName='-ir')] [ValidateSet(2.0,3.0,3.5,4.0,4.5)] [double] 
        [parameter(Mandatory=$false, ParameterSetName='-iru')] [ValidateSet(2.0,3.0,3.5,4.0,4.5)] [double] 
        $framework = 4.0,
        
        [parameter(Mandatory=$false, ParameterSetName='-s')] [switch] 
        [parameter(Mandatory=$false, ParameterSetName='-i')] [switch]
        [parameter(Mandatory=$false, ParameterSetName='-ir')] [switch]
        [parameter(Mandatory=$false, ParameterSetName='-iru')] [switch]
        $noRestart
    )
    
    $ErrorActionPreference = "Stop"
        
    $path = Get-PathToAspNetRegIIS $framework
    $output = @{ # used for return results
        'path' = $path
        'switch' = $($PsCmdlet.ParameterSetName)
        'norestart' = $false
    }
    
    if(-not (Test-Path "$path\aspnet_regiis.exe")){
        Write-Host '' # just inputs a carriage return if an error occurs
        throw $msgs.error_aspnet_regiis_not_found
    }
  
    $command = @("$path\aspnet_regiis.exe")
    if($PsCmdlet.ParameterSetName -eq '-s'){
    Write-Host "Ensuring ASP.NET version $framework is registered for $siteName."
        
        $command += "-s"
            
        $siteId = Get-IISSiteId $siteName
        $sitePath = "W3SVC/$siteId/root"
        $command += "$sitePath"
            
        $output.siteName = $siteName
        $output.sitePath = $sitePath
    } else {
        
        Write-Host "Ensuring ASP.NET version $framework is registered in IIS."
        $command += "${$PsCmdlet.ParameterSetName}"
        if( $poshBAR.DisableGlobalASPNETRegIIS ) {
            Write-Host '' # just inputs a carriage return if an error occurs
            Write-Warning $($msgs.wrn_aspnet_regiis_disabled -f $framework)
        }
    }
    
    if($noRestart.IsPresent) {
        $command += '-norestart'
        $output.norestart = $true
    }
    
    
    try{
        Write-Host "Executing: $command" -NoNewline
        Exec {. $command} $msgs.wrn_aspnet_regiis_not_found
        Write-Host "`tDone" -f Green
    } catch {
        Write-Host '' # just inputs a carriage return if an error occurs
        Write-Warning $_ # We don't want to fail deployment if this command fails. Just write out the warning.
        Write-Host 'The deployment will continue...'
    }

    Write-Output $output
}
Set-Alias aspnet_regiis Invoke-AspNetRegIIS


# PRIVATE FUNCTIONS.
function Get-IisSiteId($siteName) {
    $matches = @() # reset matches variable
    $appcmd = "$env:windir\system32\inetsrv\appcmd.exe"
    $regex = '^SITE \".*\" \(id:(?<id>\d).*$'
      
    $record = Invoke-Expression  "$appcmd list site" | ? {$_.Contains($siteName)}
    $record -match $regex | out-null
    $siteId = $matches['id']
    
    if($siteId){ 
        Write-Output $siteId
    } else {
        throw "A site with the name $siteName does not exist." # todo: add to $msgs variable
    }
}

function Get-PathToAspNetRegIIS($framework){
    
    # all possible locations for aspnet_regiis.exe excluding v1 and v1.1
    $v2_32 = "$env:WINDIR\Microsoft.NET\Framework\v2.0.50727"    # .NET Framework version 2.0, version 3.0, and version 3.5 (32-bit systems)
    $v2_64 = "$env:WINDIR\Microsoft.NET\Framework64\v2.0.50727"  # .NET Framework version 2.0, version 3.0, and version 3.5 (64-bit systems)
    $v4_32 = "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319"    # .NET Framework version 4 (32-bit systems)
    $v4_64 = "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319"  # .NET Framework version 4 (64-bit systems)

    if($ENV:PROCESSOR_ARCHITECTURE -eq 'amd64'){
        switch($framework){
            1.0 { return $v1}
            1.1 { return $v1_1}
            2.0 { return $v2_64}
            3.0 { return $v2_64}
            3.5 { return $v2_64}
            4.0 { return $v4_64}
            4.5 { return $v4_64}
        }
    } else {
        switch($framework){
            1.0 { return $v1}
            1.1 { return $v1_1}
            2.0 { return $v2_32}
            3.0 { return $v2_32}
            3.5 { return $v2_32}
            4.0 { return $v4_32}
            4.5 { return $v4_32}
        }
    }
}