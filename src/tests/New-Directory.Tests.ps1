$ErrorActionPreference = 'Stop'

Describe "New Directory" { 
    
    Context "Creates a new directory"  {

        It "should create a new directory" {
            # Setup 
            $path= Join-Path $TestDrive "foo\abc"

            # Execute 
            New-Directory $path 

            # Assert
            Test-Path $path
        }
    } 
}
