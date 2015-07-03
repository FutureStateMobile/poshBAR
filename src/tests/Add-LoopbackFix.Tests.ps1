$ErrorActionPreference = 'Stop'

Describe 'Add Loopback Fix' {
    BeforeAll {
        Mock Write-Host {} -ModuleName poshBAR
    }
    
    Context 'Will add a loopback fix for a specified domain name.' {
        # setup
        Mock Get-ItemProperty {return @{'BackConnectionHostNames' = 'foo'}} -ModuleName poshBAR
        Mock Set-ItemProperty {} -ModuleName poshBAR  
        Mock New-ItemProperty {} -ModuleName poshBAR  
        $name = 'http://foo.bar.com'
        
        # execute
        $execute = {Add-LoopbackFix $name} 
        
        # assert
        It 'Should not throw an exception when adding a domain name to the BackConnectionHostNames registry.' {
            $execute | Should Not Throw
        }
        
        It 'Should call Set-ItemProperty' {
             Assert-MockCalled Set-ItemProperty -ModuleName poshBAR -Exactly 1
        }
        
        It 'Should not call New-ItemProperty' {
             Assert-MockCalled New-ItemProperty -ModuleName poshBAR -Exactly 0
        }
    }
    
    Context 'Will add a loopback fix for a specified domain name when no registry entry exists.' {
        # setup
        Mock Get-ItemProperty {return $null} -ModuleName poshBAR
        Mock Set-ItemProperty {} -ModuleName poshBAR  
        Mock New-ItemProperty {} -ModuleName poshBAR  
        $name = 'http://foo.bar.com'
        
        # execute
        $execute = {Add-LoopbackFix $name} 
        
        # assert
        It 'Should not throw an exception when adding a domain name to the BackConnectionHostNames registry.' {
            $execute | Should Not Throw
        }
        
        It 'Should not call Set-ItemProperty' {
             Assert-MockCalled Set-ItemProperty -ModuleName poshBAR -Exactly 0
        }
        
        It 'Should call New-ItemProperty' {
             Assert-MockCalled New-ItemProperty -ModuleName poshBAR -Exactly 1
        }
    }
    
    Context 'Will not add a loopback fix when "DisableLoopbackFix" is set to "true"' {
        # setup
        Mock Write-Warning {} -ModuleName poshBAR  
        Mock Get-ItemProperty {} -ModuleName poshBAR
        Mock Set-ItemProperty {} -ModuleName poshBAR  
        Mock New-ItemProperty {} -ModuleName poshBAR  
        $poshBAR.DisableLoopbackFix = $true
        $name = 'http://foo.bar.com'
        
        # execute
        Add-LoopbackFix $name 
        
        # assert
        It 'Should write a warning to the console if DisableLoopbackFix is set to true' {
             Assert-MockCalled Write-Warning -ModuleName poshBAR -Exactly 1
        }
        
        It 'Should not call Get-ItemProperty' {
             Assert-MockCalled Get-ItemProperty -ModuleName poshBAR -Exactly 0
        }
        
        It 'Should not call Set-ItemProperty' {
             Assert-MockCalled Set-ItemProperty -ModuleName poshBAR -Exactly 0
        }
        
        It 'Should not call New-ItemProperty' {
             Assert-MockCalled New-ItemProperty -ModuleName poshBAR -Exactly 0
        }
        
        # teardown
        $poshBAR.DisableLoopbackFix = $false
    }
} 