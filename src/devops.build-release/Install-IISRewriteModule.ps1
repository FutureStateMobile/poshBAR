function Install-IISRewriteModule(){
 param( 
        [parameter(Mandatory=$true,position=0)] [string] $currentDir
 )  
  Write-Host "Installing IIS Rewrite module"
  if (!(Test-Path "$env:programfiles\Reference Assemblies\Microsoft\IIS\Microsoft.Web.Iis.Rewrite.dll")) {
    $wc = New-Object System.Net.WebClient  
    $dest = "$currentDir\IISRewrite.msi"  
    $url = "http://go.microsoft.com/?linkid=9722532"
    $wc.DownloadFile($url, $dest)  
    msiexec.exe /i $dest /passive
    Write-Host "Installation IIS Rewrite Module complete"
    Write-Host "Installation IIS Application Rewrite Module complete"
    $url2 = "http://download.microsoft.com/download/3/4/1/3415F3F9-5698-44FE-A072-D4AF09728390/ARRv2_setup_x64.EXE"
    $dest2 = "$currentDir\ARRv2_setup_x64.EXE"
    $wc.DownloadFile($url2, $dest2)
    & $dest2 /Q
    Set-WebConfigurationProperty system.webServer/proxy -Name enabled -Value "True"
    Write-Host "Installation IIS Application Rewrite Module complete"
  } else {
    Write-Host "IIS Rewrite Module - Already Installed..." -ForegroundColor Green  
  }
}
