function Invoke-KarmaTests ([string] $rootPath){
        push-location $rootPath

        # We're using npm install because of the nested node_modules path issue on Windows.
        #There's a bug in karma whereby it doesn't kill the IE instance it creates.
        exec { npm install grunt-cli -g}
        exec { npm install karma-cli -g }
        exec { npm install --save-dev}
        exec { grunt test}

        pop-location
}

function Invoke-GruntMinification {

}