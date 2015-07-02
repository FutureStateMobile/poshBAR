$appcmd = "$env:windir\system32\inetsrv\appcmd.exe"

<#
    .DESCRIPTION
        Creates an AppPool in IIS and sets up the specified identity to run under.

    .EXAMPLE
        New-AppPool "myAppPool" "NetworkService"

    .EXAMPLE
        New-AppPool "myAppPool" "NetworkService" -managedPipelineMode 'Classic'

    .PARAMETER appPoolName
        The name of the application pool.

    .PARAMETER appPoolIdentityType
        The type of identity you want the AppPool to run as, default is 'LocalSystem'. 

    .PARAMETER maxProcesses
        The number of Worker Processes this AppPool should spawn, default is 1.

    .PARAMETER username
        The Username that this app pool should run as.

    .PARAMETER password
        The password for the Username that this app pool should run as.

    .PARAMETER managedPipelineMode
        Is the app pool to be running as 'Classic', or 'Integrated' (Defaults to Integrated)

    .PARAMETER managedRuntimeVersion
        Runtime version for the app pool. (Defaults to v4.0)

    .PARAMETER alwaysRunning
        Should the app pool be configured as 'Always Running'

    .SYNOPSIS
        Will setup an Application Pool for an IIS Application.
#>
function New-AppPool{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true, position=0)] [string] $appPoolName,
        [parameter(Mandatory=$false,position=1)] [string] [ValidateSet('LocalSystem','LocalService','NetworkService','SpecificUser','ApplicationPoolIdentity')] $appPoolIdentityType = 'NetworkService',
        [parameter(Mandatory=$false,position=2)] [int] $maxProcesses = 1,
        [parameter(Mandatory=$false,position=3)] [string] [alias('un')] $username,
        [parameter(Mandatory=$false,position=4)] [string] [alias('pwd')] $password,
        [parameter(Mandatory=$false,position=5)] [string] [ValidateSet('Integrated','Classic')] $managedPipelineMode = 'Integrated',
        [parameter(Mandatory=$false,position=6)] [string] $managedRuntimeVersion = "v4.0",
        [parameter(Mandatory=$false)] [switch] $alwaysRunning,
        [parameter(Mandatory=$false)] [switch] $updateIfFound
    )

    $exists = Confirm-AppPoolExists $appPoolName

    if (!$exists){
        if($poshBAR.DisableCreateIISApplicationPool) {
            Write-Warning $msgs.wrn_apppool_creation_disabled
        } else {
            Write-Host "Creating AppPool: $appPoolName" -NoNewLine
            $newAppPool = "$appcmd add APPPOOL"
            $newAppPool += " /name:$appPoolName"
            $newAppPool += " /processModel.identityType:$appPoolIdentityType"
            $newAppPool += " /processModel.maxProcesses:$maxProcesses"
            $newAppPool += " /managedPipelineMode:$managedPipelineMode"
            $newAppPool += " /managedRuntimeVersion:$managedRuntimeVersion"
            $newAppPool += ' /autoStart:true'
            $newAppPool += if($alwaysRunning.IsPresent) {' /startMode:AlwaysRunning'}
        
            if ( $appPoolIdentityType -eq "SpecificUser" ){
                $newAppPool += " /processModel.userName:$username"
                $newAppPool += " /processModel.password:$password"
            }
    
            Exec { Invoke-Expression  $newAppPool } -retry 10 | Out-Null
            Write-Host "`tDone" -f Green            
        }
    }else{
        if($updateIfFound.IsPresent){
            Update-AppPool $appPoolName $appPoolIdentityType $maxProcesses $username $password $managedPipelineMode $managedRuntimeVersion    
        }
    }
}    

<#
    .DESCRIPTION
        Updates an AppPool in IIS and sets up the specified identity to run under.

    .EXAMPLE
        Update-AppPool "myAppPool" "NetworkService"

    .EXAMPLE
        Update-AppPool "myAppPool" "NetworkService" -managedPipelineMode 'Classic'

    .PARAMETER appPoolName
        The name of the application pool.

    .PARAMETER appPoolIdentityType
        The type of identity you want the AppPool to run as, default is 'LocalSystem'. 

    .PARAMETER maxProcesses
        The number of Worker Processes this AppPool should spawn, default is 1.

    .PARAMETER username
        The Username that this app pool should run as.

    .PARAMETER password
        The password for the Username that this app pool should run as.

    .PARAMETER managedPipelineMode
        Is the app pool to be running as 'Classic', or 'Integrated' (Defaults to Integrated)

    .PARAMETER managedRuntimeVersion
        Runtime version for the app pool. (Defaults to v4.0)

    .PARAMETER alwaysRunning
        Should the app pool be configured as 'Always Running'

    .SYNOPSIS
        Will update an Application Pool for an IIS Application.
#>
function Update-AppPool{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true, position=0)] [string] $appPoolName,
        [parameter(Mandatory=$false,position=1)] [string] [ValidateSet('LocalSystem','LocalService','NetworkService','SpecificUser','ApplicationPoolIdentity')] $appPoolIdentityType = 'NetworkService',
        [parameter(Mandatory=$false,position=2)] [int] $maxProcesses = 1,
        [parameter(Mandatory=$false,position=3)] [string] $username,
        [parameter(Mandatory=$false,position=4)] [string] $password,
        [parameter(Mandatory=$false,position=5)] [string] [ValidateSet('Integrated','Classic')] $managedPipelineMode = 'Integrated',
        [parameter(Mandatory=$false,position=6)] [string] $managedRuntimeVersion = "v4.0",
        [parameter(Mandatory=$false,position=7)] [switch] $alwaysRunning
    )

    $exists = Confirm-AppPoolExists $appPoolName

    if ($exists){
        Write-Host "Updating AppPool: $appPoolName" -NoNewLine
        $updateAppPool = "$appcmd set APPPOOL $appPoolName"
        $updateAppPool += " /processModel.identityType:$appPoolIdentityType"
        $updateAppPool += " /processModel.maxProcesses:$maxProcesses"
        $updateAppPool += " /managedPipelineMode:$managedPipelineMode"
        $updateAppPool += " /managedRuntimeVersion:$managedRuntimeVersion"
        $updateAppPool += ' /autoStart:true'
        $updateAppPool += if($alwaysRunning.IsPresent) {' /startMode:AlwaysRunning'}
    
        if ( $appPoolIdentityType -eq "SpecificUser" ){
            $updateAppPool += " /processModel.userName:$username"
            $updateAppPool += " /processModel.password:$password"
        }

        Exec { Invoke-Expression  $updateAppPool } -retry 10 | Out-Null
        Write-Host "`tDone" -f Green
    }else{
        Write-Warning ($msgs.wrn_invalid_app_pool -f $appPoolName)
    }
}

<#
    .DESCRIPTION
        Will confirm whether or not an application pool exists

    .EXAMPLE
        Confirm-AppPoolExists "myAppPool"

    .PARAMETER appPoolName
        The name of the application pool.

    .SYNOPSIS
        Will confirm whether or not an application pool exists
#>
function Confirm-AppPoolExists( $appPoolName ){
    $getAppPool = Get-AppPool($appPoolName)
    return ($getAppPool -ne $null)
}

<#
    .DESCRIPTION
        Will get an application pool by name

    .EXAMPLE
        Get-AppPool "myAppPool"

    .PARAMETER appPoolName
        The name of the application pool.

    .SYNOPSIS
        Will get an application pool by name
#>
function Get-AppPool( $appPoolName ){
    $getAppPools = "$appcmd list APPPOOL $appPoolName"
    return Invoke-Expression $getAppPools
}

<#
    .DESCRIPTION
        Will get all application pools

    .EXAMPLE
        Get-AppPools
#>
function Get-AppPools{
    $getAppPools = "$appcmd list APPPOOLS"
    Invoke-Expression $getAppPools
}

<#
    .DESCRIPTION
        Will start an application pool by name

    .EXAMPLE
        Start-AppPool "myAppPool"

    .PARAMETER appPoolName
        The name of the application pool.

    .SYNOPSIS
        Will start an application pool by name
#>
function Start-AppPool( $appPoolName ){
    $getAppPools = "$appcmd start APPPOOL $appPoolName"
    return Invoke-Expression $getAppPools
}

<#
    .DESCRIPTION
        Will stop an application pool by name

    .EXAMPLE
        Stop-AppPool "myAppPool"

    .PARAMETER appPoolName
        The name of the application pool.

    .SYNOPSIS
        Will stop an application pool by name
#>
function Stop-AppPool( $appPoolName ){
    $getAppPools = "$appcmd stop APPPOOL $appPoolName"
    return Invoke-Expression $getAppPools
}

<#
    .DESCRIPTION
        Will remove an application pool by name

    .EXAMPLE
        Remove-AppPool "myAppPool"

    .PARAMETER appPoolName
        The name of the application pool.

    .SYNOPSIS
        Will remove an application pool by name
#>
function Remove-AppPool( $appPoolName ){
    $getAppPools = "$appcmd delete APPPOOL $appPoolName"
    return Invoke-Expression $getAppPools
}

function Get-ModuleDirectory {
    return Split-Path $script:MyInvocation.MyCommand.Path
}