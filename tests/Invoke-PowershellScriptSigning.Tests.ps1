$ErrorActionPreference = 'Stop'

Describe 'Invoke-PowershellScriptSigning' { 
    
    Mock Set-AuthenticodeSignature {exit 0} 
    Mock -moduleName poshBAR Get-PfxCertificate {} 
        
    Context 'Should execute against pfx path' {
        # setup
        $scripts = @("$env:TEMP\script.ps1")
        $pfxPath = "$env:TEMP\cert.pfx"
        $password = 'foo'
        
        Set-Content $pfxPath -value 'foo'
        $scripts | % {Set-Content $_ -value 'bar' }
        
        $pfxPathInfo = (Resolve-Path $pfxPath)
        
        # execute
        $execute = {Invoke-PowershellScriptSigning $scripts $pfxPathInfo $password}

        # assert
        It 'Will not throw an exception.'  {
           $execute | should not throw
        }
        
        It 'Will call Mock of poshBAR\Get-PfxCertificate'   {
            Assert-MockCalled Get-PfxCertificate -moduleName poshBAR
        }
    }
}
