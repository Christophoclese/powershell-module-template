function Find-ModuleUpdate {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Repository
    )

    # Check for an updated version available on repository
    Try {
        $installed_version = (Get-InstalledModule -Name $Name -ErrorAction Stop).Version # Should get highest version installed
        Try {
            $repository_version = (Find-Module -Name $Name -Repository $Repository -ErrorAction Stop).Version
            If ($installed_version -lt $repository_version) {
                Write-Host -ForegroundColor Yellow "A new version of $Name ($repository_version) is available."
                Write-Host -ForegroundColor DarkGray "To upgrade, please run:"
                Write-Host -ForegroundColor Gray "Update-Module -Name $Name"
                Write-Host -ForegroundColor Gray "Remove-Module -Name $Name"
                Write-Host -ForegroundColor Gray "Import-Module -Name $Name"
            }
        }
        Catch {
            Write-Warning "Unable to locate $Name in the $Repository PSRepository. Ensure it is configured with: Get-PSRepository -Name '$Repository'"
        }
    }
    Catch {
        Write-Warning "Did not find an installed version of $Name. Are you testing with Test-Module.ps1?"
    }
}
