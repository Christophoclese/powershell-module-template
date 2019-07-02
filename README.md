# ModuleTemplate
PowerShell Module template project

### Usage
You should be able to clone this project, make a copy of it, modify `.\build_config.ps1` and you're off to the races! 

#### Local Testing
For testing new changes to your project use `.\Test-Module.ps1`. This will create a local copy of the **ModuleName** specified in `.\build_config.ps1`, appending '-test' to the module's name.  

#### Publishing
To publish your changes use `.\Publish-Module.ps1`. Ensure that the PSRepository specified in `.\build_config.ps1` exists and is reachable.
