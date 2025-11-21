# USA Data Breach Notification Checklist
This checklist helps U.S.-based organisations determine whether a data breach requires notification under applicable federal or state laws.

It covers:
- Common breach triggers across U.S. states  
- Information typically requiring notification  
- Required timelines  
- Whom to notify (individuals, regulators, AG offices, media, credit bureaus)  
- Documentation requirements  

---

# 1. Determine Whether a Breach Occurred
## ✔ Step 1 — Identify the Incident
- ☐ Was personal data accessed, acquired, used, or disclosed without authorisation?  
- ☐ Was personal data altered, destroyed, or exfiltrated?  
- ☐ Did an external attacker or an internal party cause the incident?  
- ☐ Are systems or accounts compromised?

If **YES** to any: proceed to Step 2.

---

# 2. Assess Whether the Data Involved Is “Personal Information”
Most U.S. state laws define “personal information” as:

## ✔ Personal Identifiers + Sensitive Elements
Check if the incident involved:

### Personal Identifiers
- ☐ Name (first + last name)
- ☐ Address  
- ☐ Phone number  
- ☐ Email address  

### Sensitive Elements (if linked to an individual)
- ☐ Social Security Number  
- ☐ Driver’s license or state ID number  
- ☐ Passport number  
- ☐ Financial account number (with or without access codes)  
- ☐ Credit/debit card number  
- ☐ Medical/health information  
- ☐ Insurance policy number  
- ☐ Biometric identifiers  
- ☐ Username + password combination  
- ☐ Online account credentials  

If the exposed data includes both a **personal identifier + sensitive element**, most states require notification.

---

# 3. Assess Whether Data Was “Acquired” or “Reasonably Believed to Be Acquired”
Questions to determine acquisition:

- ☐ Was the data downloaded, exfiltrated, or copied?  
- ☐ Was an account accessed by an unauthorized party?  
- ☐ Did logs show unusual access patterns?  
- ☐ Were credentials compromised (phishing, brute force, token theft)?  
- ☐ Did the attacker open, modify, or delete records?  
- ☐ Was malware or ransomware present?

If **reasonable likelihood** of access/acquisition → notification is usually required.

---

# 4. Determine Whether Encryption Prevents Notification
Most states **do NOT require notification** if the exposed data was:

- ☐ Encrypted  
- ☐ Unreadable  
- ☐ Redacted  
- ☐ Secured by a method preventing meaningful access  

BUT notification may still be required if:

- ☐ Encryption keys were also compromised  
- ☐ Login credentials to encrypted systems were stolen  

---

# 5. Mandatory Notification Timelines
Most U.S. states require notification within:

### ✔ **30–45 days** (typical)
- ☐ Confirm timeline applicable to your state  
- ☐ Start internal clock immediately  

### Faster timelines under specific laws:
- **HIPAA**: within 60 days  
- **GLBA (financial institutions)**: as soon as possible  
- **FTC Health Breach Rule**: within 60 days  

Some states require **immediate** notification to regulators if certain thresholds are met (e.g., > 500 residents affected).

---

# 6. Who Must Be Notified?
You may need to notify multiple stakeholders.

## ✔ 6.1 Affected Individuals (Most states require this)
Notifications must include:
- ☐ Description of the incident  
- ☐ Types of information affected  
- ☐ Steps individuals should take  
- ☐ Actions taken by the organisation  
- ☐ Contact number or helpline  
- ☐ Credit/identity monitoring information (if offered)  

---

## ✔ 6.2 State Attorney General (Applies when thresholds are met)
Many states require notifying the **Attorney General** IF:

- ☐ The breach affects more than a certain number of residents (typically > 500)  
- ☐ The breach is large enough to trigger regulatory oversight  
- ☐ Sensitive data was exposed  

Notification may require:
- Incident summary  
- Security measures in place  
- Number of affected individuals  
- Steps taken to contain the breach  

---

## ✔ 6.3 State Consumer Protection Agencies
Some states require additional reporting.

Checklist:
- ☐ Determine if your state mandates consumer agency notification  
- ☐ Submit standard breach report where required  

---

## ✔ 6.4 Media Notification (Large breaches)
Required in some states if:

- ☐ Breach affects 1,000+ residents  
- ☐ Public awareness is needed for safety  

---

## ✔ 6.5 Credit Bureaus (Equifax, Experian, TransUnion)
Notify credit bureaus if:

- ☐ More than 1,000 individuals are affected  
- ☐ The breach involves SSNs, financial data, or identity theft risk  

---

## ✔ 6.6 Cyber Insurance Provider
If insured:

- ☐ Notify carrier immediately (often < 24 hours)  
- ☐ Follow policy requirements for IR, forensics, and notification  
- ☐ Use approved panel vendors only  

---

## ✔ 6.7 Federal Authorities (when applicable)
Some incidents require federal reporting:

### FBI (IC3)
- ☐ Report ransomware, business email compromise, fraud

### CISA
- ☐ Report significant cyber incidents for critical infrastructure sectors

### US Secret Service CFTF
- ☐ Report financial/cyber fraud impacting payments  

---

# 7. Additional Industry-Specific Laws
Check if your organisation is subject to:

- ☐ **HIPAA** (healthcare)  
- ☐ **GLBA** (financial services)  
- ☐ **FERPA** (education)  
- ☐ **COPPA** (children’s data)  
- ☐ **PCI-DSS** (card data)  

These may impose **stricter timelines and requirements**.

---

# 8. Documentation Requirements
For audit and legal protection, document:

- ☐ Full incident timeline  
- ☐ Evidence collected (logs, alerts, emails, system snapshots)  
- ☐ Root cause analysis  
- ☐ Data affected and impact assessment  
- ☐ Containment and remediation actions  
- ☐ Notification decision-making process  
- ☐ Copies of notifications sent  
- ☐ Post-incident improvements  

Maintain records for **at least 3–6 years** (HIPAA requires 6 years).

---

# 9. Decision Matrix (Quick Summary)

| Question | Yes | No |
|---------|-----|-----|
| Was unencrypted personal information involved? | → Notify | → No notification |
| Was the data accessed or reasonably believed to be accessed? | → Notify | → Assess further |
| Did encryption keys remain secure? | → Possibly no notification | → Notification required |
| Did the breach affect >500 individuals? | → Notify AG & credit bureaus | → Individuals only |
| Does federal law apply (HIPAA/GLBA/FTC)? | → Follow federal timelines | — |

---

# 10. Final Steps Before Closing the Breach
- ☐ Conduct an After-Action Report (AAR)  
- ☐ Review incident root cause  
- ☐ Update policies/procedures  
- ☐ Improve security controls  
- ☐ Confirm state + federal timelines were met  
- ☐ Log all decisions and notify executives  

---

# Notes
This checklist complements:  
- `After_Action_Report_Template.docx`  
- `Incident_Logbook_Template.xlsx`  
- `Critical_Contacts_USA_Template.xlsx`  
- `Incident Response Plan (IRP)`  

It is intentionally simplified for SMEs, while reflecting the common structure of U.S. breach notification laws.

