The error you're encountering (`A parameter cannot be found that matches parameter name 'Enabled'`) occurs because the `Set-SecureBootUEFI` cmdlet does not have an `Enabled` parameter in the version of the module you are using.

The available parameters for `Set-SecureBootUEFI` may vary depending on your system and the version of the module. To resolve the issue, let's inspect the available parameters for `Set-SecureBootUEFI`.

### 1. **Check Available Parameters**

You can inspect the available parameters for the `Set-SecureBootUEFI` cmdlet using the following command:

```powershell
Get-Help Set-SecureBootUEFI -Full
```

This will show all parameters available for `Set-SecureBootUEFI` and how to use them correctly.

### 2. **Example Cmdlet Usage**

If you're trying to enable or disable Secure Boot, the correct syntax typically looks something like this:

```powershell
Set-SecureBootUEFI -Mode Standard
```

or to disable:

```powershell
Set-SecureBootUEFI -Mode Disabled
```

### 3. **Adjust Script According to Parameters**

Make sure your script reflects the correct parameters based on the output from `Get-Help`. For example, if you're aiming to set Secure Boot to the standard Microsoft policy, try:

```powershell
Set-SecureBootUEFI -Mode Standard
```

This command sets the Secure Boot mode to "Standard" (if supported).

### Example Script:

Here’s an example of how you might use the `Set-SecureBootUEFI` cmdlet in your script:

```powershell
# Set Secure Boot to Standard mode
Set-SecureBootUEFI -Mode Standard
Write-Output 'Secure Boot has been set to Standard mode'
```

### 4. **Further Assistance**

If `Set-SecureBootUEFI` still doesn't work as expected, there might be a system-specific limitation, or UEFI settings may need to be configured manually in BIOS. You can also explore the system's UEFI settings to ensure Secure Boot is enabled or configured as needed.
