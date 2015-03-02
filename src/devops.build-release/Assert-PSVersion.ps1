function Assert-PSVersion{
  [CmdletBinding()]
  param(
      [Parameter(Mandatory=$true)][ValidateRange(2,4)][int] $requiredVersion
  )
  $moduleName = (Get-PSCallStack)[1].Command

   $PSVersionTable.PSVersion | % {
        if($_.Major -lt $requiredVersion){
             Write-Host "ERROR: You are running an incompatable version of Powershell." -f Red
             Write-Host "A newer version of Powershell can be found at " -nonewline
             Write-Host "http://www.microsoft.com/en-us/download/details.aspx?id=40855&WT.mc_id=rss_alldownloads_all" -f cyan
             Write-Host "Or by installing through Chocolatey `(" -nonewline
             Write-Host "http://chocolatey.org" -f Cyan -nonewline
             Write-Host ")."
             Write-Host "`t> choco install Powershell" -f Cyan
             Write-Host "After installing Powershell, you may need to reboot your computer."
             throw "Powershell V.$requiredVersion is required to use $moduleName."
        }
   }
}