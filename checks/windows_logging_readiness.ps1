<#
.SYNOPSIS
    Checks basic Windows logging and audit policy readiness on a Windows endpoint/server.

.DESCRIPTION
    This script is intended as a low-cost readiness check for SMEs.
    It validates:
      - Whether key Windows event logs are enabled (Security, System, Application)
      - Whether log sizes are reasonably sized for investigations
      - Whether retention mode is sensible
      - Whether critical audit subcategories are enabled (via auditpol)

    Output:
      - A table of checks with Status = Pass / Warn / Fail
      - Optional CSV export for reporting

.PARAMETER ReportPath
    Optional path to export results as CSV (e.g. .\WindowsLoggingReadinessReport.csv)

.EXAMPLE
    .\windows_logging_readiness.ps1

.EXAMPLE
    .\windows_logging_readiness.ps1 -ReportPath .\WindowsLoggingReadinessReport.csv

.NOTES
    Must be run with administrative privileges to access all audit settings.
#>

[CmdletBinding()]
param(
    [string]$ReportPath
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

# Helper to create a standardized result object
function New-CheckResult {
    param(
        [string]$Category,
        [string]$Item,
        [string]$Status,
        [string]$Details
    )

    [pscustomobject]@{
        ComputerName = $env:COMPUTERNAME
        Category     = $Category
        Item         = $Item
        Status       = $Status   # Pass / Warn / Fail
        Details      = $Details
    }
}

$results = @()

Write-Info "Starting Windows logging readiness check on $env:COMPUTERNAME..."

# ---------------------------
# 1. OS Info (for context)
# ---------------------------
try {
    $os = Get-CimInstance Win32_OperatingSystem
    $results += New-CheckResult -Category "System" -Item "OS Info" -Status "Info" -Details ("{0} {1} (Build {2})" -f $os.Caption, $os.Version, $os.BuildNumber)
}
catch {
    $results += New-CheckResult -Category "System" -Item "OS Info" -Status "Warn" -Details "Unable to retrieve OS information: $($_.Exception.Message)"
}

# --------------------------------------------
# 2. Event Logs: Security, System, Application
# --------------------------------------------

Write-Info "Checking core Windows event logs (Security, System, Application)..."

# Recommended minimum sizes (bytes) – adjust for your environment if needed
$recommendedSizes = @{
    "Security"     = 512MB
    "System"       = 256MB
    "Application"  = 256MB
}

# Convert MB to bytes
$recommendedSizes.Keys | ForEach-Object {
    $recommendedSizes[$_] = [int64]($recommendedSizes[$_] / 1MB * 1MB)  # keep as MB-equivalent
}

$logNames = @("Security", "System", "Application")

foreach ($logName in $logNames) {
    try {
        $log = Get-WinEvent -ListLog $logName -ErrorAction Stop

        $enabled = $log.IsEnabled
        $maxSize = $log.MaximumSizeInBytes
        $logMode = $log.LogMode  # Circular, AutoBackup, Retain

        if (-not $enabled) {
            $results += New-CheckResult -Category "Event Logs" -Item $logName -Status "Fail" -Details "Log is disabled."
            continue
        }

        $recommended = $recommendedSizes[$logName]
        $sizeStatus = "Pass"
        $sizeDetails = ("Size = {0} MB" -f ([math]::Round($maxSize / 1MB, 1)))

        if ($maxSize -lt $recommended) {
            $sizeStatus = "Warn"
            $sizeDetails += (" (Recommended >= {0} MB)" -f ($recommended / 1MB))
        }

        # Retention/log mode evaluation
        $modeStatus = "Pass"
        $modeDetails = "LogMode = $logMode"

        switch ($logMode) {
            "Circular"   { $modeStatus = "Warn";  $modeDetails += " (Older events will be overwritten when full.)" }
            "AutoBackup" { $modeStatus = "Pass";  $modeDetails += " (Backups created when full.)" }
            "Retain"     { $modeStatus = "Pass";  $modeDetails += " (Events retained; risk of log fill if not monitored.)" }
            default      { $modeStatus = "Warn";  $modeDetails += " (Unknown/Unusual mode.)" }
        }

        # Combine results
        $results += New-CheckResult -Category "Event Logs" -Item "$logName - Enabled" -Status "Pass" -Details "Log is enabled."
        $results += New-CheckResult -Category "Event Logs" -Item "$logName - Size"    -Status $sizeStatus -Details $sizeDetails
        $results += New-CheckResult -Category "Event Logs" -Item "$logName - Mode"    -Status $modeStatus -Details $modeDetails
    }
    catch {
        $results += New-CheckResult -Category "Event Logs" -Item $logName -Status "Fail" -Details "Unable to query log: $($_.Exception.Message)"
    }
}

# ---------------------------------------------
# 3. Audit Policy: Critical Subcategories Check
# ---------------------------------------------
Write-Info "Checking Windows audit policy (auditpol)..."

# Ensure auditpol is available
if (-not (Get-Command auditpol.exe -ErrorAction SilentlyContinue)) {
    $results += New-CheckResult -Category "Audit Policy" -Item "auditpol.exe" -Status "Fail" -Details "auditpol.exe not found. Cannot query advanced audit policy."
}
else {
    # Define key audit subcategories and expected status
    # Expected: Success and Failure (or at least Success)
    $subcategories = @(
        "Logon",
        "Account Logon",
        "Account Lockout",
        "Group Membership",
        "User Account Management",
        "Security Group Management",
        "Computer Account Management",
        "Policy Change",
        "Authentication Policy Change",
        "Authorization Policy Change",
        "Sensitive Privilege Use",
        "Process Creation"
    )

    foreach ($sub in $subcategories) {
        try {
            $output = auditpol /get /subcategory:"$sub" 2>$null
            if (-not $output) {
                $results += New-CheckResult -Category "Audit Policy" -Item $sub -Status "Warn" -Details "No output from auditpol for this subcategory."
                continue
            }

            # Find line that contains "Success" or "Failure" state
            $line = ($output | Select-String -Pattern "Success|Failure" | Select-Object -First 1).ToString().Trim()
            if (-not $line) {
                $results += New-CheckResult -Category "Audit Policy" -Item $sub -Status "Warn" -Details "Unable to parse auditpol output."
                continue
            }

            # Example line: "  Logon                           Success and Failure"
            $parts = $line -split "\s{2,}"
            $state = $parts[-1].Trim()

            $status = "Pass"
            $details = "Current setting: $state"

            if ($state -eq "No Auditing") {
                $status = "Fail"
                $details += " (Auditing disabled for this subcategory.)"
            }
            elseif ($state -eq "Success") {
                $status = "Warn"
                $details += " (Consider enabling Failure as well.)"
            }

            $results += New-CheckResult -Category "Audit Policy" -Item $sub -Status $status -Details $details
        }
        catch {
            $results += New-CheckResult -Category "Audit Policy" -Item $sub -Status "Fail" -Details "Error querying auditpol: $($_.Exception.Message)"
        }
    }
}

# --------------------------
# 4. Display and/or Export
# --------------------------
Write-Info "Logging readiness check completed. Summary:"
$results | Sort-Object Category, Item | Format-Table -AutoSize

if ($ReportPath) {
    Write-Info "Exporting results to CSV: $ReportPath"
    try {
        $results | Sort-Object Category, Item | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8
        Write-Info "Report exported successfully."
    }
    catch {
        Write-ErrorMsg "Failed to export report: $($_.Exception.Message)"
    }
}
else {
    Write-Info "No ReportPath specified; results displayed in console only."
}
