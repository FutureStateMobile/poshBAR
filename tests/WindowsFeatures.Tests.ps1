$ErrorActionPreference = 'Stop'

Describe 'Install-WindowsFeatures' { 
    
    BeforeAll {
        # Setup Mocks
        Mock -moduleName poshBAR Get-WindowsFeatures {return @{'Fake-WindowsFeature' = 'disabled' }}
        Mock -moduleName poshBAR Invoke-ExternalCommand {}
    }
    
    Context 'Should enable a windows feature.' {
        # setup
        $windowsFeatures = @('Fake-WindowsFeature')
        
        # execute
        Install-WindowsFeatures $windowsFeatures
        
        # assert
        It 'Will execute the DISM command.' {
            Assert-MockCalled Invoke-ExternalCommand -moduleName poshBAR -Exactly 1
        }
        
        It 'Will execute the Get-WindowsFeatures cmdlet' {
            Assert-MockCalled Get-WindowsFeatures -moduleName poshBar
        }
    }
    
    Context 'Should prevent enabling a Windows Feature when DisableWindowsFeaturesAdministration is set to true.' {
        # setup
        $poshBAR.DisableWindowsFeaturesAdministration = $true
        $windowsFeatures = @('Fake-WindowsFeature')
        
        # execute
        $execute = {Install-WindowsFeatures $windowsFeatures}
        
        # assert
        It 'Will throw an exception' {
            $execute | should throw $($poshBAR.msgs.error_windows_features_admin_disabled -f 'Fake-WindowsFeature')
        }
        
        It 'Will not execute the DISM command.' {
            Assert-MockCalled Invoke-ExternalCommand -moduleName poshBAR -Exactly 0
        }
        
        It 'Will execute the Get-WindowsFeatures cmdlet' {
            Assert-MockCalled Get-WindowsFeatures -moduleName poshBar
        }
    }
            
    Context 'Should skip but not fail when attepting to enable an optional feature.' {
        # setup
        $windowsFeatures = @('SomeOptionalFeature?')
        Mock Write-Warning {} -moduleName poshBAR
        
        # execute
        $execute = {Install-WindowsFeatures $windowsFeatures}

        # assert
        It 'Will not throw an exception on optional feature'   {
            $execute | Should Not Throw
        }
                
        It 'Will execute the Get-WindowsFeatures cmdlet' {
            Assert-MockCalled Get-WindowsFeatures -moduleName poshBar
        }
        
        It 'Will write a warning message to the console' {
            Assert-MockCalled Write-Warning -moduleName poshBAR
        }
    }
    
    Context 'Should throw on invalid feature.' {
        # setup
        $poshBAR.DisableWindowsFeaturesAdministration = $true
        $windowsFeatures = @('Foo-Bar-Feature')
        
        # execute
        $execute = {Install-WindowsFeatures $windowsFeatures}
        
        # assert
        It 'Will throw an exception on an invalid feature.' {
            $execute | Should Throw $($poshBAR.msgs.error_invalid_windows_feature -f 'Foo-Bar-Feature', '')
        }
    }
    
    Context 'Should throw on empty feature array.' {
        # setup
        $poshBAR.DisableWindowsFeaturesAdministration = $true
        $windowsFeatures = @()
        
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
        
        # execute
        $execute = {Install-WindowsFeatures}
        
        # assert
        It 'Will throw an exception on an null array.' {
            $execute | Should Throw
        }
    }
}
