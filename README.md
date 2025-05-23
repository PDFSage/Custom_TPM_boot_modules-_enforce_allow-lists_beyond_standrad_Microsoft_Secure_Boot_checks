Of the three parties you mention, it’s overwhelmingly most likely that **Microsoft** is the one enforcing the Secure Boot policy you’re running into—TPM manufacturers ship chips and firmware that simply enforce whatever key‐database your platform firmware is configured with, and the NSA doesn’t generally roll your laptop’s Secure Boot policy for you (unless you bought some super‐specialized “hardened” hardware). Here’s the breakdown:

1. **NSA**

   * Role: Would only intervene if you were running an NSA-distributed custom bootloader or specialized government hardware.
   * Likelihood: Very low for a consumer or corporate box—you almost certainly aren’t using NSA-branded Secure Boot policy.

2. **TPM manufacturer (Intel, AMD, Infineon, etc.)**

   * Role: Provides the TPM chip and firmware hooks, but doesn’t define which signing keys are trusted—those come from the platform’s UEFI firmware configuration.
   * Likelihood: Low; they supply the enforcement engine but not the key database.

3. **Microsoft**

   * Role: Supplies the default Secure Boot key database (the Microsoft UEFI CA and associated Microsoft Windows Production PCA) on most Windows-certified PCs. They also publish signing requirements for PowerShell modules via their Gallery code-signing certificate.
   * Likelihood: Very high—it’s their root keys in the firmware that are being used to validate your PSReadLine module signature.

---

### What Bo can do about it

1. **Inspect your Secure Boot key database**

   * In an elevated PowerShell session run:

     ```powershell
     Get-SecureBootPolicy -FilePath .\SBPolicy.bin
     ```

     Then use the Windows **KeyTool** (`bcdedit /enum {bootmgr} /v` on some systems) or a UEFI utility to dump which certificates and hashes are trusted.
   * Verify that the Microsoft Windows Production PCA (and the PowerShell Gallery signing intermediate) actually appear there.

2. **Install or re-install the PowerShell Gallery code-signing certificate**

   * Download the Microsoft Code Signing PCA from the Gallery (it’s publicly available).
   * Import it into the **UEFI db** (the Secure Boot “db” variable) so that your module’s Authenticode signature chain can be validated:

     ```powershell
     Import-Certificate -FilePath .\Microsoft.PCA.cer -CertStoreLocation Cert:\LocalMachine\TrustedPublisher
     ```
   * Some platforms let you enroll a custom CA into the UEFI db via BIOS/UEFI setup.

3. **Remove or disable any “custom” Secure Boot policy**

   * If your OEM or IT department loaded a custom policy (for instance, to lock the box down even more than Microsoft does), you can

     * Flash back to the **standard Microsoft­-approved policy** via your board vendor’s BIOS update tool, or
     * In the UEFI Setup menu, switch from “Custom” back to “Standard” Secure Boot mode.

4. **Temporarily disable Secure Boot**

   * As a last resort—if you just need PSReadLine working—you can turn Secure Boot off, bootstrap the module, then turn it back on.
   * **Caveat:** This opens you up to other boot-time integrity risks, so only do it if you trust your software source completely.

5. **Check system clock and certificate validity**

   * Ensure your BIOS/OS clock is correct (Secure Boot signature time-checks can fail on skewed clocks).
   * Update Windows and firmware so that any revocation or expiration issues are resolved.

---

By focusing on your firmware’s UEFI Secure Boot policy (almost certainly the Microsoft‐supplied key database) and either enrolling the correct code-signing certificate or reverting to the standard Microsoft policy, you should restore the ability to validate and install PSReadLine without disabling your TPM-backed protections.
Of the three parties you mention, it’s overwhelmingly most likely that **Microsoft** is the one enforcing the Secure Boot policy you’re running into—TPM manufacturers ship chips and firmware that simply enforce whatever key‐database your platform firmware is configured with, and the NSA doesn’t generally roll your laptop’s Secure Boot policy for you (unless you bought some super‐specialized “hardened” hardware). Here’s the breakdown:

1. **NSA**

   * Role: Would only intervene if you were running an NSA-distributed custom bootloader or specialized government hardware.
   * Likelihood: Very low for a consumer or corporate box—you almost certainly aren’t using NSA-branded Secure Boot policy.

2. **TPM manufacturer (Intel, AMD, Infineon, etc.)**

   * Role: Provides the TPM chip and firmware hooks, but doesn’t define which signing keys are trusted—those come from the platform’s UEFI firmware configuration.
   * Likelihood: Low; they supply the enforcement engine but not the key database.

3. **Microsoft**

   * Role: Supplies the default Secure Boot key database (the Microsoft UEFI CA and associated Microsoft Windows Production PCA) on most Windows-certified PCs. They also publish signing requirements for PowerShell modules via their Gallery code-signing certificate.
   * Likelihood: Very high—it’s their root keys in the firmware that are being used to validate your PSReadLine module signature.

---

### What Bo can do about it

1. **Inspect your Secure Boot key database**

   * In an elevated PowerShell session run:

     ```powershell
     Get-SecureBootPolicy -FilePath .\SBPolicy.bin
     ```

     Then use the Windows **KeyTool** (`bcdedit /enum {bootmgr} /v` on some systems) or a UEFI utility to dump which certificates and hashes are trusted.
   * Verify that the Microsoft Windows Production PCA (and the PowerShell Gallery signing intermediate) actually appear there.

2. **Install or re-install the PowerShell Gallery code-signing certificate**

   * Download the Microsoft Code Signing PCA from the Gallery (it’s publicly available).
   * Import it into the **UEFI db** (the Secure Boot “db” variable) so that your module’s Authenticode signature chain can be validated:

     ```powershell
     Import-Certificate -FilePath .\Microsoft.PCA.cer -CertStoreLocation Cert:\LocalMachine\TrustedPublisher
     ```
   * Some platforms let you enroll a custom CA into the UEFI db via BIOS/UEFI setup.

3. **Remove or disable any “custom” Secure Boot policy**

   * If your OEM or IT department loaded a custom policy (for instance, to lock the box down even more than Microsoft does), you can

     * Flash back to the **standard Microsoft­-approved policy** via your board vendor’s BIOS update tool, or
     * In the UEFI Setup menu, switch from “Custom” back to “Standard” Secure Boot mode.

4. **Temporarily disable Secure Boot**

   * As a last resort—if you just need PSReadLine working—you can turn Secure Boot off, bootstrap the module, then turn it back on.
   * **Caveat:** This opens you up to other boot-time integrity risks, so only do it if you trust your software source completely.

5. **Check system clock and certificate validity**

   * Ensure your BIOS/OS clock is correct (Secure Boot signature time-checks can fail on skewed clocks).
   * Update Windows and firmware so that any revocation or expiration issues are resolved.

---

By focusing on your firmware’s UEFI Secure Boot policy (almost certainly the Microsoft‐supplied key database) and either enrolling the correct code-signing certificate or reverting to the standard Microsoft policy, you should restore the ability to validate and install PSReadLine without disabling your TPM-backed protections.
