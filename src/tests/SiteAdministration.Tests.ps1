$ErrorActionPreference = 'Stop'

Describe 'Site Administration Tests' {
	BeforeAll {
		Mock Write-Host {} -ModuleName poshBAR
		$siteName = 'foo.site.com'
		$sitePath = 'TestDrive:\FooSite'
		$bindings = @{"protocol" = "http"; "port" = 80; "hostName"="foo.site.com"}
		$appPoolName = 'foo.site.com'
	}
	Context 'Will create a new IIS Website.' {
		# setup
		Mock Update-Site {} -ModuleName poshBAR
		Mock Invoke-ExternalCommand {} -ModuleName poshBAR
		Mock Confirm-SiteExists { return $false } -ModuleName poshBAR
		
		# execute
		$execute = { New-Site $siteName $sitePath $bindings $appPoolName }
		
		# assert
		It 'Should not throw an exception when creating a new website' {
			$execute | Should Not Throw
		}
		
		It 'Should create the site and then update the application pool second.' {
			Assert-MockCalled Invoke-ExternalCommand -ModuleName poshBAR -Exactly 2
		}
		
		It 'Should not call Update-Site' {
			Assert-MockCalled Update-Site -ModuleName poshBAR -Exactly 0
		}
	}
	
	Context 'Will call Update-Site if the site already exists and the -updateIfFound flag is $true.' {
		# setup
		Mock Update-Site {} -ModuleName poshBAR
		Mock Invoke-ExternalCommand {} -ModuleName poshBAR
		Mock Confirm-SiteExists { return $true } -ModuleName poshBAR
		$updateIfFound = $true
		
		# execute
		$execute = { New-Site $siteName $sitePath $bindings $appPoolName -UpdateIfFound:$updateIfFound }
		
		# assert
		It 'Should not throw an exception when creating a new website' {
			$execute | Should Not Throw
		}
		
		It 'Should not create a new website.' {
			Assert-MockCalled Invoke-ExternalCommand -ModuleName poshBAR -Exactly 0
		}
		
		It 'Should call Update-Site' {
			Assert-MockCalled Update-Site -ModuleName poshBAR -Exactly 1
		}
	}
	
	Context 'Will do nothing if the site already exists and the -updateIfFound flag is $false.' {
		# setup
		Mock Update-Site {} -ModuleName poshBAR
		Mock Invoke-ExternalCommand {} -ModuleName poshBAR
		Mock Confirm-SiteExists { return $true } -ModuleName poshBAR
		$updateIfFound = $false
		
		# execute
		$execute = { New-Site $siteName $sitePath $bindings $appPoolName -UpdateIfFound:$updateIfFound }
		
		# assert
		It 'Should not throw an exception when creating a new website' {
			$execute | Should Not Throw
		}
		
		It 'Should not create a new website.' {
			Assert-MockCalled Invoke-ExternalCommand -ModuleName poshBAR -Exactly 0
		}
		
		It 'Should not call Update-Site' {
			Assert-MockCalled Update-Site -ModuleName poshBAR -Exactly 0
		}
	}
	
	Context 'Will not allow creating a website if DisableCreateIISWebsite is set to true' {
		# setup
		$poshBAR.DisableCreateIISWebsite = $true
		Mock Update-Site {} -ModuleName poshBAR
		Mock Invoke-ExternalCommand {} -ModuleName poshBAR
		Mock Confirm-SiteExists { return $false } -ModuleName poshBAR
		$updateIfFound = $false
		
		# execute
		$execute = { New-Site $siteName $sitePath $bindings $appPoolName -UpdateIfFound:$updateIfFound }
		
		# assert
		It 'Should throw an exception when creating a new website' {
			$execute | Should Throw $poshBAR.msgs.error_website_creation_disabled
		}
		
		It 'Should not create a new website.' {
			Assert-MockCalled Invoke-ExternalCommand -ModuleName poshBAR -Exactly 0
		}
		
		It 'Should not call Update-Site' {
			Assert-MockCalled Update-Site -ModuleName poshBAR -Exactly 0
		}	
		
		# teardown
		$poshBAR.DisableCreateIISWebsite = $false
	}
}