$ErrorActionPreference = 'Stop'
$here = Split-Path $script:MyInvocation.MyCommand.Path

Describe 'ClickOnce' { 
    
    Mock -moduleName poshBAR Invoke-ExternalCommand {} 
    
    Context 'Sign Package' {
        # setup
        $manifestPath = 'foo'
        $pfxPath = 'C:\bar'
        $pfxPassword = 'baz'
            
        # execute
        $execute = {Invoke-SignAppliationManifest $manifestPath $pfxPath $pfxPassword}

        # assert
        It 'Will not throw an exception.' -skip {
           $execute | should not throw
        }
        
        It 'Will call Mock of poshBAR\Invoke-ExternalCommand' -skip {
            Assert-MockCalled Invoke-ExternalCommand -moduleName poshBAR
        }
    }
}
