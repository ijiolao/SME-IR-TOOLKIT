# SME Incident Response (IR) Readiness Model

This IR Readiness Model provides a structured maturity scale tailored specifically for **Small and Medium-Sized Enterprises (SMEs)**.  
It evaluates the organisation’s preparedness across the *entire incident lifecycle* using practical, low-cost, achievable criteria.

The model consists of **four maturity levels**, mapped to ~30 controls across:
- Preparation  
- Detection  
- Containment  
- Eradication  
- Recovery  
- Lessons Learned  

---

# 🎯 Maturity Levels

## **Level 0 — Initial (0–10 points)**
**Characteristics:**
- No documented IR plan  
- No defined roles or responsibilities  
- Detection is ad-hoc  
- Logging is minimal or disabled  
- No consistent process for containment or recovery  
- Incidents are handled reactively  
- Heavy dependence on external MSPs without formal agreements  

**Risk:**  
High likelihood of prolonged downtime and incomplete recovery; high risk of repeated incidents.

---

## **Level 1 — Basic (11–18 points)**
**Characteristics:**
- Some elements of IR exist but are inconsistent or incomplete  
- Basic IR plan or checklist may exist  
- Users know how to report phishing or suspicious activity  
- MFA enabled for most users  
- Basic mailbox rule checks performed occasionally  
- Containment steps understood informally (e.g., disable account, disconnect device)  
- Backups exist but not regularly tested  

**Risk:**  
Moderate; response will still be slow or inconsistent. Suitable starting point for many SMEs.

---

## **Level 2 — Intermediate (19–25 points)**
**Characteristics:**
- IR Plan documented & accessible  
- Defined roles via RACI Matrix  
- Central IR contacts list maintained  
- Logging enabled on key systems  
- Routine checks: mailbox rules, MFA, privileged roles  
- Repeatable containment actions documented  
- Documented recovery workflows (password reset, re-imaging, restore)  
- Regular IR review (annual)  
- Conduct at least one tabletop exercise per year  

**Risk:**  
Reduced risk; incidents are handled in a reliable and repeatable manner.  
Suitable for SMEs with moderate cyber maturity.

---

## **Level 3 — Advanced (26–30+ points)**
**Characteristics:**
- Fully documented IR framework aligned with ISO 27001 / NIST CSF  
- Automated detection for common threats (M365 alerts, AV/EDR)  
- Logs centralised or forwarded to low-cost SIEM/cloud store  
- Privileged accounts closely monitored  
- Multi-step containment & eradication processes with decision trees  
- Post-incident root cause analysis completed for all major incidents  
- Strong lessons-learned culture (improvements tracked & owned)  
- Annual testing + periodic scenario-based tabletop exercises  

**Risk:**  
Significantly reduced; able to respond quickly and contain most threats before material damage occurs.

---

# 🔄 Lifecycle Mappings

The IR Readiness Model covers the full lifecycle:

| IR Phase | Description | Covered Controls |
|---------|-------------|------------------|
| Preparation | Plans, roles, contacts, governance | Q1–7 |
| Detection | Logging, alerts, monitoring, reporting | Q8–14 |
| Containment | Steps to stop spread, isolate assets | Q15–18 |
| Eradication | Removing malware, rules, tokens, persistence | Q19–22 |
| Recovery | Restoring systems, backups, notifications | Q23–27 |
| Lessons Learned | AAR, improvements, retesting | Q28–31 |
| Advanced Controls | Privileged monitoring, central logs | Q32–34 |

---

# 📌 Scoring
- Each question = **0 to 3 points**
- Max score ≈ 90+, but maturity thresholds normalised to **30-point scale**

**Maturity Levels**  
- **0–10 → Initial**  
- **11–18 → Basic**  
- **19–25 → Intermediate**  
- **26–30+ → Advanced**  

---

# 🧪 Usage
This model is applied through:
- `ir_readiness_questionnaire.md`
- `ir_readiness_questionnaire.xlsx`
- Automated scoring script: `tools/assessor/score_ir_readiness.py` (v1.0)

It serves as the foundation of the SME IR Readiness Toolkit.
