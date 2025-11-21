# Incident Response Plan (IRP)
**Organisation Name:** ____________________________  
**Version:** 1.0  
**Last Reviewed:** ________________________________  
**Approved By:** __________________________________  

---

# 1. Purpose
This Incident Response Plan (IRP) establishes the processes and responsibilities necessary to **detect, respond to, contain, eradicate, and recover from cybersecurity incidents** affecting the organisation.  
The goal is to ensure incidents are handled in a **controlled, consistent, and timely** manner to minimise impact on business operations, data, customers, and regulatory obligations.

---

# 2. Scope
This plan applies to:
- All employees, contractors, and third parties  
- All business systems, networks, cloud services, and data assets  
- All incidents including (but not limited to):  
  - Malware infections  
  - Phishing/account compromise  
  - Unauthorised access  
  - Data loss or data leakage  
  - Denial of service  
  - Insider misuse  
  - Device theft/loss  
  - Misconfigurations affecting security  

---

# 3. Definitions
**Security Incident**  
Any event that compromises the **confidentiality, integrity, or availability** of systems, data, or services.

**Major Incident**  
An incident that:  
- Impacts critical systems or data  
- Involves personal data breaches  
- Interrupts business operations  
- Has potential regulatory, legal, or financial consequences  

**Personal Data Breach (GDPR)**  
A breach leading to accidental or unlawful destruction, loss, alteration, unauthorised disclosure of, or access to personal data.

---

# 4. Roles & Responsibilities

## **4.1 Incident Response Lead (IR Lead)**
- Coordinates IR activities  
- Authorises containment actions  
- Maintains incident log  
- Escalates to senior leadership when required  

## **4.2 IT / Technical Response Team**
- Investigates root cause  
- Executes containment and remediation steps  
- Collects and preserves evidence  
- Restores affected systems  

## **4.3 Senior Management**
- Approves major decisions  
- Leads communication with external stakeholders  
- Supports resourcing and escalation  

## **4.4 Data Protection Officer (DPO) / Compliance Lead**
- Assesses regulatory impact (e.g., GDPR)  
- Advises on breach notification requirements  
- Coordinates with ICO or other regulators  

## **4.5 Third-Party MSP / Vendors**
*(If applicable)*  
- Provides technical investigation support  
- Responsible for systems under their management  
- Provides evidence or logs as requested  

## **4.6 Communications Lead**
- Manages internal and external communication  
- Ensures accurate, controlled messaging  

---

# 5. Incident Severity Levels
Use the following severity scale to classify incidents:

| Level | Description | Examples |
|-------|-------------|----------|
| **Low** | Minor incident, limited to one user, no sensitive data exposure | Single malware detection, spam/phishing click |
| **Medium** | Potential impact on multiple users/systems | Localised system compromise, suspicious activity |
| **High** | Significant disruption; possible data exposure | Confirmed account compromise, ransomware on single endpoint |
| **Critical** | Major impact on business operations or data | Widespread outage, confirmed data breach, ransomware spread |

---

# 6. Incident Response Lifecycle

The organisation follows a **6-phase IR lifecycle** aligned with ISO 27035 and NIST CSF Respond/Recover.

---

## **6.1 Phase 1 — Identification & Reporting**
### Trigger Events
An incident may be identified through:
- User reports  
- Security alerts (AV, EDR, M365, firewall)  
- Unusual account activity  
- External notifications (vendors, customers, regulators)

### Required Actions
1. Report incident to: **[IR Lead Name]**  
2. Create initial entry in the **Incident Logbook**  
3. Gather initial facts:
   - Who reported the incident?  
   - What happened?  
   - When was it discovered?  

4. Classify severity level (Low/Med/High/Critical)

---

## **6.2 Phase 2 — Containment**
Goal: Stop the incident from spreading.

### Short-Term Containment Actions
- Disconnect affected device(s) from network  
- Disable affected user accounts  
- Block malicious IPs, URLs, or domains  
- Remove malicious mailbox rules  
- Revoke access tokens for compromised accounts  

### Long-Term Containment
- Patch vulnerable systems  
- Apply configuration fixes  
- Increase logging & monitoring  

---

## **6.3 Phase 3 — Eradication**
Goal: Remove root cause and eliminate attacker presence.

### Required Actions
- Remove malware or malicious artefacts  
- Delete malicious mailbox rules  
- Remove unauthorised third-party OAuth applications  
- Reset passwords and enforce MFA  
- Identify root cause (phishing, unpatched system, credential theft)  

All actions must be logged in the **Incident Logbook**.

---

## **6.4 Phase 4 — Recovery**
Goal: Restore business operations safely.

### Required Actions
- Restore clean backups if necessary  
- Re-image devices if compromised  
- Validate system integrity  
- Monitor affected accounts/systems for reoccurrence  
- Re-enable accounts after verification  
- Inform users once systems are safe to use  

---

## **6.5 Phase 5 — Lessons Learned**
Must be completed **within 7–14 days** of a major incident.

### Required Actions
- Complete an **After-Action Report (AAR)**  
- Identify what worked and what failed  
- List corrective actions and assign owners  
- Update IR Plan, processes, or training as needed  
- Present findings to management  

---

# 7. Evidence Preservation
To support investigations or legal/regulatory requirements:
- Do NOT shut down systems prematurely (unless required to contain spread)  
- Preserve logs, emails, audit trails, screenshots, and artefacts  
- Save forensic copies if possible (low cost = logical copies)  
- Store evidence in a secure, access-controlled folder  

---

# 8. Communication Plan

## **8.1 Internal Communication**
- Notify affected teams and management  
- Provide clear, factual updates  
- Avoid speculation or blame  

## **8.2 External Communication**
Handled ONLY by:  
- Communications Lead  
- Senior Management  
- DPO (for regulatory bodies)  

### External Parties May Include:
- Regulators (e.g., **ICO** for GDPR breaches)  
- Customers affected  
- Cyber insurance provider  
- Law enforcement  
- Third-party vendors  

---

# 9. Regulatory & Legal Considerations

## **GDPR (if personal data involved)**
Report to ICO within **72 hours** if:
- There is a risk to individuals  
- Personal data was accessed, altered, lost, or exfiltrated  

DPO must document:
- What happened  
- What data was affected  
- Risk assessment  
- Mitigation actions  

### Other considerations:
- Contractual obligations  
- Sector-based regulations  

---

# 10. Tools & Resources Required
Low-cost tools recommended:
- Built-in antivirus / Microsoft Defender  
- M365 admin portal security alerts  
- PowerShell scripts (mailbox rules, MFA checks)  
- Backups (cloud or offline)  
- Basic log retention (Windows Event Logs, M365 unified audit log)  
- This IR readiness toolkit  

---

# 11. Training & Awareness
- All employees must receive basic security awareness training annually  
- Staff must know how to report suspicious activity  
- Conduct at least **one tabletop exercise per year**  

---

# 12. Plan Maintenance
This IR Plan must be:
- Reviewed **annually**  
- Updated after major incidents  
- Approved by management  
- Re-issued to relevant staff  

---

# 13. Document History

| Version | Date | Changes | Author | Approved By |
|---------|------|----------|--------|-------------|
| 1.0 | ______ | Initial version | _______ | _______ |

