function Invoke-Chutzpah ( [string] $testDirectory) {
    Find-ToolPath 'chutzpah'
    exec { chutzpah.console.exe /path $testDirectory /teamcity /coverage } ($msgs.error_chutzpah -f $testDirectory)
}