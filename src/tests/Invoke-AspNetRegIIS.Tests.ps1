$ErrorActionPreference = 'Stop'

Describe 'Invoke ASP_NET RegIIS' { 
    BeforeAll {
        # Setup Mocks
        Mock Write-Host {} -ModuleName poshBar # just prevents verbose output during tests.
        Mock Invoke-ExternalCommand {} -moduleName poshBAR
    }
    
    Context 'Will prevent execution when "DisableGlobalASPNETRegIIS" is set to "true".' {
        # setup
        Mock Write-Warning {} -moduleName poshBAR
        $poshBAR.DisableGlobalASPNETRegIIS = $true
        
        # execute
        Invoke-AspNetRegIIS -i
        
        # assert
        It 'Should write a warning when attempting to install ASP.NET.' {
            Assert-MockCalled Write-Warning -moduleName poshBAR -Exactly 1
        }
        
        It 'Should have DisableGlobalASPNETRegIIS set to true' {
             $poshBAR.DisableGlobalASPNETRegIIS | should be $true
        }
        
        # teardown
        $poshBAR.DisableGlobalASPNETRegIIS = $false
    }
    
    Context 'Will invoke aspnet_regiis with the -norestart flag' {
        # setup
        
        # execute
        $execute = {Invoke-AspNetRegIIS -i -norestart}
        $result = . $execute    
        
        # assert
        It 'Should add the -norestart switch to the command.' {
            $result.norestart | should be $true
        }
    }
    
    Context 'Will invoke aspnet_regiis against a specified site' {
        # setup
        Mock Get-IisSiteId {return 999} -moduleName poshBar
        $siteName = 'example.site.com'
        
        # execute
        $execute = {Invoke-AspNetRegIIS -s $siteName}
        $result = . $execute    
        
        # assert
        It 'Should return the site name in the output.' {
            $result.siteName | should be $siteName
        }
        
        It 'Should use the appropriate -s switch.' {
            $result.switch | should be '-s'
        }
        
        It 'Should return a sitePath that contains 999.' {
            $result.sitePath | should match 999
        }
        
        It 'Should call the internal method for getting the site ID.' {
            Assert-MockCalled Get-IisSiteId -moduleName poshBAR -Exactly 1
        }
    }
    
    Context 'Will invoke aspnet_regiis -i.'{
        # setup
        
        # execute
        $execute = {Invoke-AspNetRegIIS -i}
        $result = . $execute        
        
        # assert
        It 'Should use the appropriate -i switch.' {
            $result.switch | should be '-i'
        }
        
        It 'Should invoke aspnet_regiis.exe via EXEC {} command' {
            Assert-MockCalled Invoke-ExternalCommand -moduleName poshBAR -Exactly 1
        }
    }
    
    Context 'Will invoke aspnet_regiis -ir.'{
        # setup
        
        # execute
        $execute = {Invoke-AspNetRegIIS -ir}
        $result = . $execute        
        
        # assert
        It 'Should use the appropriate -ir switch.' {
            $result.switch | should be '-ir'
        }
        
        It 'Should invoke aspnet_regiis.exe via EXEC {} command' {
            Assert-MockCalled Invoke-ExternalCommand -moduleName poshBAR -Exactly 1
        }
    }
    
    Context 'Will invoke aspnet_regiis -iru.'{
        # setup
        
        # execute
        $execute = {Invoke-AspNetRegIIS -iru}
        $result = . $execute        
        
        # assert
        It 'Should use the appropriate -iru switch.' {
            $result.switch | should be '-iru'
        }
        
        It 'Should invoke aspnet_regiis.exe via EXEC {} command' {
            Assert-MockCalled Invoke-ExternalCommand -moduleName poshBAR -Exactly 1
        }
    }
    
    Context 'Will use aspnet_regiis.exe for .NET 2.0'{
        # setup
        $2_0Path = if($ENV:PROCESSOR_ARCHITECTURE -eq 'amd64'){ "$env:WINDIR\Microsoft.NET\Framework64\v2.0.50727" } else { "$env:WINDIR\Microsoft.NET\Framework\v2.0.50727" }
        
        # execute
        $execute = {Invoke-AspNetRegIIS -Framework 2.0 -i}
        $result = . $execute        
        
        # assert
        It 'Should use the appropriate path to aspnet_regiis.' {
            $result.path | should be $2_0Path
        }
    }
    
    Context 'Will use aspnet_regiis.exe for .NET 3.0'{
        # setup
        $3_0Path = if($ENV:PROCESSOR_ARCHITECTURE -eq 'amd64'){ "$env:WINDIR\Microsoft.NET\Framework64\v2.0.50727" } else { "$env:WINDIR\Microsoft.NET\Framework\v2.0.50727" }
        
        # execute
        $execute = {Invoke-AspNetRegIIS -Framework 3.0 -i}
        $result = . $execute        
        
        # assert
        It 'Should use the appropriate path to aspnet_regiis.' {
            $result.path | should be $3_0Path
        }
    }
    
    Context 'Will use aspnet_regiis.exe for .NET 3.5'{
        # setup
        $3_5Path = if($ENV:PROCESSOR_ARCHITECTURE -eq 'amd64'){ "$env:WINDIR\Microsoft.NET\Framework64\v2.0.50727" } else { "$env:WINDIR\Microsoft.NET\Framework\v2.0.50727" }
        
        # execute
        $execute = {Invoke-AspNetRegIIS -Framework 3.5 -i}
        $result = . $execute        
        
        # assert
        It 'Should use the appropriate path to aspnet_regiis.' {
            $result.path | should be $3_5Path
        }
    }
    
    Context 'Will use aspnet_regiis.exe for .NET 4.0'{
        # setup
        $4_0Path = if($ENV:PROCESSOR_ARCHITECTURE -eq 'amd64'){ "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319" } else { "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319" }
        
        # execute
        $execute = {Invoke-AspNetRegIIS -Framework 4.0 -i}
        $result = . $execute        
        
        # assert
        It 'Should use the appropriate path to aspnet_regiis.' {
            $result.path | should be $4_0Path
        }
    }
    
    Context 'Will throw an exception when aspnet_regiis cannot be found.' {
        # setup
        Mock Get-PathToAspNetRegIIS {return 'C:\Foo\Bar'} -moduleName poshbar
        
        # execute
        $execute = { Invoke-AspNetRegIIS  -i}
        
        # assert
        It 'Should throw $msgs.error_aspnet_regiis_not_found exception.' {
            $execute | should throw $poshBAR.msgs.error_aspnet_regiis_not_found
        }
    }
}