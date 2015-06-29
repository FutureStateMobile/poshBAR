$ErrorActionPreference = 'Stop'

Describe 'Add-HostsFileEntry' { 
    Mock Add-Content -ModuleName poshBAR
    Mock Get-Content { $false } -ModuleName poshBAR
   
    Context 'Add a custom domanin name to the host file.'{
        # Setup
        $hostName = 'my-temp-hostname.com'
        
        # Execute
        Add-HostsFileEntry $hostName 
        
        # Assert
        It 'Will call Add-Content' {
            Assert-MockCalled Add-Content -ModuleName poshBAR
        }
        
        It 'Will call Get-Content' {
            Assert-MockCalled Get-Content -ModuleName poshBAR -Exactly 2
        }
    }
   
    Context 'Add a custom domanin name to the host file and include a loopback fix.'{
        # Setup
        $hostName = 'my-temp-hostname.com'
        Mock Add-LoopbackFix {} -ModuleName poshBAR
        
        # Execute
        Add-HostsFileEntry $hostName -includeLoopbackFix
        
        # Assert
        It 'Will call Add-LoopbackFix' {
            Assert-MockCalled Add-LoopbackFix -ModuleName poshBAR
        }
    }
    
    Context 'Will no add a host file entry when DisableHostFileAdministration is set to true' {
        # Setup
        $poshBAR.DisableHostFileAdministration = $true
        $hostName = 'my-temp-hostname.com'
        
        # Execute
        Add-HostsFileEntry $hostName 
        
        # Assert
        It 'Will call Add-Content' {
            Assert-MockCalled Add-Content -ModuleName poshBAR -Exactly 0
        }
        
        It 'Will call Get-Content' {
            Assert-MockCalled Get-Content -ModuleName poshBAR -Exactly 2
        }
    }
}
