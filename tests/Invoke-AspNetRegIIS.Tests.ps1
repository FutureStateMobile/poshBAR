$ErrorActionPreference = 'Stop'

Describe 'Invoke-AspNetRegIIS.ps1' { 
    BeforeAll {
        # Setup Mocks
        Mock Write-Host {} -ModuleName poshBar # just prevents verbose output during tests.
        Mock Invoke-ExternalCommand {} -moduleName poshBAR
    }
    
    Context 'Will prevent execution when "DisableASPNETRegIIS" is set to "true".' {
        # setup
        Mock Write-Warning {} -moduleName poshBAR
        $poshBAR.DisableASPNETRegIIS = $true
        
        # execute
        Invoke-AspNetRegIIS 
        
        # assert
        It 'Will prevent installing ASP.NET.' {
            Assert-MockCalled Write-Warning -moduleName poshBAR -Exactly 1
        }
        
        It 'Will have DisableASPNETRegIIS set to true' {
             $poshBAR.DisableASPNETRegIIS | should be $true
        }
        
        # teardown
        $poshBAR.DisableASPNETRegIIS = $false
    }
    
    Context 'Invoke aspnet_regiis with defaults.'{
        # setup
        $4_0Path = if($ENV:PROCESSOR_ARCHITECTURE -eq 'amd64'){ "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319" } else { "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319" }
        
        # execute
        $execute = { Invoke-AspNetRegIIS }
        $result = . $execute        
        
        # assert
        It 'Will use the appropriate -iur switch.' {
            $result.switch | should be '-iur'
        }
        
        It 'Will use the appropriate path to aspnet_regiis.exe.' {
            $result.path | should be $4_0Path
        }
        
        It 'Will invoke aspnet_regiis.exe via EXEC {} command' {
            Assert-MockCalled Invoke-ExternalCommand -moduleName poshBAR -Exactly 1
        }
    }
    
    Context 'Invoke aspnet_regiis -i.'{
        # setup
        
        # execute
        $execute = {Invoke-AspNetRegIIS -i}
        $result = . $execute        
        
        # assert
        It 'Will use the appropriate -i switch.' {
            $result.switch | should be '-i'
        }
        
        It 'Will invoke aspnet_regiis.exe via EXEC {} command' {
            Assert-MockCalled Invoke-ExternalCommand -moduleName poshBAR -Exactly 1
        }
    }
    
    Context 'Invoke aspnet_regiis -ir.'{
        # setup
        
        # execute
        $execute = {Invoke-AspNetRegIIS -ir}
        $result = . $execute        
        
        # assert
        It 'Will use the appropriate -ir switch.' {
            $result.switch | should be '-ir'
        }
        
        It 'Will invoke aspnet_regiis.exe via EXEC {} command' {
            Assert-MockCalled Invoke-ExternalCommand -moduleName poshBAR -Exactly 1
        }
    }
    
    Context 'Invoke aspnet_regiis -iur.'{
        # setup
        
        # execute
        $execute = {Invoke-AspNetRegIIS -iur}
        $result = . $execute        
        
        # assert
        It 'Will use the appropriate -iur switch.' {
            $result.switch | should be '-iur'
        }
        
        It 'Will invoke aspnet_regiis.exe via EXEC {} command' {
            Assert-MockCalled Invoke-ExternalCommand -moduleName poshBAR -Exactly 1
        }
    }
    
    Context 'Will use aspnet_regiis.exe for .NET 2.0'{
        # setup
        $2_0Path = if($ENV:PROCESSOR_ARCHITECTURE -eq 'amd64'){ "$env:WINDIR\Microsoft.NET\Framework64\v2.0.50727" } else { "$env:WINDIR\Microsoft.NET\Framework\v2.0.50727" }
        
        # execute
        $execute = {Invoke-AspNetRegIIS -Framework 2.0}
        $result = . $execute        
        
        # assert
        It 'Will use the appropriate path to aspnet_regiis.' {
            $result.path | should be $2_0Path
        }
    }
    
    Context 'Will use aspnet_regiis.exe for .NET 3.0'{
        # setup
        $3_0Path = if($ENV:PROCESSOR_ARCHITECTURE -eq 'amd64'){ "$env:WINDIR\Microsoft.NET\Framework64\v2.0.50727" } else { "$env:WINDIR\Microsoft.NET\Framework\v2.0.50727" }
        
        # execute
        $execute = {Invoke-AspNetRegIIS -Framework 3.0}
        $result = . $execute        
        
        # assert
        It 'Will use the appropriate path to aspnet_regiis.' {
            $result.path | should be $3_0Path
        }
    }
    
    Context 'Will use aspnet_regiis.exe for .NET 3.5'{
        # setup
        $3_5Path = if($ENV:PROCESSOR_ARCHITECTURE -eq 'amd64'){ "$env:WINDIR\Microsoft.NET\Framework64\v2.0.50727" } else { "$env:WINDIR\Microsoft.NET\Framework\v2.0.50727" }
        
        # execute
        $execute = {Invoke-AspNetRegIIS -Framework 3.5}
        $result = . $execute        
        
        # assert
        It 'Will use the appropriate path to aspnet_regiis.' {
            $result.path | should be $3_5Path
        }
    }
    
    Context 'Will use aspnet_regiis.exe for .NET 4.0'{
        # setup
        $4_0Path = if($ENV:PROCESSOR_ARCHITECTURE -eq 'amd64'){ "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319" } else { "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319" }
        
        # execute
        $execute = {Invoke-AspNetRegIIS -Framework 4.0}
        $result = . $execute        
        
        # assert
        It 'Will use the appropriate path to aspnet_regiis.' {
            $result.path | should be $4_0Path
        }
    }
    
    Context 'Will throw an exception when aspnet_regiis cannot be found.' {
        # setup
        Mock Get-PathToAspNetRegIIS {return 'C:\Foo\Bar'} -moduleName poshbar
        
        # execute
        $execute = { Invoke-AspNetRegIIS }
        
        # assert
        It 'Will throw $msgs.error_aspnet_regiis_not_found exception.' {
            $execute | should throw $poshBAR.msgs.error_aspnet_regiis_not_found
        }
    }
}