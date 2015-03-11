function Invoke-Ecliptic ( [string] $testDir ) {
    exec { Ecliptic.exe $testDir } ($msgs.error_specflow_generation -f $testDir)
}