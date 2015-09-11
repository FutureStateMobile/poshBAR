<#
    .DESCRIPTION
        Chutzpah is an open source JavaScript test runner which enables you to run unit tests using QUnit, Jasmine, Mocha, CoffeeScript and TypeScript.
    
    .EXAMPLE
        Invoke-Chutzpah 'C:\Dev\MyApp\src'
            
    .PARAMETER testDirectory
        The directory to start the tests from.
        
    .SYNOPSIS
        Run's the Chutzpah javascript test tool over a specified directory
    
    .NOTES
        This module depends on the 'Find-ToolPath' module.
        todo: This should be expanded to take switch parameters for 'teamcity' and 'coverage'
        
    .LINK
        https://github.com/mmanela/chutzpah
            
    .LINK
        https://github.com/mmanela/chutzpah/wiki
    
    .LINK
        Find-ToolPath
#>
function Invoke-Chutzpah {
    [CmdletBinding()]
    param(
        [parameter( Mandatory=$true, Position=0)] [string] $testDirectory
    )
    Find-ToolPath 'chutzpah.console.exe'
    exec { chutzpah.console.exe /path $testDirectory /teamcity /coverage } ($msgs.error_chutzpah -f $testDirectory)
}