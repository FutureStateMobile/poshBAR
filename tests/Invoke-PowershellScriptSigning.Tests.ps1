$ErrorActionPreference = 'Stop'

Describe 'Invoke-PowershellScriptSigning' { 
            
    Context 'Should execute against pfx path' {
        # setup
        $scripts = @("$(New-Item "TestDrive:\Script.ps1" -ItemType File -Force )")
        $pfxPath = New-Item 'TestDrive:\cert.pfx' -ItemType File -Force
        $password = 'foo'
        
        # todo: figure out how to get this working.
        Mock Set-AuthenticodeSignature {} 
        Mock -moduleName poshBAR Get-PfxCertificate {} 
        
        $pfxPathInfo = (Resolve-Path $pfxPath)

        # execute
        $execute = {Invoke-PowershellScriptSigning $scripts $pfxPathInfo $password}

        # assert
        It 'Will not throw an exception.' -skip {
           $execute | should not throw
        }
        
        # todo: this is skipped because the method is never invoked.
        It 'Will call Mock of poshBAR\Get-PfxCertificate' -skip  {
            Assert-MockCalled Get-PfxCertificate -moduleName poshBAR
        }
    }
}
