<#
    .DESCRIPTION
        Nothing yet...
    
    .EXAMPLE
        Invoke-Chutzpah 'C:\Dev\MyApp\src'
            
    .PARAMETER testDirectory
        The directory to start the tests from.
        
    .SYNOPSIS
        Run's the Chutzpah javascript test tool over a specified directory
    
        
    .NOTES
        todo: This should be expanded to take switch parameters for 'teamcity' and 'coverage'
#>
function Invoke-Chutzpah {
    [CmdletBinding()]
    param(
        [parameter( Mandatory=$true, Position=0)] [string] $testDirectory
    )
    Find-ToolPath 'chutzpah'
    exec { chutzpah.console.exe /path $testDirectory /teamcity /coverage } ($msgs.error_chutzpah -f $testDirectory)
}