###Powershell Build & Release###

poshBAR is a library of powershell scripts designed to aid in the build & release cycle of a .NET application.

###Using poshBAR###

Install via [NuGet](https://www.nuget.org/packages/poshBAR) (*recommended)

    > Install-Package poshBAR
    
Download the [zip](../../archive/master.zip)

Clone the repository

    > git clone git@github.com:FutureStateMobile/poshBAR.git

-----

###Wiki###

 - For more information, please see our [GitHub Wiki](../../wiki)


###API Documentation###

  - Detailed API documentation can be found in [GitHub Pages](https://futurestatemobile.github.io/poshBAR/)
  - Or you can build the documentation yourself
  
     > .\build.ps1 docs

###Dependencies###
  
  - [psake](https://github.com/psake/psake) (for builds)
    - psake isn't *required* but it is the recommended tool for builds. poshBAR doesn't use psake directly, but instead simplifies your build process. 
  - [NuGet.CommandLine](https://github.com/NuGet/NuGet.CommandLine) (for generating nupkg's)
    - again, nuget isn't *required* per-se, but if you're doing deployments with a tool like [Octopus](http://octopusdeploy.com), you'll need to deliver your artifacts in `nupkg` form.
  - [XmlTransform](https://github.com/Novakov/xmltransform) (for xml transforms)
    - during the deployment process, you'll probably want to simplify your config updates by running xml tranforms. This is the dependency for that.

###License###

[Microsoft Public License (Ms-PL)](http://www.microsoft.com/en-us/openness/licenses.aspx#MPL)
