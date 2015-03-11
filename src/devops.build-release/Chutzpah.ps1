function Invoke-Chutzpah ( [string] $testDirectory) {
    exec { chutzpah.console.exe /path $testDirectory /teamcity /coverage } ($msgs.error_chutzpah -f $testDirectory)
}