$ErrorActionPreference = 'Stop'

Describe 'Web Health Checks' {
    
    BeforeAll {
        Mock Write-Host {} -ModuleName poshBAR
    }
    
    Context 'Will create a Mock Http Web Request' {
        # setup
        Mock CustomWebRequest {
            return @{
                Code = '200'
                Message = 'OK'
                Success = $true
            }
        } -ModuleName poshBAR
        
        $request = @{
            uri = 'http://foo'
            verbs = 'GET', 'PUT', 'POST', 'DELETE'
            postData = "{'foo': 'bar'}"
            contentType = 'application/javascript'
            timeout = 5
            customHeaders = @{
                'someKey' = 'someVal'
            }
        }
        $expectedStatusCode = '200 OK'
        $expectedSuccess = $true
        
        # execute
        $execute = { Invoke-WebHealthCheck $request }
        $result = . $execute
        
        # assert
        It 'Should execute the CustomWebRequest cmdlet 2 times.' {
            Assert-MockCalled CustomWebRequest -ModuleName poshBAR -exactly $request.verbs.Count
        }
        
        It 'Should return a hashtable of appropriate data.' {
            $result.Count | Should Be 4
            $result.status | Should Be $expectedStatusCode
            $result.success | Should Be $expectedSuccess
        }
    }
    
    Context 'Will create an actual HTTP GET request and expect a 200 OK.' {
        # setup
        $uri = 'http://httpstat.us/200'
        $request = @{ uri = $uri; verbs = 'GET','PUT','POST','DELETE'}
        $expectedStatusCode = '200 OK'
        $expectedSuccess = $true
        
        # execute
        $result = Invoke-WebHealthCheck $request 
        
        # assert
        It 'Should return a hashtable of appropriate data.' {
            $result.Count | Should Be 4
            $result.status | Should Be $expectedStatusCode
            $result.success | Should Be $expectedSuccess
        }
    }
    
    Context 'Will create an actual HTTP GET request and expect a 301 Moved Permanently.' {
        # setup
        $uri = 'http://httpstat.us/301'
        $expectedStatusCode = '301 MovedPermanently'
        $expectedSuccess = $true
        $request = @{ uri = $uri; verbs = 'GET','PUT','POST','DELETE'}
        
        # execute
        $execute = { Invoke-WebHealthCheck $request } 
        $result = . $execute
        # assert
        It 'Should return a hashtable of appropriate data.' {
            $result.Count | Should Be 4
            $result.status | Should Be $expectedStatusCode
            $result.success | Should Be $expectedSuccess
        }
    }
    
    Context 'Will create an actual HTTP GET request and expect a 404 Not Found.' {
        # setup
        $uri = 'http://httpstat.us/404'
        $request = @{ uri = $uri; verbs = 'GET','PUT','POST','DELETE'}
        $expectedStatusCode = '404 Not Found'
        $expectedSuccess = $false
        
        # execute
        $execute = { Invoke-WebHealthCheck $request } 
        $result = . $execute
        
        # assert
        It 'Should return a hashtable of appropriate data.' {
            $result.Count | Should Be 4
            $result.status | Should Be $expectedStatusCode
            $result.success | Should Be $expectedSuccess
        }
    }
    
    Context 'Will create an actual HTTP GET request and expect a 500 Internal Server Error.' {
        # setup
        $uri = 'http://httpstat.us/500'
        $request = @{ uri = $uri; verbs = 'GET','PUT','POST','DELETE'}
        $expectedStatusCode = '500 Internal Server Error'
        $expectedSuccess = $false
        
        # execute
        $execute = { Invoke-WebHealthCheck $request } 
        $result = . $execute
        
        # assert
        It 'Should return a hashtable of appropriate data.' {
            $result.Count | Should Be 4
            $result.status | Should Be $expectedStatusCode
            $result.success | Should Be $expectedSuccess
        }
    }
    
    Context 'Will ensure the first example runs as expected.' {
        # setup
        $example = { Invoke-WebHealthCheck 'https://www.google.ca' 'GET' }
        $expectedStatusCode = '200 OK'
        $expectedSuccess = $true
        
        # execute
        [array]$result = . $example
        
        # assert
        It 'Should return a hashtable of appropriate data.' {
            $result.Count | Should Be 1
            $result.status | Should Be $expectedStatusCode
            $result.success | Should Be $expectedSuccess
        }
    }
    
    Context 'Will ensure the second example runs as expected.' {
        # setup
        $example = { Invoke-WebHealthCheck @{uri = 'https://www.google.ca'; verbs = 'GET'} }
        $expectedStatusCode = '200 OK'
        $expectedSuccess = $true
        
        # execute
        [array]$result = . $example
        
        # assert
        It 'Should return a hashtable of appropriate data.' {
            $result.Count | Should Be 1
            $result.status | Should Be $expectedStatusCode
            $result.success | Should Be $expectedSuccess
        }
    }
} 