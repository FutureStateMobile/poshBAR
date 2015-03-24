<#
    .DESCRIPTION
       Will register asp.net into IIS

    .EXAMPLE
        Invoke-AspNetRegIIS '-i'

    .EXAMPLE 
        aspnet_regiis '-iur' -framework 3.5

    .PARAMETER argument
        The registration options
        -i - Install ASP.NET and updates existing applications to use the specified version of the application pool.
        -ir - Installs and registers ASP.NET. This option is the same as the -i option except that it does not change the CLR version associated with any existing application pools.
        -iur - If ASP.NET is not currently registered with IIS, performs the tasks of -i. If a previous version of ASP.NET is already registered with IIS, performs the tasks of -ir.

    .PARAMETER framework
        The framework version to register.
        Defaults to 4.0

#>
function Invoke-AspNetRegIIS {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$false, ParameterSetName='-i')] [switch] $i,
        [parameter(Mandatory=$false, ParameterSetName='-ir')] [switch] $ir,
        [parameter(Mandatory=$false, ParameterSetName='-iur')] [switch] $iur,
        
        [parameter(Mandatory=$false, ParameterSetName='-i')] [ValidateSet(1.0,1.1,2.0,3.0,3.5,4.0,4.5)] [double] 
        [parameter(Mandatory=$false, ParameterSetName='-ir')] [ValidateSet(1.0,1.1,2.0,3.0,3.5,4.0,4.5)] [double] 
        [parameter(Mandatory=$false, ParameterSetName='-iur')] [ValidateSet(1.0,1.1,2.0,3.0,3.5,4.0,4.5)] [double] 
        $framework = 4.0
    )
    $ErrorActionPreference = "Stop"
    Write-Host "Ensuring ASP.NET version $framework is registered in IIS."

    # all possible locations for aspnet_regiis.exe
    $v1   = "$env:WINDIR\.NET\Framework\v1.0.3705"               # .NET Framework version 1
    $v1_1 = "$env:WINDIR\Microsoft.NET\Framework\v1.1.4322"      # .NET Framework version 1.1
    $v2_32 = "$env:WINDIR\Microsoft.NET\Framework\v2.0.50727"    # .NET Framework version 2.0, version 3.0, and version 3.5 (32-bit systems)
    $v2_64 = "$env:WINDIR\Microsoft.NET\Framework64\v2.0.50727"  # .NET Framework version 2.0, version 3.0, and version 3.5 (64-bit systems)
    $v4_32 = "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319"    # .NET Framework version 4 (32-bit systems)
    $v4_64 = "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319"  # .NET Framework version 4 (64-bit systems)


    if($ENV:PROCESSOR_ARCHITECTURE -eq 'amd64'){
        switch($framework){
            1.0 { $path = $v1;break}
            1.1 { $path = $v1_1;break}
            2.0 { $path = $v2_64;break}
            3.0 { $path = $v2_64;break}
            3.5 { $path = $v2_64;break}
            4.0 { $path = $v4_64;break}
            4.5 { $path = $v4_64;break}
        }
    } else {
        switch($framework){
            1.0 { $path = $v1;break}
            1.1 { $path = $v1_1;break}
            2.0 { $path = $v2_32;break}
            3.0 { $path = $v2_32;break}
            3.5 { $path = $v2_32;break}
            4.0 { $path = $v4_32;break}
            4.5 { $path = $v4_32;break}
        }
    }
         
    if(-not (Test-Path "$path\aspnet_regiis.exe")){
        Write-Host '' # just inputs a carriage return if an error occurs
        throw 'aspnet_regiis.exe was not found on this machine.'
    }

    try{
        Write-Host "Executing: '$path\aspnet_regiis.exe $($PsCmdlet.ParameterSetName)'." -NoNewline
        Exec {"$path\aspnet_regiis.exe $argument"} "An error occurred while trying to register IIS." | out-null
        Write-Host "`tDone" -f Green
    } catch {
        Write-Host '' # just inputs a carriage return if an error occurs
        throw $_
    }
}
Set-Alias aspnet_regiis Invoke-AspNetRegIIS