$ErrorActionPreference = 'Stop'

Describe "Get Version From Nuspec" { 
    
    Context "Gets version from nuspec file"  {

        It "should return version from nuspec file" {
            # Setup 
            $nuspec= @"
<package>
    <metadata>
        <version>1.0.0.100</version>
        <owners>Acme Corp</owners>
        <releaseNotes>Some Release notes</releaseNotes>
        <copyright>Copywrite (c) 2015 Acme Corp</copyright>
    </metadata>
</package>
"@
            $nuspecPath= Join-Path $TestDrive "app.nuspec"
            Set-Content -Path $nuspecPath -value $nuspec

            # Execute 
            $actual = Get-VersionFromNuspec $nuspecPath
           
            # Assert
            $($actual) | Should be "1.0.0.100"
        }
    } 
}
