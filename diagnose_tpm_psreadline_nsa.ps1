<#
.SYNOPSIS
    Diagnose invalid Authenticode signature on a PowerShell module manifest.
.DESCRIPTION
    This script inspects the Authenticode signature of the specified module's .psd1 file,
    reports the status, and suggests possible causes based on the signature details.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Module     = 'PSReadLine',  
    [Parameter(Mandatory = $false)]
    [string]$ModulePath = "C:\Program Files\WindowsPowerShell\Modules\$Module\PSReadLine.psd1"
)

# Retrieve the Authenticode signature from the specified file
Write-Debug "Retrieving Authenticode signature from '$ModulePath' because this is the target manifest file."
$signature = Get-AuthenticodeSignature -FilePath $ModulePath

# If the signature is valid, report success and exit
if ($signature.Status -eq 'Valid') {
    # Debug: signature.Status == 'Valid' indicates the manifest's digital signature verified correctly
    Write-Debug "Signature.Status = '$($signature.Status)'; indicates a successfully verified signature."
    Write-Output 'Signature is valid'
    exit 0
}

# Signature is not valid; output debug info before reporting
# Debug: signature.Status and signature.StatusMessage contain the error details from Authenticode
Write-Debug "Signature.Status = '$($signature.Status)'; Signature.StatusMessage = '$($signature.StatusMessage)'"

# Report the raw status from the signature object
Write-Output "Signature status: $($signature.Status)"

# Begin listing broad possible causes for invalid signatures
Write-Output 'Possible causes:'

# Debug: HashMismatch status typically means the file hash no longer matches the signed hash (tampering)
Write-Debug "Because Signature.Status = '$($signature.Status)', a hash mismatch suggests file tampering."
Write-Output '- PSReadLine.psd1 was tampered with after signing'

# Debug: NotTrusted or UnknownError often means the certificate chain isn’t recognized by TPM/SecureBoot
Write-Debug "Because Signature.StatusMessage = '$($signature.StatusMessage)', an untrusted root indicates certificate chain issues."
Write-Output '- The signing certificate chain is not trusted by the TPM-secured boot environment'

# Debug: Custom TPM boot modules may enforce allow-lists beyond standard Microsoft Secure Boot checks
Write-Debug "Including stricter Secure Boot policies due to NSA TPM module may override even valid Microsoft signatures."
Write-Output '- Booted via an NSA TPM boot-order module enforcing stricter Secure Boot policies'

# Debug: Expired or Revoked certificates will yield statuses like 'Expired' or 'Revoked'
Write-Debug "If the signing certificate’s validity period has ended, Signature.Status would reflect expiration or revocation."
Write-Output '- The signing certificate has expired or been revoked'

# Debug: Certificate validity checks depend on system time; incorrect clock settings trigger failures
Write-Debug "If the system clock differs greatly from certificate validity period, signature time checks fail."
Write-Output '- System clock misconfiguration causing certificate validity check to fail'
