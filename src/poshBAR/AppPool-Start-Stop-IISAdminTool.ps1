<#
    .DESCRIPTION
        Start-Stop an AppPool in IIS via the IISAdminTool.

    .EXAMPLE
        Start-Stop-AppPool "http://IISAdminToolUrl" "AppPool_Javascript_href"

    .EXAMPLE
        Start-Stop-AppPool "http://dinf03555.inet.dev.ad/iisadmintool/AppPools.aspx" "javascript:__doPostBack`(`'ctl00`$ContentPlaceHolder1`$dgServerWebSite`$ctl02`$ctl01`'`,`'`'`)" 

    .PARAMETER IISAdminTool url
        The url for the IISAdminTool of the application pool.

    .PARAMETER AppPoolName
        The App pool to start and stop.  
		
    .SYNOPSIS
        Will start or stop  Application Pool for an IIS Application.
#>
function Start-Stop-AppPool() {
    [CmdletBinding()]
    param( 
        [parameter(Mandatory=$true,position=0)] [string]  [alias('env')] $environment,
        [parameter(Mandatory=$true,position=1)] [System.Xml.XmlElement] [alias('ws')] $websiteSettings,
        [parameter(Mandatory=$true,position=2)] [ValidatePattern('^([0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3})(\.[0-9]*?)?')] [string] [alias('v')] $version
    )   
	$iisAdminToolUrl = "$($websiteSettings.iisAdminToolUrl)"
    $AppPool="$($websiteSettings.appPoolName)"
  
    #Stop App Pool
    $ie = new-object -com internetexplorer.application
	$ie.visible=$true
	$ie.navigate($iisAdminToolUrl)
	do { Start-Sleep -m 100 } while ( $ie.ReadyState -ne 4 )
    $link=$ie.Document.getElementsByTagName("a") | Where-Object    { ($_.innerText -eq "Stop")  -and ($_.parentNode.nextSibling.innerText  -eq "$AppPool") }
	$link.click()
    $ie.Quit()
    
    #Start App Pool
    $ie = new-object -com internetexplorer.application
	$ie.visible=$true
	$ie.navigate($iisAdminToolUrl)
	do { Start-Sleep -m 100 } while ( $ie.ReadyState -ne 4 )
    $link=$ie.Document.getElementsByTagName("a") | Where-Object    { ($_.innerText -eq "Start")  -and ($_.parentNode.nextSibling.nextSibling.innerText  -eq "$AppPool") }
	$link.click()
}