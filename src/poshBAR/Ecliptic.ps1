function Invoke-Ecliptic ( [string] $testDir ) {
    Find-ToolPath 'ecliptic'
    exec { Ecliptic.exe $testDir } ($msgs.error_specflow_generation -f $testDir)
}