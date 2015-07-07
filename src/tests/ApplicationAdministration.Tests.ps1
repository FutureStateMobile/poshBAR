$ErrorActionPreference = 'Stop'

Describe 'Application Administration Tests' {
	BeforeAll {
		Mock Write-Host {} -ModuleName poshBAR
		$applicationName = 'foo.application.com'
		$applicationPath = 'TestDrive:\FooApplication'
		$bindings = @{"protocol" = "http"; "port" = 80; "hostName"="foo.application.com"}
		$appPoolName = 'foo.application.com'
	}
	Context 'Will create a new IIS Web Application.' {
		# setup
		Mock Update-Application {} -ModuleName poshBAR
		Mock Invoke-ExternalCommand {} -ModuleName poshBAR
		Mock Confirm-ApplicationExists { return $false } -ModuleName poshBAR
		
		# execute
		$execute = { New-Application $applicationName $applicationPath $bindings $appPoolName }
		
		# assert
		It 'Should not throw an exception when creating a new webapplication' {
			$execute | Should Not Throw
		}
		
		It 'Should create the application and then update the application pool second.' {
			Assert-MockCalled Invoke-ExternalCommand -ModuleName poshBAR -Exactly 2
		}
		
		It 'Should not call Update-Application' {
			Assert-MockCalled Update-Application -ModuleName poshBAR -Exactly 0
		}
	}
	
	Context 'Will call Update-Application if the application already exists and the -updateIfFound flag is $true.' {
		# setup
		Mock Update-Application {} -ModuleName poshBAR
		Mock Invoke-ExternalCommand {} -ModuleName poshBAR
		Mock Confirm-ApplicationExists { return $true } -ModuleName poshBAR
		$updateIfFound = $true
		
		# execute
		$execute = { New-Application $applicationName $applicationPath $bindings $appPoolName -UpdateIfFound:$updateIfFound }
		
		# assert
		It 'Should not throw an exception when creating a new webapplication' {
			$execute | Should Not Throw
		}
		
		It 'Should not create a new webapplication.' {
			Assert-MockCalled Invoke-ExternalCommand -ModuleName poshBAR -Exactly 0
		}
		
		It 'Should call Update-Application' {
			Assert-MockCalled Update-Application -ModuleName poshBAR -Exactly 1
		}
	}
	
	Context 'Will do nothing if the application already exists and the -updateIfFound flag is $false.' {
		# setup
		Mock Update-Application {} -ModuleName poshBAR
		Mock Invoke-ExternalCommand {} -ModuleName poshBAR
		Mock Confirm-ApplicationExists { return $true } -ModuleName poshBAR
		$updateIfFound = $false
		
		# execute
		$execute = { New-Application $applicationName $applicationPath $bindings $appPoolName -UpdateIfFound:$updateIfFound }
		
		# assert
		It 'Should not throw an exception when creating a new webapplication' {
			$execute | Should Not Throw
		}
		
		It 'Should not create a new webapplication.' {
			Assert-MockCalled Invoke-ExternalCommand -ModuleName poshBAR -Exactly 0
		}
		
		It 'Should not call Update-Application' {
			Assert-MockCalled Update-Application -ModuleName poshBAR -Exactly 0
		}
	}
	
	Context 'Will not allow creating a webapplication if DisableCreateIISWebapplication is set to true' {
		# setup
		$poshBAR.DisableCreateIISApplication = $true
		Mock Update-Application {} -ModuleName poshBAR
		Mock Invoke-ExternalCommand {} -ModuleName poshBAR
		Mock Confirm-ApplicationExists { return $false } -ModuleName poshBAR
		$updateIfFound = $false
		
		# execute
		$execute = { New-Application $applicationName $applicationPath $bindings $appPoolName -UpdateIfFound:$updateIfFound }
		
		# assert
		It 'Should throw an exception when creating a new webapplication' {
			$execute | Should Throw $poshBAR.msgs.error_webapplication_creation_disabled
		}
		
		It 'Should not create a new webapplication.' {
			Assert-MockCalled Invoke-ExternalCommand -ModuleName poshBAR -Exactly 0
		}
		
		It 'Should not call Update-Application' {
			Assert-MockCalled Update-Application -ModuleName poshBAR -Exactly 0
		}	
		
		# teardown
		$poshBAR.DisableCreateIISWebapplication = $false
	}
}