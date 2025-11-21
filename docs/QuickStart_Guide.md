# SME IR Readiness Toolkit — QuickStart Guide

## 1. Complete the IR Readiness Questionnaire
Fill the 34-question assessment and save responses:

```
question_id,score
1,2
2,3
...
34,3
```

Scores:
- **0** = Not in place  
- **1** = Partial  
- **2** = Mostly  
- **3** = Fully  

---

## 2. Score Your IR Readiness
Run:

```
python score_ir_readiness.py --input responses.csv --output report.md
```

Outputs:
- Maturity score (0–30)
- Category breakdown
- Recommendations
- Markdown report

---

## 3. Generate a Governance RACI Matrix
Edit:

```
data/raci_input.yaml
```

Run:

```
python build_raci_from_yaml.py --input data/raci_input.yaml --output raci_matrix.xlsx
```

---

## 4. Run Technical Readiness Checks

### (a) Mailbox Rule Scanner — BEC Detection
```
.\m365_mailbox_rules.ps1 -AllMailboxes
```

### (b) MFA + Admin Role Checker
```
.\m365_mfa_admin_check.ps1
```

### (c) Windows Logging Baseline Check
```
.\windows_logging_readiness.ps1
```

### (d) Email Authentication (SPF/DMARC/DKIM)
```
python email_dmarc_spf_checker.py --domain example.com
```

---

## 5. Use Templates to Formalise IR Capability
- Incident Response Plan  
- Critical Contacts List  
- Incident Logbook  
- After-Action Report  
- Breach Notification Checklist  
- Logging Baseline  

---

## 6. Next Steps
- Conduct a tabletop exercise  
- Patch gaps based on readiness score  
- Re-run checks monthly/quarterly  
- Implement corrective controls  
