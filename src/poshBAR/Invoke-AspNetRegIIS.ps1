<#
    .DESCRIPTION
       Will register asp.net into IIS

    .EXAMPLE
        Invoke-AspNetRegIIS '-i'

    .EXAMPLE 
        aspnet_regiis '-iur'

    .PARAMETER argument
        The registration options
        -i - Install ASP.NET and updates existing applications to use the specified version of the application pool.
        -ir - Installs and registers ASP.NET. This option is the same as the -i option except that it does not change the CLR version associated with any existing application pools.
        -iur - If ASP.NET is not currently registered with IIS, performs the tasks of -i. If a previous version of ASP.NET is already registered with IIS, performs the tasks of -ir.

#>
function Invoke-AspNetRegIIS {
    [CmdletBinding()]
     param(
        [parameter(Mandatory=$true, Position=0)] [string] [ValidateSet('-i','-ir','-iur')] $argument

     )

     [array]$paths = @(
         "$env:WINDIR\.NET\Framework\v1.0.3705",             # .NET Framework version 1
         "$env:WINDIR\Microsoft.NET\Framework\v1.1.4322",    # .NET Framework version 1.1
         "$env:WINDIR\Microsoft.NET\Framework\v2.0.50727",   # .NET Framework version 2.0, version 3.0, and version 3.5 (32-bit systems)
         "$env:WINDIR\Microsoft.NET\Framework64\v2.0.50727", # .NET Framework version 2.0, version 3.0, and version 3.5 (64-bit systems)
         "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319",   # .NET Framework version 4 (32-bit systems)
         "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319"  # .NET Framework version 4 (64-bit systems)
     )

     $paths| % {
        if(Test-Path $_){
            $location = $_
        }
     }
 
     if(-not [string]::IsNullOrWhiteSpace($location)){
        Exec {"$location\aspnet_regiis.exe $argument"} "An error occurred while trying to register IIS."
     } else {
        throw 'aspnet_regiis.exe was not found on this machine.'
     }
     
}
Set-Alias aspnet_regiis Invoke-AspNetRegIIS