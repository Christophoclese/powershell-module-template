<#  
    .SYNOPSIS
        Publishes the configured module to the configured PSRepository.

    .DESCRIPTION
        Makes a copy of the specified module in .\build. 
        Parses Public function names and adds them to a static list of functions to import in the module manifest.
        Modifies .\MODULE_ROOT\Private\Global-Vars.ps1 to set desired PSRepositoryName
        Publishes module to the specified PSRepository.

    .NOTES
        This should be run in the parent dir of the repo (where it is located).
#>
[CmdletBinding()]
Param(
)

$BUILD_CONFIG_FILENAME = '.\build_config.ps1'
Try {
    . $BUILD_CONFIG_FILENAME
}
Catch {
    Throw "Unable to open build_config"
}

If ($BUILD_CONFIG.ModuleName) {
    $MODULE_NAME = $BUILD_CONFIG.ModuleName
}
Else {
    Write-Error "Unable to find the property 'ModuleName' in $PSScriptRoot\$BUILD_CONFIG_FILENAME" -ErrorAction Stop
}

If ($BUILD_CONFIG.PSRepositoryName) {
    $REPOSITORY_NAME = $BUILD_CONFIG.PSRepositoryName
}
Else {
    Write-Error "Unable to find the property 'PSRepositoryName' in $PSScriptRoot\$BUILD_CONFIG_FILENAME" -ErrorAction Stop
}

# If build folder doesn't exist, create it
If (-not (Test-Path -Path ".\build")) {
    New-Item -Name "build" -Type Directory -ErrorAction Stop | Out-Null
}

# Ensure the build folder is empty
Remove-Item -Path ".\build\*" -Recurse -ErrorAction Stop

# Copy the module contents into the build folder
Copy-Item -Path ".\MODULE_ROOT\" -Destination ".\build\$MODULE_NAME" -Recurse -ErrorAction Stop

Rename-Item -Path ".\build\$MODULE_NAME\Module.psm1" -NewName "$MODULE_NAME.psm1" -ErrorAction Stop
Rename-Item -Path ".\build\$MODULE_NAME\Manifest.psd1" -NewName "$MODULE_NAME.psd1" -ErrorAction Stop

$manifest = Get-Content -Path ".\build\$MODULE_NAME\$MODULE_NAME.psd1" -ErrorAction Stop
$manifest = $manifest -Replace 'Module\.psm1', "$MODULE_NAME.psm1"

# Read in all the public function files, we'll use the basename property to get function names to export
$Public = @( Get-ChildItem -Path ".\build\$MODULE_NAME\Public\*.ps1" -ErrorAction Stop )

If ($Public.Basename) {
    # Build a FunctionsToExport array (as a string) that we'll swap with the default FunctionsToExport = '*'
    $exportString = 'FunctionsToExport = @('
    $Public.Basename | % {
        $exportString += "'$_',"
    }
    $exportString = $exportString.TrimEnd(',')
    $exportString += ')'

    If ($manifest -match "^FunctionsToExport = '\*'") {
        # Replace the default FunctionToExport with our static list
        $manifest = $manifest -Replace "^FunctionsToExport = '\*'", $exportString
    }
    Else {
        Throw "Did not find FunctionsToExport = '*' in order to replace it. Has something changed with the module manifest?"
    }
}

$manifest | Set-Content -Path ".\build\$MODULE_NAME\$MODULE_NAME.psd1" -ErrorAction Stop

$global_vars = Get-Content -Path ".\build\$MODULE_NAME\Private\Global-Vars.ps1" -ErrorAction Stop

If ($global_vars -like '$MODULE_CONFIG.PSRepositoryName = ''''*') {
    Write-Verbose "Trying to rewrite global vars"
    $global_vars = $global_vars -Replace "^\`$MODULE_CONFIG.PSRepositoryName = ''", "`$MODULE_CONFIG.PSRepositoryName = '$REPOSITORY_NAME'"
    $global_vars | Set-Content -Path ".\build\$MODULE_NAME\Private\Global-Vars.ps1" -ErrorAction Stop
}
Else {
    Throw "Did not find $MODULE_CONFIG.PSRepositoryName = '' in order to replace it. Has something changed with .\Private\Global-Vars.ps1?"
}

Publish-Module -Path ".\build\$MODULE_NAME\" -Repository $REPOSITORY_NAME
