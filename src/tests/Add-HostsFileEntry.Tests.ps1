$ErrorActionPreference = 'Stop'

Describe 'Add Hosts File Entry' { 
    BeforeAll {
        Mock Write-Host {} -ModuleName poshBar # just prevents verbose output during tests.
        Mock Add-Content -ModuleName poshBAR
        Mock Get-Content { $false } -ModuleName poshBAR   
    }
    
    Context 'Will add a custom domanin name to the host file.'{
        # Setup
        $hostName = 'my-temp-hostname.com'
        
        # Execute
        Add-HostsFileEntry $hostName 
        
        # Assert
        It 'Should call Add-Content' {
            Assert-MockCalled Add-Content -ModuleName poshBAR
        }
        
        It 'Should call Get-Content' {
            Assert-MockCalled Get-Content -ModuleName poshBAR -Exactly 2
        }
    }
   
    Context 'Will add a custom domanin name to the host file and include a loopback fix.'{
        # Setup
        $hostName = 'my-temp-hostname.com'
        Mock Add-LoopbackFix {} -ModuleName poshBAR
        
        # Execute
        Add-HostsFileEntry $hostName -includeLoopbackFix
        
        # Assert
        It 'Should call Add-LoopbackFix' {
            Assert-MockCalled Add-LoopbackFix -ModuleName poshBAR
        }
    }
    
    Context 'Will disable adding a host file entry when DisableHostFileAdministration is set to true' {
        # Setup
        $poshBAR.DisableHostFileAdministration = $true
        $hostName = 'my-temp-hostname.com'
        Mock Write-Warning -moduleName poshBAR
        
        # Execute
        Add-HostsFileEntry $hostName 
        
        # Assert
        It 'Should not call Add-Content' {
            Assert-MockCalled Add-Content -ModuleName poshBAR -Exactly 0
        }
        
        It 'Should write a warning message out to the console.' {
            Assert-MockCalled Write-Warning -ModuleName poshBAR -Exactly 1
        }
        
        It 'Should call Get-Content' {
            Assert-MockCalled Get-Content -ModuleName poshBAR -Exactly 2
        }
    }
}
