$ErrorActionPreference = "Stop"

<#
    .SYNOPSIS
        Installs a web application Source and backup into Archives Folder.
    
    .DESCRIPTION
        This is a helper method used to simplify the installation of a web application.
    
    .PARAMETER environment
        The environment name that the web application is being installed into. [dev, qual, uat, production]
        
    .PARAMETER websiteSettings
        An XML node defining all of the required XML settings. An example can be found in the repository.
    
    .PARAMETER version
        The version number of the application
        
    .EXAMPLE
        Install-WebApplicationToFolder 'dev' $environmentSettings.websites.myWebsite '1.0.2.1234'
    
    .NOTES
        The environment name should always line up with the environment names listed in your deployment tool (Octopus Deploy)
   

#>
function Install-WebApplicationToFolder() {
    [CmdletBinding()]
    param( 
        [parameter(Mandatory=$true,position=0)] [string]  [alias('env')] $environment,
        [parameter(Mandatory=$true,position=1)] [System.Xml.XmlElement] [alias('ws')] $websiteSettings,
        [parameter(Mandatory=$true,position=2)] [ValidatePattern('^([0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3})(\.[0-9]*?)?')] [string] [alias('v')] $version
    )
    $moduleDir = Split-Path $script:MyInvocation.MyCommand.Path
    # todo: figure out why running 'deploy' vs 'deploy.ps1' causes this bug.
    $baseDir = if($moduleDir.EndsWith('poshBAR')){
        Resolve-Path "$moduleDir\..\.."
    } else {
        Resolve-Path $moduleDir
    }
    
   
    $appFilePath = "$($websiteSettings.physicalPathRoot)\$($websiteSettings.appPath)"
    $archiveroot="$($websiteSettings.physicalPathRoot)\$($websiteSettings.appPath)\Archives"        
    

    # Create Folder for the application
    if(!(Test-Path $($appFilePath))) {
        md $($appFilePath)        
        md $($archiveroot)           
    } else {
        #Remove-Item  -Path "$($appFilePath)\*" -Exclude "*C:\inetpub\icsa-dev.external.transcanada.com\ICSAexternal\Archives\"  -recurse -Force
        write-host "Archive Path: $archiveroot"
        (Get-ChildItem "$($appFilePath)\" -recurse | select -ExpandProperty fullname) | where { $_ -notlike "$archiveroot*"} | sort length -descending | remove-item               
    }

    Write-Host ($msgs.msg_copying_content -f $websiteSettings.siteName, $appFilePath) -NoNewLine
    # copy the website over, but be sure to exclude environment specific web configs.
    Copy-Item "$baseDir\website\*" "$($appFilePath)\" -Exclude 'web.*.config'  -Recurse -Force
    #Backup
    #$current_domainuser=$(Get-WMIObject -class Win32_ComputerSystem | select username).username
    $current_domainuser=whoami
    $current_user=$current_domainuser.split("\")[1]
    $current_date=Get-Date -format "yyyyMMddHHmmss"
    write-Host ("Current Date:$current_date ") -NoNewLine
    write-Host ("Current User:$current_user ") -NoNewLine
    $archiveFilePath="$archiveroot\$($websiteSettings.appPath)-$current_date-$current_user"
    md $($archiveFilePath)
    #Copy New Source Files
    Copy-Item "$baseDir\website\*" "$($archiveFilePath)\" -Exclude 'web.*.config'  -Recurse -Force 
    Write-Host "`tDone" -f Green
    
    $msgs.msg_web_app_success -f $websiteSettings.siteName
}