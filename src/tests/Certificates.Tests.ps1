$ErrorActionPreference = 'Stop'
$here = Split-Path $script:MyInvocation.MyCommand.Path

Describe 'SSL Certificates' { 
    
    BeforeAll {
        $pth = $env:PATH
        if(! ($env:PATH.Contains('openssl'))){
            $pathToOpenSSL = Resolve-Path "$here\..\..\Tools\OpenSSL\bin"
            $env:PATH += ";$pathToOpenSSL"
        }
    }
    
    AfterAll {
        $env:PATH = $pth
    }
   
    Context 'Will create a Private Key' {
        # setup
        $name = 'pk-cert'
        $password = (ConvertTo-SecureString 'somePassword' -AsPlainText -Force)
        $subject = '/CN=test-pk'
        $out = New-Item 'TestDrive:\testDir1' -ItemType Directory -Force
        
        # execute
        $result = New-PrivateKey $name $password $subject $out
        
        # assert
        It 'Should not return null' {
            $result | should not BeNullOrEmpty
        }
        
        It 'Should have the expected path returned' {
            $result.path | should be $out.FullName
        }
        
        It 'Should have the expected key name returned' {
            $result.key | should be "$($name).key"
        }
        
        It 'Should have the expected crt name returned'{
            $result.name | should be "$name"
        }
        
        It 'Should have the expected name returned' {
            $result.subject | should be $subject
        }
        
        It 'Should have a .key file on the path' {
            (Test-Path "$out\$($name).key") | should be $true
        }
    }

    Context 'Will create all 4 Certificates in a Chain using the combined method (New-PrivateKeyAndCertificateSigningRequest)' {
        # setup
        $name = 'test-cert'
        $password = (ConvertTo-SecureString 'password' -AsPlainText -Force)
        $subject = '/CN=test-foo'
        $out = New-Item 'TestDrive:\testDir2' -ItemType Directory -Force
        
        # execute
        $result = New-PrivateKeyAndCertificateSigningRequest $name $password $subject $out -verbose | New-Certificate -verbose | New-PfxCertificate -password $password -verbose
        
        # assert
        It 'Should have a .key file on the path' {
            (Test-Path "$out\$($name).key") | should be $true
            $result.path | should be "$out"
            $result.key | should be "$($name).key"
        }
        
        It 'Should have a .crt file on the path' {
            (Test-Path "$out\$($name).crt") | should be $true
            $result.path | should be "$out"
            $result.crt | should be "$($name).crt"
        }
        
        It 'Should have a .csr file on the path' {
            (Test-Path "$out\$($name).csr") | should be $true
            $result.path | should be "$out"
            $result.csr | should be "$($name).csr"
        }
        
        It 'Should have a .pfx file on the path' {
            (Test-Path "$out\$($name).pfx") | should be $true
            $result.path | should be "$out"
            $result.pfx | should be "$($name).pfx"
        }
        
        It 'Should not have a .cvg file on the path' {
            (Test-Path "$out\$($name).cvg") | should be $false
        }
    }
}