$ErrorActionPreference = 'Stop'

Describe 'poshBAR module tests' {

    Context 'Will ensure the version and build number were properly updated during the build.' {
        # setup
        
        # execute
        
        # assert
        It 'Should have a matching version' {
            $poshBAR.version | should be $version
        }
        
        It 'Should have a matching build number' {
            $poshBAR.buildNumber | should be $buildNumber
        }
    }

} 