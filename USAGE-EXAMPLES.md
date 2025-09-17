# Usage Examples for Windows Unattend.xml Suite

This document provides practical examples for using the Windows Unattend.xml configuration suite.

## Basic Validation

### Simple Validation
```powershell
# Validate the comprehensive unattend.xml
.\Validate-UnattendXml.ps1 -UnattendPath "comprehensive-unattend.xml"
```

### Detailed Validation with Report
```powershell
# Get detailed output and generate HTML report
.\Validate-UnattendXml.ps1 -UnattendPath "comprehensive-unattend.xml" -DetailedOutput -GenerateReport
```

### Validate Your Custom File
```powershell
# Validate your existing unattend.xml
.\Validate-UnattendXml.ps1 -UnattendPath "minimal-unattend.xml" -DetailedOutput
```

## Password Management

### Cloud Console Compatibility (Recommended)

For cloud deployments where you need "Get Windows Password" functionality:

```xml
<!-- Edit passwords directly in cloud-compatible-unattend.xml -->
<AdministratorPassword>
  <Value>YourCustomPassword123!</Value>
  <PlainText>true</PlainText>
</AdministratorPassword>
```

### Secure Environments

For secure environments where encryption is required:

```xml
<!-- Use comprehensive-unattend.xml with encrypted passwords -->
<AdministratorPassword>
  <Value>EncryptedPasswordValue</Value>
  <PlainText>false</PlainText>
</AdministratorPassword>
```

### Manual Password Editing

Simply edit the password values in the XML file:

1. Open the unattend.xml file in a text editor
2. Find all `<Value>` tags containing passwords
3. Replace with your desired password
4. Save the file
5. Validate before deploying

## Complete Workflow Examples

### Example 1: Cloud Console Setup

```powershell
# Step 1: Choose cloud-compatible configuration
# Use cloud-compatible-unattend.xml (already configured)

# Step 2: Edit password if needed (optional)
# Open cloud-compatible-unattend.xml in text editor
# Change "CloudConsolePassword123!" to your preferred password

# Step 3: Validate the configuration
.\Validate-UnattendXml.ps1 -UnattendPath "cloud-compatible-unattend.xml" -DetailedOutput

# Step 4: Deploy with sysprep
# sysprep /generalize /oobe /shutdown /unattend:cloud-compatible-unattend.xml

# Step 5: Use "Get Windows Password" in cloud console
# Step 6: Connect via RDP
```

### Example 2: Testing Configuration

```powershell
# Step 1: Create a test copy
Copy-Item "cloud-compatible-unattend.xml" "test-unattend.xml"

# Step 2: Modify for testing (e.g., change computer name)
(Get-Content "test-unattend.xml") -replace "WIN-CLOUD", "TEST-CLOUD" | Set-Content "test-unattend.xml"

# Step 3: Validate the test configuration
.\Validate-UnattendXml.ps1 -UnattendPath "test-unattend.xml" -DetailedOutput -GenerateReport

# Step 4: If validation passes, use for testing
```

### Example 3: Production Deployment

```powershell
# Step 1: Create production unattend.xml
Copy-Item "cloud-compatible-unattend.xml" "production-unattend.xml"

# Step 2: Update with production settings
(Get-Content "production-unattend.xml") -replace "WIN-CLOUD", "PROD-SERVER-01" | Set-Content "production-unattend.xml"

# Step 3: Edit password for production (optional)
# Open production-unattend.xml and change password if needed

# Step 4: Validate production configuration
.\Validate-UnattendXml.ps1 -UnattendPath "production-unattend.xml" -DetailedOutput -GenerateReport

# Step 5: Deploy
# sysprep /generalize /oobe /shutdown /unattend:production-unattend.xml
```

## Troubleshooting Examples

### Fix Common Validation Errors

```powershell
# Check for XML syntax errors
.\Validate-UnattendXml.ps1 -UnattendPath "problematic-unattend.xml" -DetailedOutput

# Common fixes:
# 1. Missing closing tags
# 2. Incorrect attribute values
# 3. Missing required components
```

### Password Issues

```powershell
# Check password configuration
.\Validate-UnattendXml.ps1 -UnattendPath "cloud-compatible-unattend.xml" -DetailedOutput

# Edit password manually if needed
# Open unattend.xml in text editor and change password values

# Validate after password changes
.\Validate-UnattendXml.ps1 -UnattendPath "your-unattend.xml" -DetailedOutput
```

## Advanced Usage

### Custom Validation Rules

```powershell
# Create a custom validation script
$validationScript = @"
# Custom validation logic
if ($xmlContent.unattend.settings.component.name -notcontains "Microsoft-Windows-Shell-Setup") {
    Write-Error "Missing Shell-Setup component"
}
"@

$validationScript | Out-File -FilePath "Custom-Validation.ps1"
```

### Batch Processing

```powershell
# Validate multiple unattend files
$unattendFiles = @("unattend1.xml", "unattend2.xml", "unattend3.xml")

foreach ($file in $unattendFiles) {
    Write-Host "Validating $file..." -ForegroundColor Yellow
    .\Validate-UnattendXml.ps1 -UnattendPath $file -DetailedOutput
}
```

### Integration with CI/CD

```powershell
# Example for automated validation in CI/CD pipeline
$validationResult = .\Validate-UnattendXml.ps1 -UnattendPath "unattend.xml" -DetailedOutput

if (-not $validationResult.IsValid) {
    Write-Error "Unattend.xml validation failed"
    exit 1
} else {
    Write-Host "Validation passed" -ForegroundColor Green
    exit 0
}
```

## Security Best Practices

### Cloud Console Workflow

```powershell
# 1. Use cloud-compatible-unattend.xml (already configured)
# 2. Edit password if needed (optional)
# 3. Validate configuration
.\Validate-UnattendXml.ps1 -UnattendPath "cloud-compatible-unattend.xml" -DetailedOutput

# 4. Deploy with sysprep
# sysprep /generalize /oobe /shutdown /unattend:cloud-compatible-unattend.xml

# 5. Use "Get Windows Password" in cloud console
# 6. Connect via RDP with retrieved password
```

### Environment-Specific Configurations

```powershell
# Development environment
Copy-Item "cloud-compatible-unattend.xml" "dev-unattend.xml"
# Edit dev-unattend.xml and change password to "DevPassword123!"

# Staging environment
Copy-Item "cloud-compatible-unattend.xml" "staging-unattend.xml"
# Edit staging-unattend.xml and change password to "StagingPassword123!"

# Production environment
Copy-Item "cloud-compatible-unattend.xml" "prod-unattend.xml"
# Edit prod-unattend.xml and change password to "ProductionPassword123!"
```

## Monitoring and Logging

### Log Validation Results

```powershell
# Log validation results to file
$logFile = "validation-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
.\Validate-UnattendXml.ps1 -UnattendPath "unattend.xml" -DetailedOutput | Tee-Object -FilePath $logFile
```

### Generate Reports for Documentation

```powershell
# Generate HTML report for documentation
.\Validate-UnattendXml.ps1 -UnattendPath "unattend.xml" -GenerateReport

# The report will be saved as "unattend-validation-report.html"
```

## Common Commands Reference

### Quick Commands

```powershell
# Quick validation
.\Validate-UnattendXml.ps1 -UnattendPath "cloud-compatible-unattend.xml"

# Quick validation with report
.\Validate-UnattendXml.ps1 -UnattendPath "cloud-compatible-unattend.xml" -DetailedOutput -GenerateReport

# Quick deployment
# sysprep /generalize /oobe /shutdown /unattend:cloud-compatible-unattend.xml
```

### Help and Information

```powershell
# Get help for validation script
Get-Help .\Validate-UnattendXml.ps1 -Full

# List all available parameters
.\Validate-UnattendXml.ps1 -?
```

---

**Remember**: Always test configurations in a lab environment before deploying to production systems!
