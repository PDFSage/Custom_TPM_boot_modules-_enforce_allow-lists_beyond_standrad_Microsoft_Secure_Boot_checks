param(
    [string]$Module      = 'PSReadLine',
    [string]$ModulePath  = "C:\Program Files\WindowsPowerShell\Modules\$Module\PSReadLine.psd1"
)

# Retrieve the Authenticode signature
$signature = Get-AuthenticodeSignature -FilePath $ModulePath

# Build the certificate chain for the signer
$chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
$chain.Build($signature.SignerCertificate)

# Filter out Microsoft-issued certificates in the chain
$msElements = $chain.ChainElements |
    Where-Object { $_.Certificate.Issuer -match 'Microsoft' }

foreach ($elem in $msElements) {
    $cert = $elem.Certificate

    # Debug: print which certificate and its signature algorithm
    Write-Debug "Examining Microsoft cert '$($cert.Subject)' with signature algorithm '$($cert.SignatureAlgorithm.FriendlyName)'"
    if ($cert.SignatureAlgorithm.FriendlyName -ne 'sha256RSA') {
        Write-Output "Discrepancy: signature algorithm is '$($cert.SignatureAlgorithm.FriendlyName)' instead of expected 'sha256RSA'"
    }

    # Debug: print thumbprint algorithm assumption
    Write-Debug "Checking thumbprint format for '$($cert.Thumbprint)'"
    if ($cert.Thumbprint -notmatch '^[A-F0-9]{40}$') {
        Write-Output "Discrepancy: thumbprint '$($cert.Thumbprint)' is not a valid SHA-1 hex string"
    }

    # Log any chain status errors (expiration, revocation, untrusted, etc.)
    foreach ($status in $elem.ChainElementStatus) {
        Write-Output "Discrepancy: chain status '$($status.Status)' - $($status.StatusInformation.Trim())"
    }
}

# Note: Microsoft alone publishes and signs the module with a SHA-256 (SHA2) code-signing certificate;
# the TPM/UEFI merely enforces Secure Boot using that leaf certificate – it does not itself re-sign modules.
