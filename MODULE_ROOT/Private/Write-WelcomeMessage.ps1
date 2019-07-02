function Write-WelcomeMessage {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Version,

        [Parameter(Mandatory = $true)]
        [string]$Email
    )
    
    Write-Host
    Write-Host "Module " -NoNewLine -ForegroundColor DarkGreen
    Write-Host "$Name ($Version)" -NoNewLine -ForegroundColor Green
    Write-Host " loaded." -ForegroundColor DarkGreen

    Write-Host "Please contact " -NoNewLine -ForegroundColor DarkGreen
    Write-Host "$Email" -NoNewLine -ForegroundColor Green
    Write-Host " with questions." -ForegroundColor DarkGreen
    Write-Host
}
