# Mapping to ISO 27001, NIST CSF & Cyber Essentials
This document maps the SME IR Readiness Toolkit to relevant global cybersecurity frameworks:

- **ISO/IEC 27001:2022** (modern controls)
- **NIST Cybersecurity Framework (CSF) 1.1 / 2.0**
- **Cyber Essentials (UK)** (where applicable)

The toolkit aligns with major controls required for incident management across these frameworks, despite being built for SMEs with limited budget and staff.

---

# 📘 ISO 27001:2022 Mapping

## **A.5 – Information Security Policies**
| Toolkit Component | ISO 27001 Control |
|-------------------|-------------------|
| IR Plan Template | A.5.1 |

---

## **A.6 – Organisational Roles and Responsibilities**
| Toolkit Component | ISO 27001 Control |
|-------------------|-------------------|
| RACI Matrix | A.6.1 |
| Critical Contacts List | A.6.3 |

---

## **A.8 – Logging & Monitoring**
| Toolkit Component | ISO 27001 Control |
|-------------------|-------------------|
| Windows Logging Check | A.8.15 |
| M365 mailbox rule check | A.8.16 |
| MFA + admin check | A.8.2, A.8.4 |
| SPF/DKIM/DMARC checks | A.8.23 |

---

## **A.12 – Operations Security**
| Toolkit Component | Mapping |
|-------------------|---------|
| Malware removal steps (eradication) | A.12.2 |
| Application inventory | A.12.1 |

---

## **A.16 – Information Security Incident Management**
| Toolkit Component | ISO 27001 Control |
|-------------------|-------------------|
| IR Plan | A.16.1–A.16.4 |
| Incident Logbook | A.16.1, A.16.3 |
| After-Action Report | A.16.4 |
| IR Readiness Questionnaire | A.16.1 |
| Tabletop Exercise Recommendation | A.16.5 |

*A.16 is the core alignment; this toolkit strongly supports it.*

---

## **A.18 – Compliance**
| Toolkit Component | Control |
|-------------------|---------|
| Breach notification understanding (questionnaire Q34) | A.18.1 |

---

---

# 🔶 NIST Cybersecurity Framework (CSF) Mapping

NIST CSF functions:  
**Identify, Protect, Detect, Respond, Recover**

## **Identify (ID)**
| Toolkit Components | Relevant NIST Categories |
|--------------------|--------------------------|
| Asset inventory | ID.AM-1, ID.AM-2 |
| RACI roles | ID.GV-2 |
| Critical contacts | ID.AM-6 |

---

## **Protect (PR)**
| Tools/Features | NIST Category |
|----------------|----------------|
| MFA check | PR.AC-7 |
| Privileged account review | PR.AC-4 |
| User training | PR.AT-1 |

---

## **Detect (DE)**
| Component | NIST Category |
|-----------|----------------|
| Mailbox rule detection | DE.CM-1, DE.CM-7 |
| Logging readiness | DE.CM-7 |
| Alerting tools | DE.CM-1 |

---

## **Respond (RS)**
**This toolkit is strongest here.**

| Component | NIST Category |
|-----------|----------------|
| IR Plan | RS.RP-1 |
| Isolation procedures | RS.CO-2 |
| Account disable procedures | RS.MI-1 |
| Removing malicious OAuth/Mail rules | RS.MI-3 |
| Incident Logbook | RS.CO-3 |
| AAR Template | RS.IM-1, RS.IM-2 |

---

## **Recover (RC)**
| Component | NIST Category |
|-----------|----------------|
| Backup & restore processes | RC.RP-1 |
| Business restoration steps | RC.IM-1 |
| Post-incident communications | RC.CO-1 |

---

# 🇬🇧 Cyber Essentials Alignment (UK SMEs)

| Toolkit Feature | Alignment |
|-----------------|-----------|
| MFA/admin checks | User Access Control |
| Malware removal guidance | Malware Protection |
| SPF/DKIM/DMARC email checks | Secure Configuration |
| Logging readiness | Logging/Monitoring (not required but recommended) |

Cyber Essentials does **not** fully cover incident response, but this toolkit complements it well.

---

# 🧩 Summary of Alignment
| Toolkit Area | ISO 27001 | NIST CSF | Cyber Essentials |
|--------------|-----------|-----------|------------------|
| IR Plan | A.16.1–A.16.4 | RS.RP | — |
| Logging & Monitoring | A.8 | DE.CM | Recommended |
| Containment & Eradication | A.12 & A.16 | RS.MI | Partial |
| Roles & Responsibilities | A.6 | ID.GV | — |
| Lessons Learned | A.16.4 | RS.IM | — |
| Backups & Recovery | A.17 | RC | Partially via “malware protection” |

---

# 📌 Purpose of This Mapping
- Helps SMEs demonstrate compliance with major frameworks  
- Helps consultants, MSPs, and auditors use the toolkit in assessments  
- Supports the toolkit’s role in **governance, audit readiness, and regulatory alignment**

