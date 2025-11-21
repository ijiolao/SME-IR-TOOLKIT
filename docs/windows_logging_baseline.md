# Windows Logging Baseline for SMEs

## 1. Core Event Logs (Minimum Requirements)
| Log Name | Minimum Size | Rationale |
|----------|--------------|-----------|
| **Security** | **512 MB** | Authentication events, privilege use, policy tampering. |
| **System** | **256 MB** | Service failures, reboots, instability indicators. |
| **Application** | **256 MB** | App-level errors, injection/tampering patterns. |

### Additional Requirements
- Logs **must be enabled**.
- Retention mode: **AutoBackup** or **Retain** preferred.
- Avoid **Circular** for Security log.
- Maintain **7–14 days** of retrievable history.

## 2. Advanced Audit Policy Baseline
Enable via `auditpol`:

- Logon / Account Logon  
- Account Management  
- Policy Change  
- Sensitive Privilege Use  
- **Process Creation (4688)**  
- Optional (Servers): File Share Access, DS Access

## 3. Command-Line Logging Enhancements
- Enable **Include command line in process creation events**.
- Enable **PowerShell Operational Logging**.

## 4. Minimum Collection Strategy
- Export logs during investigation.
- Retain for **30–90 days**.
- Forward to SIEM if available (Sentinel recommended).

## 5. Success Criteria
A system meets the baseline if:
- All three logs enabled + correct sizing  
- Audit policy categories enabled  
- 4688 logging active  
- Retention provides at least 7–14 days of data  
