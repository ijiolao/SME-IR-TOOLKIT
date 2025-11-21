<#
.SYNOPSIS
    Checks Microsoft 365 tenant for privileged admin accounts and their MFA status.

.DESCRIPTION
    This script connects to Azure AD (MSOL) and:
      - Identifies users in privileged/admin roles
      - Checks whether MFA is enabled for those accounts
      - Optionally includes ALL users in the report
    It then exports the results to a CSV file for review.

    This is intended as a low-cost IR/governance control for SMEs:
      - Quickly spot Global Admins without MFA
      - Identify risky accounts (e.g. blocked, unlicensed, no MFA)

.PARAMETER ReportPath
    Path to the CSV report file to be generated.

.PARAMETER IncludeAllUsers
    Include all user accounts in the report (not only admins).

.EXAMPLE
    .\m365_mfa_admin_check.ps1 -ReportPath .\MFA_AdminRole_Report.csv

.EXAMPLE
    .\m365_mfa_admin_check.ps1 -IncludeAllUsers

.NOTES
    Requires:
      - MSOnline PowerShell module
      - Appropriate permissions (e.g. Global Admin, Security Admin)
#>

[CmdletBinding()]
param(
    [string]$ReportPath = ".\MFA_AdminRole_Report.csv",
    [switch]$IncludeAllUsers
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

# Ensure MSOnline module is available
if (-not (Get-Module -ListAvailable -Name MSOnline)) {
    Write-ErrorMsg "MSOnline module not found. Please install it:"
    Write-Host "  Install-Module MSOnline -Scope CurrentUser"
    exit 1
}

Import-Module MSOnline -ErrorAction Stop

# Connect to MSOL
try {
    Write-Info "Connecting to Azure AD (MSOnline)..."
    Connect-MsolService
}
catch {
    Write-ErrorMsg "Failed to connect to Azure AD: $($_.Exception.Message)"
    exit 1
}

# Define privileged/admin role names (MSOL-style)
$privilegedRoleNames = @(
    "Company Administrator",              # Global Admin
    "Security Administrator",
    "SharePoint Service Administrator",
    "Exchange Service Administrator",
    "User Account Administrator",
    "Helpdesk Administrator",
    "Service Support Administrator",
    "Billing Administrator",
    "Directory Writers",
    "Password Administrator",
    "Conditional Access Administrator",
    "Reports Reader"
)

Write-Info "Collecting privileged roles and members..."

# Map: UPN -> list of roles
$userRoles = @{}

foreach ($roleName in $privilegedRoleNames) {
    try {
        $role = Get-MsolRole -RoleName $roleName -ErrorAction SilentlyContinue
        if (-not $role) {
            continue
        }

        $members = Get-MsolRoleMember -RoleObjectId $role.ObjectId -ErrorAction SilentlyContinue
        foreach ($m in $members) {
            if ($m.EmailAddress) {
                $upn = $m.EmailAddress.ToLower()
            } elseif ($m.UserPrincipalName) {
                $upn = $m.UserPrincipalName.ToLower()
            } else {
                continue
            }

            if (-not $userRoles.ContainsKey($upn)) {
                $userRoles[$upn] = New-Object System.Collections.Generic.List[string]
            }
            $userRoles[$upn].Add($roleName)
        }
    }
    catch {
        Write-Warn "Failed to retrieve members for role '$roleName': $($_.Exception.Message)"
    }
}

if ($userRoles.Count -eq 0) {
    Write-Warn "No privileged role members found based on the configured roles."
}

# Retrieve users
Write-Info "Retrieving users from Azure AD..."
try {
    $allUsers = Get-MsolUser -All
}
catch {
    Write-ErrorMsg "Failed to retrieve users: $($_.Exception.Message)"
    exit 1
}

# Helper: determine MFA status
function Get-MFAStatus {
    param([Microsoft.Online.Administration.User]$User)

    $requirements = $User.StrongAuthenticationRequirements
    $methods = $User.StrongAuthenticationMethods

    $hasMethods = $false
    if ($methods -and $methods.Count -gt 0) {
        $hasMethods = $true
    }

    $state = $null
    if ($requirements -and $requirements.Count -gt 0) {
        # Just grab the first requirement state for simplicity
        $state = $requirements[0].State
    }

    if ($state -match "Enabled|Enforced") {
        return "Enabled/Enforced"
    }

    if ($hasMethods) {
        return "Enabled (Methods Present)"
    }

    return "Disabled"
}

Write-Info "Building report data..."

$results = @()

foreach ($user in $allUsers) {
    $upn = $user.UserPrincipalName.ToLower()
    $roles = @()
    $isAdmin = $false

    if ($userRoles.ContainsKey($upn)) {
        $roles = $userRoles[$upn]
        if ($roles.Count -gt 0) {
            $isAdmin = $true
        }
    }

    if (-not $IncludeAllUsers -and -not $isAdmin) {
        continue
    }

    $mfaStatus = Get-MFAStatus -User $user

    # Simple risk classification
    $riskLevel = "Info"
    $riskReason = @()

    if ($isAdmin -and $mfaStatus -like "Disabled") {
        $riskLevel = "High"
        $riskReason += "Admin without MFA"
    } elseif ($isAdmin -and $mfaStatus -notlike "Disabled") {
        $riskLevel = "Medium"
        $riskReason += "Admin with MFA"
    } elseif (-not $isAdmin -and $mfaStatus -like "Disabled") {
        $riskLevel = "Info"
        $riskReason += "Non-admin without MFA"
    } else {
        $riskReason += "Non-admin with MFA"
    }

    if ($user.BlockCredential) {
        $riskReason += "Account blocked"
    }

    $results += [pscustomobject]@{
        UserPrincipalName = $user.UserPrincipalName
        DisplayName       = $user.DisplayName
        IsAdmin           = $isAdmin
        Roles             = ($roles -join "; ")
        MFAStatus         = $mfaStatus
        IsLicensed        = $user.IsLicensed
        Blocked           = $user.BlockCredential
        LastDirSyncTime   = $user.LastDirSyncTime
        SignInAllowed     = -not $user.BlockCredential
        RiskLevel         = $riskLevel
        RiskReason        = ($riskReason -join "; ")
    }
}

if ($results.Count -eq 0) {
    Write-Warn "No users matched the selection criteria. Nothing to export."
    exit 0
}

Write-Info ("Exporting {0} user record(s) to: {1}" -f $results.Count, $ReportPath)

try {
    $results |
        Sort-Object -Property @{Expression="IsAdmin";Descending=$true}, MFAStatus, UserPrincipalName |
        Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8

    Write-Info "Report generated successfully."
}
catch {
    Write-ErrorMsg "Failed to write report: $($_.Exception.Message)"
}

Write-Info "MFA + Admin role check complete."
