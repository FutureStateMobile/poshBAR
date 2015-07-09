$ErrorActionPreference = 'Stop'

Describe 'Web Health Checks' {
    
    BeforeAll {
        Mock Write-Host {} -ModuleName poshBAR
    }
    
    Context 'Will create a Mock Http Web Request' {
        # setup
        Mock CustomWebRequest {} -ModuleName poshBAR
        $request = @{uri = 'http://foo'; verbs = 'GET', 'PUT';}
        
        # execute
        $execute = { Invoke-WebHealthCheck $request }
        $result = . $execute
        
        # assert
        It 'Should execute the CustomWebRequest cmdlet 2 times.' {
            Assert-MockCalled CustomWebRequest -ModuleName poshBAR -exactly 2 # should be called 2 times because there are 2 separate verbs.
        }
        
        It 'Should return a hashtable of appropriate data' {
            $result.uri | Should Be $request.uri
            $result.verbs | Should Be $request.verbs 
            $result.postData | Should Be '{}'
            $result.contentType | Should Be "application/json"
            $result.customHeaders | Should BeNullOrEmpty 
            $result.totalRequests | Should Be 2
        }
    }
    
    Context 'Will create an actual HTTP GET request and expect a 200 OK.' {
        # setup
        $uri = 'http://httpstat.us/200'
        $request = @{ uri = $uri; verbs = 'GET','PUT','POST','DELETE'}
        
        # execute
        $result = Invoke-WebHealthCheck $request 
        
        # assert
        It 'Should return a hashtable of appropriate data.' {
            $result.uri | Should Be $uri
            $result.verbs | Should Be $request.verbs 
            $result.postData | Should Be '{}'
            $result.contentType | Should Be "application/json"
            $result.customHeaders | Should BeNullOrEmpty 
            $result.totalRequests | Should Be 4
            $result.statusCodes | Should Be '200 OK.'
            $result.status | Should Be 'passed'
        }
    }
    
    Context 'Will create an actual HTTP GET request and expect a 301 Moved Permanently.' {
        # setup
        $uri = 'http://httpstat.us/301'
        $expectedStatusCode = '301 MovedPermanently.'
        $expectedStatus = 'passed'
        $request = @{ uri = $uri; verbs = 'GET','PUT','POST','DELETE'}
        
        # execute
        $execute = { Invoke-WebHealthCheck $request } 
        $result = . $execute
        # assert
        It 'Should return a hashtable of appropriate data.' {
            $result.uri | Should Be $uri
            $result.verbs | Should Be $request.verbs 
            $result.postData | Should Be '{}'
            $result.contentType | Should Be "application/json"
            $result.customHeaders | Should BeNullOrEmpty 
            $result.totalRequests | Should Be 4
            $result.statusCodes | Should Be $expectedStatusCode
            $result.status | Should Be $expectedStatus
        }
    }
    
    Context 'Will create an actual HTTP GET request and expect a 404 Not Found.' {
        # setup
        $uri = 'http://httpstat.us/404'
        $expectedStatusCode = '404 Not Found.'
        $expectedStatus = 'failed'
        $request = @{ uri = $uri; verbs = 'GET','PUT','POST','DELETE'}
        
        # execute
        $execute = { Invoke-WebHealthCheck $request } 
        $result = . $execute
        # assert
        It 'Should return a hashtable of appropriate data.' {
            $result.uri | Should Be $uri
            $result.verbs | Should Be $request.verbs 
            $result.postData | Should Be '{}'
            $result.contentType | Should Be "application/json"
            $result.customHeaders | Should BeNullOrEmpty 
            $result.totalRequests | Should Be 4
            $result.statusCodes | Should Be $expectedStatusCode
            $result.status | Should Be $expectedStatus
        }
    }
    
    Context 'Will create an actual HTTP GET request and expect a 500 Internal Server Error.' {
        # setup
        $uri = 'http://httpstat.us/500'
        $expectedStatusCode = '500 Internal Server Error.'
        $expectedStatus = 'failed'
        $request = @{ uri = $uri; verbs = 'GET','PUT','POST','DELETE'}
        
        # execute
        $execute = { Invoke-WebHealthCheck $request } 
        $result = . $execute
        # assert
        It 'Should return a hashtable of appropriate data.' {
            $result.uri | Should Be $uri
            $result.verbs | Should Be $request.verbs 
            $result.postData | Should Be '{}'
            $result.contentType | Should Be "application/json"
            $result.customHeaders | Should BeNullOrEmpty 
            $result.totalRequests | Should Be 4
            $result.statusCodes | Should Be $expectedStatusCode
            $result.status | Should Be $expectedStatus
        }
    }
} 