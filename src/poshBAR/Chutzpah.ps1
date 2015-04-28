function Invoke-Chutzpah ( [string] $testDirectory) {
    Add-ToolToPath 'chutzpah'
    exec { chutzpah.console.exe /path $testDirectory /teamcity /coverage } ($msgs.error_chutzpah -f $testDirectory)
}