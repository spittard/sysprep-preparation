# Windows Unattend.xml Configuration Suite

This suite provides a comprehensive solution for Windows unattend.xml configuration with RDP, SSM, admin functionality, and secure password management.

## Files Overview

- `comprehensive-unattend.xml` - Complete unattend.xml with encrypted passwords (for secure environments)
- `cloud-compatible-unattend.xml` - Unattend.xml with plain text passwords (for cloud console compatibility)
- `Validate-UnattendXml.ps1` - PowerShell script to validate unattend.xml syntax and configuration
- `minimal-unattend.xml` - Your original minimal configuration (for reference)

## Features

### Comprehensive Unattend.xml Features

✅ **Remote Desktop (RDP) Configuration**
- Enables Remote Desktop connections
- Configures RDP security settings
- Sets up Windows Firewall rules for RDP
- Enables Network Level Authentication

✅ **System Service Manager (SSM) Support**
- Enables Remote Registry service
- Configures WinRM for remote management
- Enables PowerShell Remoting
- Sets up proper service configurations

✅ **Administrator Account Management**
- Creates and configures Administrator account
- Sets secure passwords
- Enables auto-logon for initial setup
- Disables UAC for easier administration

✅ **Security and System Configuration**
- Configures Windows Firewall
- Disables unnecessary Windows features
- Sets up proper time zones and locales
- Configures Windows Update settings

## Quick Start

### 1. Validate Your Unattend.xml

Before applying any configuration, always validate it first:

```powershell
# Basic validation
.\Validate-UnattendXml.ps1 -UnattendPath "comprehensive-unattend.xml"

# Detailed validation with HTML report
.\Validate-UnattendXml.ps1 -UnattendPath "comprehensive-unattend.xml" -DetailedOutput -GenerateReport
```

### 2. Choose Your Configuration

**For Cloud Console Compatibility (Recommended):**
- Use `cloud-compatible-unattend.xml`
- Passwords are in plain text for "Get Windows Password" functionality
- Edit passwords directly in the XML file if needed

**For Secure Environments:**
- Use `comprehensive-unattend.xml`
- Passwords are encrypted for security
- Requires manual password management

### 3. Apply Configuration

1. Copy your chosen unattend.xml to your Windows system
2. Run sysprep with the configuration:
   ```cmd
   # For cloud console compatibility
   sysprep /generalize /oobe /shutdown /unattend:cloud-compatible-unattend.xml
   
   # For secure environments
   sysprep /generalize /oobe /shutdown /unattend:comprehensive-unattend.xml
   ```

## Detailed Configuration

### Remote Desktop (RDP) Settings

The configuration includes comprehensive RDP setup:

- **fDenyTSConnections**: Set to `false` to enable RDP
- **UserAuthentication**: Set to `0` for compatibility
- **SecurityLayer**: Set to `2` for Network Level Authentication
- **Windows Firewall**: Automatically configured for RDP traffic

### System Service Manager (SSM) Configuration

SSM support is enabled through:

- **Remote Registry Service**: Enabled and started
- **WinRM**: Configured for remote management
- **PowerShell Remoting**: Enabled with proper security settings
- **Service Dependencies**: Properly configured

### Administrator Account Setup

The Administrator account is configured with:

- **Account Creation**: Local Administrator account created
- **Password Management**: Secure password handling
- **Auto-logon**: Enabled for initial setup (disabled after first logon)
- **UAC**: Disabled for easier administration

### Security Considerations

⚠️ **Important Security Notes:**

1. **Password Security**: The default configuration uses plain text passwords. Use the Secure-PasswordManager.ps1 to encrypt passwords.

2. **UAC Disabled**: UAC is disabled for easier administration. Consider enabling it in production environments.

3. **Firewall Configuration**: Windows Firewall is configured to allow RDP. Review firewall rules for your environment.

4. **Network Security**: Ensure proper network security when using RDP and SSM.

## Validation Features

The validation script checks for:

- ✅ XML syntax errors
- ✅ Required unattend.xml structure
- ✅ Component configuration validation
- ✅ Password security analysis
- ✅ RDP configuration verification
- ✅ SSM/WinRM setup validation
- ✅ First logon commands verification

### Validation Output

The script provides three levels of feedback:

- **Errors**: Critical issues that will prevent sysprep from working
- **Warnings**: Potential issues or security concerns
- **Info**: Informational messages about configuration

## Password Management

### Cloud Console Compatibility (Recommended)

For cloud deployments where you need "Get Windows Password" functionality:

- Use `cloud-compatible-unattend.xml`
- Passwords are stored in plain text
- Edit passwords directly in the XML file
- Cloud console can retrieve passwords automatically

### Secure Environments

For secure environments where encryption is required:

- Use `comprehensive-unattend.xml`
- Passwords are encrypted for security
- Manual password management required
- No cloud console compatibility

### Manual Password Editing

Simply edit the password values in the XML file:

```xml
<!-- For cloud console compatibility -->
<AdministratorPassword>
  <Value>YourPassword123!</Value>
  <PlainText>true</PlainText>
</AdministratorPassword>

<!-- For secure environments -->
<AdministratorPassword>
  <Value>EncryptedPasswordValue</Value>
  <PlainText>false</PlainText>
</AdministratorPassword>
```

## Troubleshooting

### Common Issues

1. **XML Syntax Errors**
   - Use the validation script to identify syntax issues
   - Check for missing closing tags or incorrect attributes

2. **RDP Not Working**
   - Verify Windows Firewall rules are applied
   - Check that Remote Desktop service is running
   - Ensure proper network connectivity

3. **SSM/WinRM Issues**
   - Verify Remote Registry service is running
   - Check WinRM configuration
   - Ensure PowerShell execution policy allows remoting

4. **Password Issues**
   - Check for special characters that might cause issues
   - Verify password format matches your chosen configuration
   - Ensure passwords meet Windows requirements

### Validation Errors

If validation fails:

1. Check the detailed output for specific error messages
2. Review the HTML report for comprehensive analysis
3. Fix errors and re-validate
4. Test with a minimal configuration first

## Best Practices

1. **Always Validate**: Never apply an unattend.xml without validation
2. **Choose Right Configuration**: Use cloud-compatible for cloud, comprehensive for secure environments
3. **Test in Lab**: Test configurations in a lab environment first
4. **Document Changes**: Keep track of configuration changes
5. **Regular Updates**: Update configurations as Windows versions change
6. **Password Security**: Use strong passwords regardless of storage method

## System Requirements

- Windows PowerShell 5.1 or later
- Windows 10/11 or Windows Server 2016/2019/2022
- Administrative privileges for sysprep operations
- Network connectivity for RDP/SSM functionality

## Support

For issues or questions:

1. Run the validation script with detailed output
2. Check the generated HTML report
3. Review Windows Event Logs for sysprep errors
4. Test with minimal configuration first

## Security Recommendations

1. **Change Default Passwords**: Always change default passwords before production use
2. **Use Strong Passwords**: Implement strong password policies
3. **Choose Right Storage**: Use encrypted passwords for secure environments, plain text for cloud console compatibility
4. **Network Security**: Implement proper network security measures
5. **Regular Updates**: Keep systems updated with latest security patches
6. **Access Control**: Implement proper access control and monitoring

---

**Note**: This configuration is designed for administrative and testing purposes. Review all security settings before using in production environments.
