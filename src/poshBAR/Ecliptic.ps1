function Invoke-Ecliptic ( [string] $testDir ) {
    Add-ToolToPath 'ecliptic'
    exec { Ecliptic.exe $testDir } ($msgs.error_specflow_generation -f $testDir)
}