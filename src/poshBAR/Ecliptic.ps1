<#
    .SYNOPSIS
        Generates Specflow Features from Excel spreadsheets
    
    .PARAMETER testDir
        The directory containing test case spreadsheets
        
    .EXAMPLE
        Invoke-Ecliptic 'C:/dev/myProject/src/myProject.Tests/'
    
    .EXAMPLE
        ecliptic 'C:/dev/myProject/src/myProject.Tests/'
         
    .NOTES
        This tools required Ecliptic to be availble within your project or $env:PATH
    
    .LINK
        https://github.com/jonathanmccracken/ecliptic

#>
function Invoke-Ecliptic {
    [CmdletBinding()]
    param([string] $testDir)
    
    Find-ToolPath 'ecliptic'
    exec { Ecliptic.exe $testDir } ($msgs.error_specflow_generation -f $testDir)
}
Set-Alias ecliptic Invoke-Ecliptic