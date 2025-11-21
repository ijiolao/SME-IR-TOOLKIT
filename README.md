# SME Incident Response (IR) Readiness Toolkit
A lightweight, low-cost, and practical toolkit designed to help **Small and Medium-Sized Enterprises (SMEs)** assess, strengthen, and document their Incident Response (IR) capability.

This toolkit focuses on *realistic, achievable, low-cost* controls and processes that SMEs can implement without expensive security platforms, consultants, or enterprise-grade tooling.  
Everything in this repository is designed to accelerate IR readiness using **templates**, **scripts**, **checklists**, and **automated assessments**.

---

## 🔍 Why This Toolkit Exists
Most SMEs lack dedicated security teams and incident response processes.  
However, SMEs are increasingly targeted by attackers due to:
- Weak or absent detection capabilities  
- Poor logging  
- No defined escalation paths  
- No formal incident plan  
- No lessons-learned process  
- Heavy reliance on MSPs with unclear responsibilities  

This toolkit provides **simple, low-cost, practical IR readiness building blocks** that SMEs can adopt immediately.

---

## 🎯 What This Toolkit Provides
### **1. IR Readiness Self-Assessment**
A structured questionnaire (Excel + Markdown) and an automated scoring script that evaluates:
- Preparation
- Detection
- Containment
- Eradication
- Recovery
- Lessons Learned

The output helps SMEs understand their current maturity level and identify priority gaps.

---

### **2. IR Documentation Templates**
Professionally structured, audit-ready templates:
- Incident Response Plan  
- RACI Matrix (Roles & Responsibilities)  
- Critical Contacts List  
- Incident Logbook  
- After-Action Report (AAR)

All templates are SME-friendly and require minimal customisation.

---

### **3. Low-Cost Technical Checks**
Simple Python and PowerShell scripts to help SMEs identify high-risk misconfigurations:
- **Mailbox rule abuse detection** (M365)  
- **External email forwarding checks**  
- **Admin role + MFA enforcement checks**  
- **Basic Windows logging readiness**  
- **SPF/DKIM/DMARC posture check** for email security  

These are intentionally lightweight and do not require premium licensing.

---

### **4. Reporting Outputs**
Assessment results can be exported as:
- Markdown summary  
- CSV  
- JSON (future roadmap)  
- PDF (future roadmap)

---
### **📦 5. Automated Setup & Execution Script

The toolkit includes a one-stop orchestration script that runs all core technical checks and generates a full readiness report bundle.

run_ir_toolkit_setup.ps1


This script is designed for SMEs, IT admins, and auditors to quickly assess Microsoft 365 and Windows endpoint readiness with minimal manual steps.

### **🚀 What the Script Does

When executed from the repository root, the script automatically:

Creates a ./reports folder (if not present)


Optionally installs required dependencies

PowerShell modules:

ExchangeOnlineManagement

MSOnline

Python package:

dnspython

Runs all core readiness checks

### ** Mailbox Rule Scanner → Detects BEC indicators

Output: MailboxRulesReport.csv

### ** MFA & Admin Role Check → Finds admin accounts without MFA

Output: MFA_AdminRole_Report.csv

### ** Windows Logging Readiness Check → Verifies audit/logging posture

Output: WindowsLoggingReadinessReport.csv

### ** Email Authentication Check (SPF/DMARC/DKIM)

Output: Email_Auth_Posture_Report.csv

All results are saved to the ./reports folder.

### **🧭 Usage
Basic run (recommended)
.\run_ir_toolkit_setup.ps1 -Domain example.com


Install all required dependencies automatically
.\run_ir_toolkit_setup.ps1 -Domain example.com -InstallDependencies


Specify a custom Python path (optional)
.\run_ir_toolkit_setup.ps1 -Domain example.com -PythonPath "C:\Python311\python.exe"

📁 Generated Outputs

After running, you will find the following reports in:

./reports


MailboxRulesReport.csv

MFA_AdminRole_Report.csv

WindowsLoggingReadinessReport.csv

Email_Auth_Posture_Report.csv


These reports can be fed directly into:

Your IR maturity score

Management dashboards

Audit evidence packs

Gaps & remediation planning

ISO 27001 / Cyber Essentials / NIST CSF readiness documentation


