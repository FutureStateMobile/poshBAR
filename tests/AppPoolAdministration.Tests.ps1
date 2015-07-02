$ErrorActionPreference = 'Stop'

Describe 'Application Pool Administration - Add Application Pools' {
    
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
        It 'Should create a new Application Pool.' {
            Assert-MockCalled Invoke-Externalcommand -ModuleName poshBAR -Exactly 1
        }
        
        It 'Should not call Update-AppPool.' {
            Assert-MockCalled Update-AppPool -ModuleName poshBAR -Exactly 0
        }
        
        It 'Should not call Write-Warning.' {
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
        It 'Should not create a new Application Pool.' {
            Assert-MockCalled Invoke-Externalcommand -ModuleName poshBAR -Exactly 0
        }
        
        It 'Should not call Update-AppPool.' {
            Assert-MockCalled Update-AppPool -ModuleName poshBAR -Exactly 0
        }
        
        It 'Should write a warning to the console.' {
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
        New-AppPool $appPoolName -updateIfFound
        
        # assert
        It 'Should not create a new Application Pool.' {
            Assert-MockCalled Invoke-Externalcommand -ModuleName poshBAR -Exactly 0
        }
        
        It 'Should call Update-AppPool.' {
            Assert-MockCalled Update-AppPool -ModuleName poshBAR -Exactly 1
        }
        
        It 'Should write a warning to the console.' {
            Assert-MockCalled Write-Warning -ModuleName poshBAR -Exactly 0
        }
    }
    
    Context 'Will not create or update an Application Pool.' {
        # setup
        Mock Confirm-AppPoolExists {return $true} -ModuleName poshBAR
        Mock Invoke-ExternalCommand {} -ModuleName poshBAR
        Mock Update-AppPool {} -ModuleName poshBAR
        Mock Write-Warning {} -ModuleName poshBAR
        $appPoolName = 'SomeAppPool'
        
        # execute
        New-AppPool $appPoolName # -updateIfFound is not present
        
        # assert
        It 'Should not create a new Application Pool.' {
            Assert-MockCalled Invoke-Externalcommand -ModuleName poshBAR -Exactly 0
        }
        
        It 'Should call Update-AppPool.' {
            Assert-MockCalled Update-AppPool -ModuleName poshBAR -Exactly 0
        }
        
        It 'Should write a warning to the console.' {
            Assert-MockCalled Write-Warning -ModuleName poshBAR -Exactly 0
        }
    }
}

Describe 'Application Pool Administration - Update Application Pools' { 
    Context 'Will update an application pool.' {
        # setup
        Mock Confirm-AppPoolExists {return $true} -ModuleName poshBAR
        Mock Invoke-ExternalCommand {} -ModuleName poshBAR
        Mock Write-Warning {} -ModuleName poshBAR
        $appPoolName = 'SomeAppPool'
        
        # execute
        Update-AppPool $appPoolName
        
        # assert
        It 'Should create a new Application Pool.' {
            Assert-MockCalled Invoke-Externalcommand -ModuleName poshBAR -Exactly 1
        }
        
        It 'Should not call Write-Warning.' {
            Assert-MockCalled Write-Warning -ModuleName poshBAR -Exactly 0
        }
    }
    
    Context 'Will not update an invalid application pool.' {
        # setup
        Mock Confirm-AppPoolExists {return $false} -ModuleName poshBAR
        Mock Invoke-ExternalCommand {} -ModuleName poshBAR
        Mock Write-Warning {} -ModuleName poshBAR
        $appPoolName = 'SomeAppPool'
        
        # execute
        Update-AppPool $appPoolName
        
        # assert
        It 'Should create a new Application Pool.' {
            Assert-MockCalled Invoke-Externalcommand -ModuleName poshBAR -Exactly 0
        }
        
        It 'Should not call Write-Warning.' {
            Assert-MockCalled Write-Warning -ModuleName poshBAR -Exactly 1
        }
    }
}