$ErrorActionPreference = 'Stop'

Describe 'Application Pool Administration' {
    
    BeforeAll {
        Mock Write-Host {} -ModuleName poshBAR
    }
    
    Context 'Will create a new application pool.' {
        # setup
        Mock Confirm-AppPoolExists {return $false} -ModuleName poshBAR
        Mock Invoke-ExternalCommand {} -ModuleName poshBAR
        Mock Update-AppPool {} -ModuleName poshBAR
        Mock Write-Warning {} -ModuleName poshBAR
        $appPoolName = 'SomeAppPool'
        
        # execute
        New-AppPool $appPoolName
        
        # assert
        It 'Will create a new Application Pool.' {
            Assert-MockCalled Invoke-Externalcommand -ModuleName poshBAR -Exactly 1
        }
        
        It 'Will not call Update-AppPool.' {
            Assert-MockCalled Update-AppPool -ModuleName poshBAR -Exactly 0
        }
        
        It 'Will not call Write-Warning.' {
            Assert-MockCalled Write-Warning -ModuleName poshBAR -Exactly 0
        }
    }
    
    Context 'Will prevent creating a new application pool when DisableCreateIISApplicationPool is set to true.' {
        # setup
        $poshBAR.DisableCreateIISApplicationPool = $true
        Mock Confirm-AppPoolExists {return $false} -ModuleName poshBAR
        Mock Invoke-ExternalCommand {} -ModuleName poshBAR
        Mock Update-AppPool {} -ModuleName poshBAR
        Mock Write-Warning {} -ModuleName poshBAR
        $appPoolName = 'SomeAppPool'
        
        # execute
        New-AppPool $appPoolName
        
        # assert
        It 'Will not create a new Application Pool.' {
            Assert-MockCalled Invoke-Externalcommand -ModuleName poshBAR -Exactly 0
        }
        
        It 'Will not call Update-AppPool.' {
            Assert-MockCalled Update-AppPool -ModuleName poshBAR -Exactly 0
        }
        
        It 'Will write a warning to the console.' {
            Assert-MockCalled Write-Warning -ModuleName poshBAR -Exactly 1
        }
        
        # teardown
        $poshBAR.DisableCreateIISApplicationPool = $false
    }
    
    Context 'Will not create a new Application Pool, but instead update an existing one.' {
        # setup
        Mock Confirm-AppPoolExists {return $true} -ModuleName poshBAR
        Mock Invoke-ExternalCommand {} -ModuleName poshBAR
        Mock Update-AppPool {} -ModuleName poshBAR
        Mock Write-Warning {} -ModuleName poshBAR
        $appPoolName = 'SomeAppPool'
        
        # execute
        New-AppPool $appPoolName
        
        # assert
        It 'Will not create a new Application Pool.' {
            Assert-MockCalled Invoke-Externalcommand -ModuleName poshBAR -Exactly 0
        }
        
        It 'Will call Update-AppPool.' {
            Assert-MockCalled Update-AppPool -ModuleName poshBAR -Exactly 1
        }
        
        It 'Will write a warning to the console.' {
            Assert-MockCalled Write-Warning -ModuleName poshBAR -Exactly 0
        }
    }
    
    
}