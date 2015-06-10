$ErrorActionPreference = 'Stop'
$here = Split-Path $script:MyInvocation.MyCommand.Path

Describe 'Certificates' { 
    
    BeforeAll {
        $pth = $env:PATH
        if(! ($env:PATH.Contains('openssl'))){
            $pathToOpenSSL = Resolve-Path "$here\..\Tools\OpenSSL"
            $env:PATH += ";$pathToOpenSSL"
        }
    }
    
    AfterAll {
        $env:PATH = $pth
    }
    
    Context 'Doesn`'t effing break ' {
        $out = New-Item 'TestDrive:\testDir0' -ItemType Directory -Force
        
        push-location $out
        openssl.exe genrsa -passout pass:password -out somefile.key 2048 -subj '/CN=test-junk' -noverify
        pop-location
    }
    
    
    Context 'Private Key' {
        # setup
        $name = 'pk-cert'
        $password = (ConvertTo-SecureString 'somePassword' -AsPlainText -Force)
        $subject = '/CN=test-pk'
        $out = New-Item 'TestDrive:\testDir1' -ItemType Directory -Force
        
        # execute
        $result = New-PrivateKey $name $password $subject $out
        
        # assert
        It 'Will not return null' {
            $result | should not BeNullOrEmpty
        }
        
        It 'Will have the expected path returned' {
            $result.path | should be $out.FullName
        }
        
        It 'Will have the expected key name returned' {
            $result.key | should be "$($name).key"
        }
        
        It 'Will have the expected crt name returned'{
            $result.name | should be "$name"
        }
        
        It 'Will have the expected name returned' {
            $result.subject | should be $subject
        }
        
        It 'Will have a .key file on the path' {
            (Test-Path "$out\$($name).key") | should be $true
        }
    }

    Context 'Create all 4 Certificates in a Chain using the combined method (New-PrivateKeyAndCertificateSigningRequest)' {
        # setup
        $name = 'test-cert'
        $password = (ConvertTo-SecureString 'password' -AsPlainText -Force)
        $subject = '/CN=test-foo'
        $out = New-Item 'TestDrive:\testDir2' -ItemType Directory -Force
        
        # execute
        $result = New-PrivateKeyAndCertificateSigningRequest $name $password $subject $out | New-Certificate | New-PfxCertificate -password $password
        
        # assert
        
        It 'Will have a .key file on the path' {
            (Test-Path "$out\$($name).key") | should be $true
        }
        
        It 'Will have a .crt file on the path' {
            (Test-Path "$out\$($name).crt") | should be $true
        }
        
        It 'Will have a .csr file on the path' {
            (Test-Path "$out\$($name).csr") | should be $true
        }
        
        It 'Will have a .pfx file on the path' {
            (Test-Path "$out\$($name).pfx") | should be $true
        }
        
        It 'Will not have a .cvg file on the path' {
            (Test-Path "$out\$($name).cvg") | should be $false
        }
        
    }
}