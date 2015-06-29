param( [hashtable] $poshBAR )

if ( $OctopusParameters ) { 
    $poshBAR.DisableWindowsFeaturesAdministration = [System.Convert]::ToBoolean($OctopusParameters['poshBAR.DisableWindowsFeaturesAdministration'])
    $poshBAR.DisableChocolateyInstallationAdministration = [System.Convert]::ToBoolean($OctopusParameters['poshBAR.DisableChocolateyInstallationAdministration'])
    $poshBAR.DisableHostFileAdministration = [System.Convert]::ToBoolean($OctopusParameters['poshBAR.DisableHostFileAdministration'])
}

return $poshBAR