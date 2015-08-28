<#
    .SYNOPSIS
        Generates a nuget package from a specified nuspec
    
    .PARAMETER nuspecFile
        The nuspec file used to generate the nupkg
        
    .PARAMETER version
        The version of the application being packaged
        
    .PARAMETER outputDirectory
        The location of the generated nupkg file
        
    .NOTES
        Requires `nuget.exe` to be available on your $env:PATH
        Uses Find-ToolPath to try and locate nuget.exe (see Links below)
        
    .LINK
        Find-ToolPath
        
    .LINK
        https://docs.nuget.org/Create/Creating-and-Publishing-a-Package
#>
function New-NugetPackage{
    [CmdletBinding()]
	param(
		[parameter(Mandatory=$true, Position=0)][string] $nuspecFile,
        [parameter(Mandatory=$true, Position=1)][string] $version,
        [parameter(Mandatory=$true, Position=2)][string] $outputDirectory
	)

    Find-ToolPath 'nuget.exe'
	exec { NuGet.exe Pack $nuspecFile -Version $version -OutputDirectory $outputDirectory -NoPackageAnalysis } "Failed to package $nuspecFile."
}
Set-Alias nupack New-NugetPackage