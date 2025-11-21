<#
.SYNOPSIS
    Scans Microsoft 365 mailboxes for risky inbox rules (external forwarding, auto-delete, stealth rules).

.DESCRIPTION
    This script connects to Exchange Online (EXO) and inspects inbox rules for one or more mailboxes.
    It flags potentially malicious or risky rules such as:
      - Forwarding or redirecting mail to external domains
      - Deleting or moving messages to obscure folders
      - Marking messages as read silently
    Results are exported to a CSV report for review.

    Designed for SMEs as part of an Incident Response / Threat Hunting toolkit.

.PARAMETER ReportPath
    Path to the CSV report file to be generated.

.PARAMETER AllMailboxes
    Scan all user mailboxes in the tenant.

.PARAMETER UserPrincipalName
    Scan a single mailbox identified by UPN (e.g. user@domain.com).

.EXAMPLE
    .\m365_mailbox_rules.ps1 -AllMailboxes -ReportPath .\MailboxRulesReport.csv

.EXAMPLE
    .\m365_mailbox_rules.ps1 -UserPrincipalName user@contoso.com

.NOTES
    Requires:
      - Exchange Online PowerShell module (V2)
      - Appropriate permissions (e.g. Exchange admin, or delegated rights)
#>

[CmdletBinding()]
param(
    [string]$ReportPath = ".\MailboxRulesReport.csv",
    [switch]$AllMailboxes,
    [string]$UserPrincipalName
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

if (-not $AllMailboxes -and -not $UserPrincipalName) {
    Write-Warn "You did not specify -AllMailboxes or -UserPrincipalName."
    Write-Host "Usage examples:"
    Write-Host "  .\m365_mailbox_rules.ps1 -AllMailboxes"
    Write-Host "  .\m365_mailbox_rules.ps1 -UserPrincipalName user@contoso.com"
    exit 1
}

# Ensure EXO module is available
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-ErrorMsg "ExchangeOnlineManagement module not found. Please install it:"
    Write-Host "  Install-Module ExchangeOnlineManagement -Scope CurrentUser"
    exit 1
}

# Try to connect to Exchange Online
try {
    if (-not (Get-ConnectionInformation)) {
        Write-Info "Connecting to Exchange Online..."
        Connect-ExchangeOnline -ShowBanner:$false | Out-Null
    } else {
        Write-Info "Reusing existing Exchange Online session."
    }
}
catch {
    Write-ErrorMsg "Failed to connect to Exchange Online: $($_.Exception.Message)"
    exit 1
}

# Get target mailboxes
$mailboxes = @()

if ($AllMailboxes) {
    Write-Info "Retrieving all user mailboxes..."
    try {
        $mailboxes = Get-ExoMailbox -RecipientTypeDetails UserMailbox -ResultSize Unlimited
    }
    catch {
        Write-ErrorMsg "Failed to retrieve mailboxes: $($_.Exception.Message)"
        exit 1
    }
} else {
    Write-Info "Retrieving mailbox for user: $UserPrincipalName"
    try {
        $mbx = Get-ExoMailbox -Identity $UserPrincipalName -ErrorAction Stop
        $mailboxes = @($mbx)
    }
    catch {
        Write-ErrorMsg "Failed to retrieve mailbox for $UserPrincipalName: $($_.Exception.Message)"
        exit 1
    }
}

if (-not $mailboxes -or $mailboxes.Count -eq 0) {
    Write-Warn "No mailboxes found to scan."
    exit 0
}

Write-Info ("Scanning {0} mailbox(es) for risky inbox rules..." -f $mailboxes.Count)

$results = @()

foreach ($mbx in $mailboxes) {
    $primarySmtp = $mbx.PrimarySmtpAddress.ToString()
    $tenantDomain = $primarySmtp.Split("@")[-1]

    Write-Info "Checking mailbox: $primarySmtp"

    try {
        $rules = Get-InboxRule -Mailbox $primarySmtp -ErrorAction Stop
    }
    catch {
        Write-Warn "Could not retrieve rules for $primarySmtp: $($_.Exception.Message)"
        continue
    }

    foreach ($rule in $rules) {

        # Determine if rule forwards externally
        $externalRecipients = @()

        $forwardTargets = @()
        if ($rule.ForwardTo) { $forwardTargets += $rule.ForwardTo }
        if ($rule.ForwardAsAttachmentTo) { $forwardTargets += $rule.ForwardAsAttachmentTo }
        if ($rule.RedirectTo) { $forwardTargets += $rule.RedirectTo }

        foreach ($rec in $forwardTargets) {
            # Try to treat as a string address
            $addr = $null
            try {
                if ($rec -is [string]) {
                    $addr = $rec
                } elseif ($rec.PrimarySmtpAddress) {
                    $addr = $rec.PrimarySmtpAddress.ToString()
                } elseif ($rec.Address) {
                    $addr = $rec.Address.ToString()
                }
            } catch { }

            if ($addr) {
                $domain = $addr.Split("@")[-1]
                if ($domain -and ($domain -ne $tenantDomain)) {
                    $externalRecipients += $addr
                }
            }
        }

        $hasExternalForward = $externalRecipients.Count -gt 0
        $hasForward = $forwardTargets.Count -gt 0

        $hasDelete = $rule.DeleteMessage
        $hasMove = -not [string]::IsNullOrEmpty($rule.MoveToFolder)
        $marksRead = $rule.MarkAsRead
        $stopsProcessing = $rule.StopProcessingRules

        # Simple risk classification
        $riskLevel = "Info"
        $riskReason = @()

        if ($hasExternalForward) {
            $riskLevel = "High"
            $riskReason += "External forwarding"
        } elseif ($hasForward) {
            $riskLevel = "Medium"
            $riskReason += "Internal forwarding/redirect"
        }

        if ($hasDelete -or $hasMove -or $marksRead) {
            if ($riskLevel -eq "High") {
                $riskReason += "Stealth actions (delete/move/mark as read)"
            } elseif ($hasMove -or $hasDelete -or $marksRead) {
                if ($riskLevel -eq "Info") {
                    $riskLevel = "Medium"
                }
                $riskReason += "Local stealth actions (delete/move/mark as read)"
            }
        }

        if ($stopsProcessing) {
            $riskReason += "StopProcessingRules"
            if ($riskLevel -eq "Info") { $riskLevel = "Medium" }
        }

        # Only include "interesting" rules, or include all if you prefer
        $includeRule = $hasForward -or $hasExternalForward -or $hasDelete -or $hasMove -or $marksRead

        if ($includeRule) {
            $results += [pscustomobject]@{
                Mailbox               = $primarySmtp
                RuleName              = $rule.Name
                Enabled               = $rule.Enabled
                Priority              = $rule.Priority
                Description           = $rule.Description
                FromAddressContains   = ($rule.From | ForEach-Object { $_.ToString() }) -join ";"
                SentToContains        = ($rule.SentTo | ForEach-Object { $_.ToString() }) -join ";"
                SubjectContains       = ($rule.SubjectContainsWords -join ";")
                BodyContains          = ($rule.BodyContainsWords -join ";")
                HasForward            = $hasForward
                HasExternalForward    = $hasExternalForward
                ExternalRecipients    = $externalRecipients -join ";"
                DeleteMessage         = $hasDelete
                MoveToFolder          = $rule.MoveToFolder
                MarkAsRead            = $marksRead
                StopProcessingRules   = $stopsProcessing
                RiskLevel             = $riskLevel
                RiskReason            = ($riskReason -join "; ")
            }
        }
    }
}

if ($results.Count -eq 0) {
    Write-Info "No risky or forwarding-related inbox rules were found based on current criteria."
} else {
    Write-Info ("Exporting {0} rule(s) to report: {1}" -f $results.Count, $ReportPath)
    try {
        $results | Sort-Object RiskLevel, Mailbox, Priority | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8
        Write-Info "Report generated successfully."
    }
    catch {
        Write-ErrorMsg "Failed to write report: $($_.Exception.Message)"
    }
}

Write-Info "Scan complete."
