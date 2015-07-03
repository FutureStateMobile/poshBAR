param( [hashtable] $poshBAR )

if ( $OctopusParameters ) { 
    $poshBAR.DisableWindowsFeaturesAdministration = [System.Convert]::ToBoolean($OctopusParameters['poshBAR.DisableWindowsFeaturesAdministration'])
    $poshBAR.DisableChocolateySoftwareInstallation = [System.Convert]::ToBoolean($OctopusParameters['poshBAR.DisableChocolateySoftwareInstallation']) # chocolatey feature to be created.
    $poshBAR.DisableHostFileAdministration = [System.Convert]::ToBoolean($OctopusParameters['poshBAR.DisableHostFileAdministration'])
    $poshBAR.DisableASPNETRegIIS = [System.Convert]::ToBoolean($OctopusParameters['poshBAR.DisableASPNETRegIIS'])
    $poshBAR.DisableLoopbackFix = [System.Convert]::ToBoolean($OctopusParameters['poshBAR.DisableLoopbackFix'])
    $poshBAR.DisableCreateIISApplicationPool = [System.Convert]::ToBoolean($OctopusParameters['poshBAR.DisableCreateIISApplicationPool'])
    $poshBAR.DisableCreateIISWebsite = [System.Convert]::ToBoolean($OctopusParameters['poshBAR.DisableCreateIISWebsite'])
    #$poshBAR.DisableCreateIISApplication = [System.Convert]::ToBoolean($OctopusParameters['poshBAR.DisableCreateIISApplication'])
    
    
}

return $poshBAR