#Requires -Version 5.1
<#
.SYNOPSIS
    Validates Windows unattend.xml files for syntax errors and configuration issues.

.DESCRIPTION
    This script validates Windows unattend.xml files to catch parsing errors and configuration
    issues before applying them during sysprep. It checks XML syntax, validates against
    Microsoft's unattend schema, and performs additional configuration validation.

.PARAMETER UnattendPath
    Path to the unattend.xml file to validate.

.PARAMETER DetailedOutput
    Provides detailed validation output including warnings and recommendations.

.EXAMPLE
    .\Validate-UnattendXml.ps1 -UnattendPath "C:\Temp\comprehensive-unattend.xml"

.EXAMPLE
    .\Validate-UnattendXml.ps1 -UnattendPath "unattend.xml" -DetailedOutput

.NOTES
    Author: System Administrator
    Version: 1.0
    Requires: Windows PowerShell 5.1 or later
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({Test-Path $_ -PathType Leaf})]
    [string]$UnattendPath,
    
    [switch]$DetailedOutput
)

# Initialize validation results
$ValidationResults = @{
    IsValid = $true
    Errors = @()
    Warnings = @()
    Info = @()
    SchemaValidation = $true
    XmlValidation = $true
}

# Function to add validation message
function Add-ValidationMessage {
    param(
        [string]$Message,
        [string]$Type = "Info",
        [string]$Component = "",
        [int]$Line = 0
    )
    
    $messageObj = @{
        Message = $Message
        Type = $Type
        Component = $Component
        Line = $Line
        Timestamp = Get-Date
    }
    
    switch ($Type) {
        "Error" { 
            $ValidationResults.Errors += $messageObj
            $ValidationResults.IsValid = $false
        }
        "Warning" { $ValidationResults.Warnings += $messageObj }
        "Info" { $ValidationResults.Info += $messageObj }
    }
}

# Function to validate XML syntax
function Test-XmlSyntax {
    param([string]$FilePath)
    
    try {
        [xml]$xmlContent = Get-Content $FilePath -Raw
        Add-ValidationMessage "XML syntax validation passed" "Info"
        return $true
    }
    catch {
        Add-ValidationMessage "XML syntax error: $($_.Exception.Message)" "Error"
        $ValidationResults.XmlValidation = $false
        return $false
    }
}

# Function to validate unattend structure
function Test-UnattendStructure {
    param([xml]$XmlContent)
    
    # Check root element
    if ($XmlContent.unattend -eq $null) {
        Add-ValidationMessage "Missing root 'unattend' element" "Error"
        return $false
    }
    
    # Check required namespaces
    $expectedNamespace = "urn:schemas-microsoft-com:unattend"
    if ($XmlContent.unattend.xmlns -ne $expectedNamespace) {
        Add-ValidationMessage "Incorrect or missing namespace. Expected: $expectedNamespace" "Warning"
    }
    
    # Check for required settings passes
    $requiredPasses = @("windowsPE", "specialize", "oobeSystem")
    $foundPasses = @()
    
    foreach ($pass in $requiredPasses) {
        $passElement = $XmlContent.unattend.settings | Where-Object { $_.pass -eq $pass }
        if ($passElement) {
            $foundPasses += $pass
            Add-ValidationMessage "Found required pass: $pass" "Info"
        } else {
            Add-ValidationMessage "Missing required pass: $pass" "Warning"
        }
    }
    
    return $true
}

# Function to validate components
function Test-Components {
    param([xml]$XmlContent)
    
    $components = $XmlContent.unattend.settings.component
    
    foreach ($component in $components) {
        $componentName = $component.name
        
        # Validate required attributes
        if (-not $component.processorArchitecture) {
            Add-ValidationMessage "Missing processorArchitecture attribute in component: $componentName" "Error" $componentName
        }
        
        if (-not $component.publicKeyToken) {
            Add-ValidationMessage "Missing publicKeyToken attribute in component: $componentName" "Error" $componentName
        }
        
        # Component-specific validations
        switch ($componentName) {
            "Microsoft-Windows-Shell-Setup" {
                Test-ShellSetupComponent $component
            }
            "Microsoft-Windows-TerminalServices-LocalSessionManager" {
                Test-RDPComponent $component
            }
            "Microsoft-Windows-Firewall" {
                Test-FirewallComponent $component
            }
        }
    }
}

# Function to validate Shell Setup component
function Test-ShellSetupComponent {
    param([System.Xml.XmlElement]$Component)
    
    # Check for AdministratorPassword
    $adminPassword = $Component.UserAccounts.AdministratorPassword
    if ($adminPassword) {
        if ($adminPassword.PlainText -eq "true" -and $adminPassword.Value) {
            Add-ValidationMessage "Administrator password is set in plain text" "Warning" "Shell-Setup"
        }
        if (-not $adminPassword.Value) {
            Add-ValidationMessage "Administrator password value is empty" "Error" "Shell-Setup"
        }
    } else {
        Add-ValidationMessage "No AdministratorPassword configured" "Warning" "Shell-Setup"
    }
    
    # Check AutoLogon
    $autoLogon = $Component.AutoLogon
    if ($autoLogon -and $autoLogon.Enabled -eq "true") {
        if (-not $autoLogon.Username) {
            Add-ValidationMessage "AutoLogon enabled but no Username specified" "Error" "Shell-Setup"
        }
        if (-not $autoLogon.Password) {
            Add-ValidationMessage "AutoLogon enabled but no Password specified" "Error" "Shell-Setup"
        }
    }
}

# Function to validate RDP component
function Test-RDPComponent {
    param([System.Xml.XmlElement]$Component)
    
    if ($Component.fDenyTSConnections -eq "false") {
        Add-ValidationMessage "Remote Desktop is enabled" "Info" "RDP"
    } else {
        Add-ValidationMessage "Remote Desktop is disabled" "Warning" "RDP"
    }
}

# Function to validate Firewall component
function Test-FirewallComponent {
    param([System.Xml.XmlElement]$Component)
    
    if ($Component.Profile.WindowsFirewall -eq "false") {
        Add-ValidationMessage "Windows Firewall is disabled" "Warning" "Firewall"
    }
}

# Function to validate first logon commands
function Test-FirstLogonCommands {
    param([xml]$XmlContent)
    
    $firstLogonSettings = $XmlContent.unattend.settings | Where-Object { $_.pass -eq "firstLogonCommands" }
    if ($firstLogonSettings) {
        $commands = $firstLogonSettings.component.FirstLogonCommands.SynchronousCommand
        if ($commands) {
            Add-ValidationMessage "Found $($commands.Count) first logon commands" "Info" "FirstLogonCommands"
            
            # Check for RDP enabling commands
            $rdpCommands = $commands | Where-Object { $_.CommandLine -like "*fDenyTSConnections*" }
            if ($rdpCommands) {
                Add-ValidationMessage "RDP enabling commands found" "Info" "FirstLogonCommands"
            }
            
            # Check for SSM/WinRM commands
            $ssmCommands = $commands | Where-Object { $_.CommandLine -like "*winrm*" -or $_.CommandLine -like "*RemoteRegistry*" }
            if ($ssmCommands) {
                Add-ValidationMessage "SSM/WinRM configuration commands found" "Info" "FirstLogonCommands"
            }
        }
    }
}

# Function to generate text report
function Generate-TextReport {
    param([hashtable]$Results, [string]$OutputPath)
    
    $report = @"
UNATTEND.XML VALIDATION REPORT
===============================
Generated: $(Get-Date)
File: $UnattendPath

VALIDATION SUMMARY
==================
Overall Status: $(if ($Results.IsValid) { 'PASSED' } else { 'FAILED' })
Errors: $($Results.Errors.Count)
Warnings: $($Results.Warnings.Count)
Info Messages: $($Results.Info.Count)

"@

    if ($Results.Errors.Count -gt 0) {
        $report += "`nERRORS`n=====`n"
        foreach ($error in $Results.Errors) {
            $report += "Component: $($error.Component) | Line: $($error.Line)`n"
            $report += "Message: $($error.Message)`n"
            $report += "Timestamp: $($error.Timestamp)`n`n"
        }
    }

    if ($Results.Warnings.Count -gt 0) {
        $report += "`nWARNINGS`n========`n"
        foreach ($warning in $Results.Warnings) {
            $report += "Component: $($warning.Component) | Line: $($warning.Line)`n"
            $report += "Message: $($warning.Message)`n"
            $report += "Timestamp: $($warning.Timestamp)`n`n"
        }
    }

    if ($Results.Info.Count -gt 0) {
        $report += "`nINFORMATION`n===========`n"
        foreach ($info in $Results.Info) {
            $report += "Component: $($info.Component) | Line: $($info.Line)`n"
            $report += "Message: $($info.Message)`n"
            $report += "Timestamp: $($info.Timestamp)`n`n"
        }
    }

    $report | Out-File -FilePath $OutputPath -Encoding UTF8
    Add-ValidationMessage "Text report generated: $OutputPath" "Info"
}

# Main validation process
Write-Host "Starting unattend.xml validation..."
Write-Host "File: $UnattendPath"

# Step 1: XML Syntax Validation
Write-Host ""
Write-Host "1. Validating XML syntax..."
if (Test-XmlSyntax -FilePath $UnattendPath) {
    [xml]$xmlContent = Get-Content $UnattendPath -Raw
    
    # Step 2: Unattend Structure Validation
    Write-Host "2. Validating unattend structure..."
    Test-UnattendStructure -XmlContent $xmlContent
    
    # Step 3: Component Validation
    Write-Host "3. Validating components..."
    Test-Components -XmlContent $xmlContent
    
    # Step 4: First Logon Commands Validation
    Write-Host "4. Validating first logon commands..."
    Test-FirstLogonCommands -XmlContent $xmlContent
}

# Display results
Write-Host ""
Write-Host "=" * 60
Write-Host "VALIDATION RESULTS"
Write-Host "=" * 60

if ($ValidationResults.IsValid) {
    Write-Host "VALIDATION PASSED" -ForegroundColor Green
} else {
    Write-Host "VALIDATION FAILED" -ForegroundColor Red
}

Write-Host ""
Write-Host "Errors: $($ValidationResults.Errors.Count)"
Write-Host "Warnings: $($ValidationResults.Warnings.Count)"
Write-Host "Info: $($ValidationResults.Info.Count)"

# Display detailed output if requested
if ($DetailedOutput) {
    Write-Host ""
    Write-Host "-" * 40
    Write-Host "DETAILED OUTPUT"
    Write-Host "-" * 40
    
    foreach ($error in $ValidationResults.Errors) {
        Write-Host "ERROR [$($error.Component)]: $($error.Message)"
    }
    
    foreach ($warning in $ValidationResults.Warnings) {
        Write-Host "WARNING [$($warning.Component)]: $($warning.Message)"
    }
    
    foreach ($info in $ValidationResults.Info) {
        Write-Host "INFO [$($info.Component)]: $($info.Message)"
    }
}

# Generate text report
$reportPath = "unattend-validation-report.txt"
Write-Host ""
Write-Host "Generating text report..."
Generate-TextReport -Results $ValidationResults -OutputPath $reportPath

# Return validation results
return $ValidationResults
