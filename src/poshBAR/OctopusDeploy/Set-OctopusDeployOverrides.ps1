param( [hashtable] $poshBAR )

if ( $OctopusParameters ) { 
    $poshBAR.DisableWindowsFeaturesAdministration = $OctopusParameters['poshBAR.DisableWindowsFeaturesAdministration']
    $poshBAR.DisableChocolateyInstallationAdministration = $OctopusParameters['poshBAR.DisableChocolateyInstallationAdministration']
    $poshBAR.DisableHostFileAdministration = $OctopusParameters['poshBAR.DisableHostFileAdministration']
}

return $poshBAR