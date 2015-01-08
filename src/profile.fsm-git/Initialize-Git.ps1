<#
.SYNOPSIS
Configures your local git installation to make things work nicely.

.DESCRIPTION
This script will configure your username, email address, setup some nice defaults and configure 'git-credential-winstore.exe' to handle your authentication to the server.

.EXAMPLE
.\build
You can just call the build script and this will excute with all the defaults.

.PARAMETER name
This is your full name as you would like it displayed, ex. 'John Smith'

.PARAMETER email
You full email address, ex. 'jsmith@gmail.com'
#>
Function Initialize-Git ( [string] $name = $(throw "A name is required"), [string] $email = $(throw "An email address is required")) {
    git config --global user.name $name
    git config --global user.email $email

    #tells git-branch and git-checkout to setup new branches so that git-pull(1)
    #will appropriately merge from that remote branch.  Recommended.  Without this,
    #you will have to add --track to your branch command or manually merge remote
    #tracking branches with "fetch" and then "merge".
    git config --global branch.autosetupmerge true
    git config --global apply.whitespace nowarn
    
    & "$POWERSHELLHOME\Installs\git-credential-winstore.exe"
}