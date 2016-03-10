$ErrorActionPreference = 'Stop'

Describe "Get Value From Nuspec" { 

    BeforeAll {

        # Setup 
        $nuspec= @"
<package>
    <metadata>
        <id>SomeId</id>
        <version>1.0.0.100</version>
        <owners>Acme Corp</owners>
        <releaseNotes>Some Release notes</releaseNotes>
        <copyright>Copywrite (c) 2015 Acme Corp</copyright>
    </metadata>
</package>
"@
            $nuspecPath= Join-Path $TestDrive "app.nuspec"
            Set-Content -Path $nuspecPath -value $nuspec
    }
    
    Context "Gets version from nuspec file"  {

        It "should return version from nuspec file" {

            # Execute 
            $version = Get-ValueFromNuspec $nuspecPath "version"
           
            # Assert
            $version | Should be "1.0.0.100"
        }
    } 

    Context "Gets id from nuspec file"  {

        It "should return id from nuspec file" {

            # Execute 
            $id = Get-ValueFromNuspec $nuspecPath "id"
           
            # Assert
            $id | Should be "SomeId"
        }
    } 
}
