$ErrorActionPreference = 'Stop'

Describe 'Install-WindowsFeatures' { 
    
    Context 'Should enable a windows feature.' {
        # setup
        $windowsFeatures = @('TFTP')
        Mock -moduleName poshBAR Invoke-ExternalCommand {}
        
        # execute
        $execute = {Install-WindowsFeatures $windowsFeatures}
        
        # assert
        It 'Will execute the DISM command.' {
            . $execute
            Assert-MockCalled Invoke-ExternalCommand -moduleName poshBAR -Exactly 1
        }
    }
    
    Context 'Should prevent enabling feature.' {
        # setup
        $poshBAR.DisableWindowsFeaturesAdministration = $true
        $windowsFeatures = @('TFTP')
        Mock -moduleName poshBAR Invoke-ExternalCommand {}
        
        # execute
        $execute = {Install-WindowsFeatures $windowsFeatures}
        
        # assert
        It 'Will not execute the DISM command.' {
            . $execute
            Assert-MockCalled Invoke-ExternalCommand -moduleName poshBAR -Exactly 0
        }
    }
            
    Context 'Should enable a windows feature.' {
        # setup
        $windowsFeatures = @('IIS-THISFEATUREDOESNTEXIST?')

        # execute
        $execute = {Install-WindowsFeatures $windowsFeatures}

        # assert
        It 'Will not throw an exception on optional feature'   {
            $execute | Should Not Throw
        }
    }
    
    Context 'Should throw on invalid feature.' {
        # setup
        $poshBAR.DisableWindowsFeaturesAdministration = $true
        $windowsFeatures = @('Foo-Bar-Feature')
        Mock -moduleName poshBAR Invoke-ExternalCommand {}
        
        # execute
        $execute = {Install-WindowsFeatures $windowsFeatures}
        
        # assert
        It 'Will throw an exception on an invalid feature.' {
            $execute | Should Throw
        }
    }
    
    Context 'Should throw on empty feature array.' {
        # setup
        $poshBAR.DisableWindowsFeaturesAdministration = $true
        $windowsFeatures = @()
        Mock -moduleName poshBAR Invoke-ExternalCommand {}
        
        # execute
        $execute = {Install-WindowsFeatures $windowsFeatures}
        
        # assert
        It 'Will throw an exception on an empty array.' {
            $execute | Should Throw
        }
    }
    
    Context 'Should throw on null feature array.' {
        # setup
        $poshBAR.DisableWindowsFeaturesAdministration = $true
        Mock -moduleName poshBAR Invoke-ExternalCommand {}
        
        # execute
        $execute = {Install-WindowsFeatures}
        
        # assert
        It 'Will throw an exception on an null array.' {
            $execute | Should Throw
        }
    }
}
