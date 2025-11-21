<#
.SYNOPSIS
    One-stop setup and execution script for the SME IR Readiness Toolkit.

.DESCRIPTION
    This script is intended to be run from the **root** of the repository.
    It will:

      1. Create a "reports" folder if it does not exist.
      2. Optionally install required dependencies:
         - PowerShell modules:
             - ExchangeOnlineManagement
             - MSOnline
         - Python package:
             - dnspython
      3. Run the core technical checks:
         - m365_mailbox_rules.ps1
         - m365_mfa_admin_check.ps1
         - windows_logging_readiness.ps1
         - email_dmarc_spf_checker.py (for a specified domain)

    Outputs CSV/MD reports into the "reports" folder.

.PARAMETER Domain
    Primary email/domain name to test SPF/DMARC/DKIM for (e.g. example.com).

.PARAMETER InstallDependencies
    If specified, attempts to install required PowerShell modules and Python package (dnspython).

.PARAMETER PythonPath
    Optional path to python executable. Defaults to "python" on PATH.

.EXAMPLE
    .\run_ir_toolkit_setup.ps1 -Domain example.com

.EXAMPLE
    .\run_ir_toolkit_setup.ps1 -Domain example.com -InstallDependencies
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Domain,

    [switch]$InstallDependencies,

    [string]$PythonPath = "python"
)

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Ensure we are in the repo root (heuristic: check for tools folder)
if (-not (Test-Path ".\tools")) {
    Write-Warn "This script should be run from the root of the repository where the 'tools' folder exists."
}

# Create reports folder
$reportsDir = Join-Path (Get-Location) "reports"
if (-not (Test-Path $reportsDir)) {
    Write-Info "Creating reports directory at: $reportsDir"
    New-Item -Path $reportsDir -ItemType Directory | Out-Null
} else {
    Write-Info "Reports directory already exists: $reportsDir"
}

# -----------------------------
# Install dependencies (optional)
# -----------------------------
if ($InstallDependencies) {
    Write-Info "Installing/validating required dependencies..."

    # PowerShell modules – ExchangeOnlineManagement
    if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
        Write-Info "Installing ExchangeOnlineManagement module..."
        try {
            Install-Module ExchangeOnlineManagement -Scope CurrentUser -Force -ErrorAction Stop
        }
        catch {
            Write-ErrorMsg "Failed to install ExchangeOnlineManagement: $($_.Exception.Message)"
        }
    } else {
        Write-Info "ExchangeOnlineManagement module already installed."
    }

    # PowerShell modules – MSOnline
    if (-not (Get-Module -ListAvailable -Name MSOnline)) {
        Write-Info "Installing MSOnline module..."
        try {
            Install-Module MSOnline -Scope CurrentUser -Force -ErrorAction Stop
        }
        catch {
            Write-ErrorMsg "Failed to install MSOnline: $($_.Exception.Message)"
        }
    } else {
        Write-Info "MSOnline module already installed."
    }

    # Python dnspython
    Write-Info "Checking Python and dnspython package..."
    try {
        & $PythonPath -c "import dns" 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Info "dnspython not detected. Installing via pip..."
            & $PythonPath -m pip install dnspython
        } else {
            Write-Info "dnspython already available."
        }
    }
    catch {
        Write-Warn "Unable to verify/install dnspython. Ensure Python and pip are installed and on PATH."
    }
}

# -----------------------------
# 1. Run mailbox rules check
# -----------------------------
$MailboxRulesScript = ".\tools\checks\m365_mailbox_rules.ps1"
if (Test-Path $MailboxRulesScript) {
    $mailboxReport = Join-Path $reportsDir "MailboxRulesReport.csv"
    Write-Info "Running mailbox rules scanner..."
    try {
        & $MailboxRulesScript -AllMailboxes -ReportPath $mailboxReport
    }
    catch {
        Write-ErrorMsg "Failed to run mailbox rules script: $($_.Exception.Message)"
    }
} else {
    Write-Warn "Mailbox rules script not found at $MailboxRulesScript"
}

# -----------------------------
# 2. Run MFA + admin role check
# -----------------------------
$MfaAdminScript = ".\tools\checks\m365_mfa_admin_check.ps1"
if (Test-Path $MfaAdminScript) {
    $mfaReport = Join-Path $reportsDir "MFA_AdminRole_Report.csv"
    Write-Info "Running MFA + admin role check..."
    try {
        & $MfaAdminScript -ReportPath $mfaReport
    }
    catch {
        Write-ErrorMsg "Failed to run MFA/admin script: $($_.Exception.Message)"
    }
} else {
    Write-Warn "MFA/admin script not found at $MfaAdminScript"
}

# -----------------------------
# 3. Run Windows logging readiness check
# -----------------------------
$LoggingScript = ".\tools\checks\windows_logging_readiness.ps1"
if (Test-Path $LoggingScript) {
    $loggingReport = Join-Path $reportsDir "WindowsLoggingReadinessReport.csv"
    Write-Info "Running Windows logging readiness check..."
    try {
        & $LoggingScript -ReportPath $loggingReport
    }
    catch {
        Write-ErrorMsg "Failed to run Windows logging readiness script: $($_.Exception.Message)"
    }
} else {
    Write-Warn "Windows logging readiness script not found at $LoggingScript"
}

# -----------------------------
# 4. Run Email SPF/DMARC/DKIM checker
# -----------------------------
$EmailChecker = ".\tools\checks\email_dmarc_spf_checker.py"
if (Test-Path $EmailChecker) {
    $emailReport = Join-Path $reportsDir "Email_Auth_Posture_Report.csv"
    Write-Info "Running email SPF/DMARC/DKIM checker for domain: $Domain"
    try {
        & $PythonPath $EmailChecker --domain $Domain --output $emailReport
    }
    catch {
        Write-ErrorMsg "Failed to run email authentication checker: $($_.Exception.Message)"
    }
} else {
    Write-Warn "Email authentication checker not found at $EmailChecker"
}

Write-Info "IR Readiness Toolkit setup/checks complete. Reports (if generated) are in: $reportsDir"
