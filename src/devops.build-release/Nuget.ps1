function New-NugetPackage{
	param(
		[parameter(Mandatory=$true, Position=0)][string] $nuspecFile,
        [parameter(Mandatory=$true, Position=1)][string] $version,
        [parameter(Mandatory=$true, Position=2)][string] $outputDirectory
	)

	exec { NuGet.exe Pack $nuspecFile -Version $version -OutputDirectory $outputDirectory -NoPackageAnalysis } "Failed to package $nuspecFile."
}