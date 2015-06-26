$ErrorActionPreference = 'Stop'

Describe 'Install-WindowsFeatures' { 
    
    Context 'Should enable a windows feature.' {
        # setup
        $windowsFeatures = @('RasRip')
        Mock -moduleName poshBAR Invoke-ExternalCommand {}
        
        # execute
        $execute = {Install-WindowsFeatures $windowsFeatures}
        
        # assert
        It 'Will execute the DISM command.' {
            . $execute
            Assert-MockCalled Invoke-ExternalCommand -moduleName poshBAR -Exactly 1
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
    
    Context 'Should prevent enabling feature.' {
        # setup
        $poshBAR.DisableWindowsFeaturesAdministration = $true
        $windowsFeatures = @('RasRip')
        Mock -moduleName poshBAR Invoke-ExternalCommand {}
        
        # execute
        $execute = {Install-WindowsFeatures $windowsFeatures}
        
        # assert
        It 'Will not execute the DISM command.' {
            . $execute
            Assert-MockCalled Invoke-ExternalCommand -moduleName poshBAR -Exactly 0
        }
    }
}
