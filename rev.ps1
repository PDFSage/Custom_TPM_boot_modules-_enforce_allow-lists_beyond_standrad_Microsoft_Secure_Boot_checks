<#
.SYNOPSIS
    Replace any custom Secure Boot policy with the Microsoft standard or disable Secure Boot.
#>
[CmdletBinding()]
param(
    [switch]$DisableOnly
)

# ensure running on a UEFI + Secure Boot–capable system
if (-not (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State')) {
    Write-Error 'Secure Boot is not supported on this platform'
    exit 1
}

# ensure SecureBoot module is available
if (-not (Get-Module -ListAvailable -Name SecureBoot)) {
    Write-Error 'SecureBoot module not found; please use your UEFI/BIOS setup to revert policy'
    exit 1
}

Import-Module SecureBoot -ErrorAction Stop

function Replace-SecureBootPolicy {
    $policyPath = Join-Path $env:TEMP 'MicrosoftStandardSecureBoot.bin'
    Export-SecureBootPolicy -FilePath $policyPath -SecureBootPolicy Standard
    Import-SecureBootPolicy -FilePath $policyPath -SecureBootPolicy Standard
    Write-Output 'Replaced custom Secure Boot policy with Microsoft standard'
}

if ($DisableOnly) {
    Disable-SecureBootUEFI -Confirm:$false
    Write-Output 'Secure Boot has been disabled'
    exit 0
}

Replace-SecureBootPolicy
