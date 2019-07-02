$ManifestData = Test-ModuleManifest -Path $PSScriptRoot\*.psd1

#Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
ForEach ($import in @($Public + $Private)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import file $($import.fullname): $_"
    }
}

Find-ModuleUpdate -Name $MODULE_CONFIG.Name -Repository $MODULE_CONFIG.PSRepositoryName

# Export public functions and all aliases to user's session, allowing tab-completion
Export-ModuleMember -Function $Public.Basename -Alias *

Write-WelcomeMessage -Name $MODULE_CONFIG.Name -Version $MODULE_CONFIG.Version -Email $MODULE_CONFIG.ContactEmail
