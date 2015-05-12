<#
    .SYNOPSIS
        Uses Grunt and Karma to test javascript
        
    .DESCRIPTION    
        Uses Grunt and Karma to test javascript
        
    .PARAMETER rootPath
        The path to the grunt file
    
    .EXAMPLE
        Invoke-KarmaTests "C:\Dev\myApp\src\myApp.Website"
        
    .LINK
        https://karma-runner.github.io/0.12/index.html
        
    .LINK 
        http://gruntjs.com/
#>
function Invoke-KarmaTests {
    [CmdletBinding()]
    param(
        [string] $rootPath
    )

    push-location $rootPath

    # We're using npm install because of the nested node_modules path issue on Windows.
    #There's a bug in karma whereby it doesn't kill the IE instance it creates.
    exec { npm install grunt-cli -g}
    exec { npm install karma-cli -g }
    exec { npm install --save-dev}
    exec { grunt test}

    pop-location
}