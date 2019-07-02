<#	
	.SYNOPSIS
		Installs a local copy of the configured module as 'ModuleName-test'

	.DESCRIPTION
		Makes a copy of module configured in build_config.json called 'ModuleName-test'
		in the user's \Documents\WindowsPowerShell\Modules folder.
		Allows for the local testing of unpublished changes.

	.NOTES
		The test module will only be available to the user running this command (not installed globally).
		The ModuleName configured in the build_config.json should match the name and folder of the module in this repo.

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

$TEST_MODULE_NAME = "$MODULE_NAME-test"

# Detect host OS to define correct path.
If ([Environment]::OSVersion.Platform -eq 'Win32NT') {
    $MODULE_PATH = (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders").Personal + '\WindowsPowerShell\Modules'
}
ElseIf ([Environment]::OSVersion.Platform -eq 'Unix') {
    $MODULE_PATH = $Env:HOME + '/.local/share/powershell/Modules'
}
Else {
    # Abort the import of the module if we can't initialize properly
    Write-Error "Unable to determine OS!" -ErrorAction Stop
}

# Remove any currently loaded modules
$MODULE_NAME, $TEST_MODULE_NAME | Remove-Module -ErrorAction SilentlyContinue

If (-not (Test-Path "$MODULE_PATH\$TEST_MODULE_NAME")) {
	Write-Verbose "The path '$MODULE_PATH\$TEST_MODULE_NAME' does not exist. Attempting to create it."
	Try {
		New-Item -Path $MODULE_PATH -Name $TEST_MODULE_NAME -ItemType Directory | Out-Null
	}
	Catch {
		Write-Error "Unable to create the folder '$MODULE_PATH\$TEST_MODULE_NAME'"
		Write-Verbose "The error was: $($_.Exception.Message)"
		Break
	}
}
Else {
	Write-Verbose "The path '$MODULE_PATH\$TEST_MODULE_NAME' already exists."
}

Remove-Item -Path $MODULE_PATH\$TEST_MODULE_NAME\* -Recurse

# Copy the module to the destination
Copy-Item "$PSScriptRoot\MODULE_ROOT\*" -Destination "$MODULE_PATH\$TEST_MODULE_NAME" -Recurse -ErrorAction Stop | Out-Null



# Load the existing manifest file and replace the generic Module.psm1 with $TEST_MODULE_NAME
$manifest = (Get-Content "$MODULE_PATH\$TEST_MODULE_NAME\Manifest.psd1")
$manifest = $manifest -Replace 'Module\.psm1', "$TEST_MODULE_NAME.psm1"
# Replace the test module manifest
$manifest | Out-File "$MODULE_PATH\$TEST_MODULE_NAME\$TEST_MODULE_NAME.psd1" -ErrorAction Stop
Remove-Item -Path "$MODULE_PATH\$TEST_MODULE_NAME\Manifest.psd1"

# Rename the module file too
Rename-Item -Path "$MODULE_PATH\$TEST_MODULE_NAME\Module.psm1" -NewName "$TEST_MODULE_NAME.psm1" -ErrorAction Stop

# Explicitly import the test module
Import-Module $TEST_MODULE_NAME
