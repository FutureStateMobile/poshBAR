$ErrorActionPreference = 'Stop'

Describe 'Install Windows Features' { 
    
    BeforeAll {
        # Setup Mocks
        Mock Write-Host {} -ModuleName poshBar # just prevents verbose output during tests.
        Mock -moduleName poshBAR Get-WindowsFeatures {return @{'Fake-WindowsFeature' = 'disabled' }}
        Mock -moduleName poshBAR Invoke-ExternalCommand {}
    }
    
    Context 'Will enable a windows feature.' {
        # setup
        $windowsFeatures = @('Fake-WindowsFeature')
        
        # execute
        Install-WindowsFeatures $windowsFeatures
        
        # assert
        It 'Should execute the DISM command.' {
            Assert-MockCalled Invoke-ExternalCommand -moduleName poshBAR -Exactly 1
        }
        
        It 'Should execute the Get-WindowsFeatures cmdlet' {
            Assert-MockCalled Get-WindowsFeatures -moduleName poshBar
        }
    }
    
    Context 'Will prevent enabling a Windows Feature when DisableWindowsFeaturesAdministration is set to true.' {
        # setup
        $poshBAR.DisableWindowsFeaturesAdministration = $true
        $windowsFeatures = @('Fake-WindowsFeature')
        
        # execute
        $execute = {Install-WindowsFeatures $windowsFeatures}
        
        # assert
        It 'Should throw an exception' {
            $execute | should throw $($poshBAR.msgs.error_windows_features_admin_disabled -f 'Fake-WindowsFeature')
        }
        
        It 'Should not execute the DISM command.' {
            Assert-MockCalled Invoke-ExternalCommand -moduleName poshBAR -Exactly 0
        }
        
        It 'Should execute the Get-WindowsFeatures cmdlet' {
            Assert-MockCalled Get-WindowsFeatures -moduleName poshBar
        }
    }
            
    Context 'Will skip but not fail when attepting to enable an optional feature.' {
        # setup
        $windowsFeatures = @('SomeOptionalFeature?')
        Mock Write-Warning {} -moduleName poshBAR
        
        # execute
        $execute = {Install-WindowsFeatures $windowsFeatures}

        # assert
        It 'Should not throw an exception on optional feature'   {
            $execute | Should Not Throw
        }
                
        It 'Should execute the Get-WindowsFeatures cmdlet' {
            Assert-MockCalled Get-WindowsFeatures -moduleName poshBar
        }
        
        It 'Should write a warning message to the console' {
            Assert-MockCalled Write-Warning -moduleName poshBAR
        }
    }
    
    Context 'Will throw on invalid feature.' {
        # setup
        $poshBAR.DisableWindowsFeaturesAdministration = $true
        $windowsFeatures = @('Foo-Bar-Feature')
        
        # execute
        $execute = {Install-WindowsFeatures $windowsFeatures}
        
        # assert
        It 'Should throw an exception on an invalid feature.' {
            $execute | Should Throw $($poshBAR.msgs.error_invalid_windows_feature -f 'Foo-Bar-Feature', '')
        }
    }
    
    Context 'Will throw on empty feature array.' {
        # setup
        $poshBAR.DisableWindowsFeaturesAdministration = $true
        $windowsFeatures = @()
        
        # execute
        $execute = {Install-WindowsFeatures $windowsFeatures}
        
        # assert
        It 'Should throw an exception on an empty array.' {
            $execute | Should Throw
        }
    }
    
    Context 'Will throw on null feature array.' {
        # setup
        $poshBAR.DisableWindowsFeaturesAdministration = $true
        
        # execute
        $execute = {Install-WindowsFeatures}
        
        # assert
        It 'Should throw an exception on an null array.' {
            $execute | Should Throw
        }
    }
}
