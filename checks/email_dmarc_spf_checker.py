#!/usr/bin/env python3
"""
email_dmarc_spf_checker.py

Lightweight DNS-based checker for SPF and DMARC (and optional DKIM) records
for one or more domains.

Usage examples:
    python email_dmarc_spf_checker.py --domain example.com
    python email_dmarc_spf_checker.py --input domains.txt --output report.csv
    python email_dmarc_spf_checker.py --domain example.com --dkim-selector default

Features:
- Looks up SPF records (TXT with "v=spf1")
- Looks up DMARC records (_dmarc.<domain> TXT with "v=DMARC1")
- Optionally checks a DKIM record for a given selector (selector._domainkey.<domain>)
- Provides a simple "posture" assessment for each:
    - SPF: present/missing, ending with -all/~all/?all, use of include/mechanisms
    - DMARC: present/missing, p=none/quarantine/reject, rua/pct tags
- Outputs to stdout in a human-readable table
- Optionally writes CSV for further analysis

Dependencies:
    pip install dnspython
"""

import argparse
import csv
from dataclasses import dataclass, asdict
from typing import Optional, List, Dict

import dns.resolver


@dataclass
class DomainEmailPosture:
    domain: str
    spf_present: bool
    spf_record: str
    spf_assessment: str
    dmarc_present: bool
    dmarc_record: str
    dmarc_policy: str
    dmarc_assessment: str
    dkim_checked: bool
    dkim_selector: str
    dkim_present: bool
    dkim_record: str
    notes: str = ""


def lookup_txt_records(name: str) -> List[str]:
    """
    Lookup TXT records for a given DNS name using dnspython.
    Returns a list of TXT strings. If none, returns [].
    """
    try:
        answers = dns.resolver.resolve(name, "TXT")
        records = []
        for rdata in answers:
            # rdata.strings is deprecated; use .to_text()
            txt = rdata.to_text().strip('"')
            # Some records may include multiple quoted strings concatenated with spaces
            # e.g. "v=spf1" "include:example.com" "-all"
            txt = txt.replace('" "', " ")
            records.append(txt)
        return records
    except (dns.resolver.NXDOMAIN, dns.resolver.NoAnswer, dns.resolver.NoNameservers):
        return []
    except Exception:
        return []


def get_spf_record(domain: str) -> Optional[str]:
    txt_records = lookup_txt_records(domain)
    for rec in txt_records:
        if rec.lower().startswith("v=spf1"):
            return rec
    return None


def assess_spf(spf: Optional[str]) -> (bool, str, str):
    if not spf:
        return False, "", "No SPF record found."

    record = spf.strip()
    lower = record.lower()
    assessment_parts: List[str] = []

    if " -all" in lower:
        assessment_parts.append("Restrictive policy (-all).")
    elif " ~all" in lower:
        assessment_parts.append("Soft fail policy (~all). Consider -all if mature.")
    elif " ?all" in lower or "all" in lower:
        assessment_parts.append("Permissive 'all' mechanism. Review necessity.")

    if "include:" in lower:
        assessment_parts.append("Uses include mechanisms (check third-party senders).")
    if " ip4:" in lower or " ip6:" in lower:
        assessment_parts.append("Direct IP mechanisms configured.")
    if " redirect=" in lower:
        assessment_parts.append("Uses redirect (advanced configuration).")

    if not assessment_parts:
        assessment_parts.append("SPF present but could not derive specific guidance.")

    return True, record, " ".join(assessment_parts)


def parse_dmarc_tag(record: str) -> Dict[str, str]:
    """
    Parses a DMARC record into a dict of key->value.
    Example: "v=DMARC1; p=reject; rua=mailto:dmarc@example.com"
    """
    tags: Dict[str, str] = {}
    for part in record.split(";"):
        part = part.strip()
        if "=" in part:
            k, v = part.split("=", 1)
            tags[k.strip().lower()] = v.strip()
    return tags


def get_dmarc_record(domain: str) -> Optional[str]:
    name = f"_dmarc.{domain}"
    txt_records = lookup_txt_records(name)
    for rec in txt_records:
        if rec.lower().startswith("v=dmarc1"):
            return rec
    return None


def assess_dmarc(dmarc: Optional[str]) -> (bool, str, str, str):
    if not dmarc:
        return False, "", "", "No DMARC record found."

    record = dmarc.strip()
    tags = parse_dmarc_tag(record)
    policy = tags.get("p", "").lower()
    pct = tags.get("pct", "100")
    rua = tags.get("rua", "")

    assessment_parts: List[str] = []

    if policy == "none":
        assessment_parts.append("Monitoring-only DMARC policy (p=none). Consider quarantine/reject.")
    elif policy == "quarantine":
        assessment_parts.append("Quarantine policy in place (p=quarantine).")
    elif policy == "reject":
        assessment_parts.append("Strong enforcement policy (p=reject).")
    else:
        assessment_parts.append("DMARC policy missing or unrecognised; review required.")

    if rua:
        assessment_parts.append("Aggregate reporting (rua) configured.")
    else:
        assessment_parts.append("No aggregate reporting address (rua) configured.")

    if pct != "100":
        assessment_parts.append(f"DMARC applies to {pct}% of messages (pct={pct}).")

    return True, record, policy or "(not set)", " ".join(assessment_parts)


def get_dkim_record(domain: str, selector: Optional[str]) -> (bool, str, bool, str):
    if not selector:
        return False, "", False, ""
    name = f"{selector}._domainkey.{domain}"
    txt_records = lookup_txt_records(name)
    if not txt_records:
        return True, selector, False, ""
    # Just return the first DKIM-related record
    for rec in txt_records:
        if "v=DKIM1" in rec.upper():
            return True, selector, True, rec
    # If no explicit DKIM version but something exists
    return True, selector, True, txt_records[0]


def check_domain(domain: str, dkim_selector: Optional[str] = None) -> DomainEmailPosture:
    spf = get_spf_record(domain)
    spf_present, spf_record, spf_assessment = assess_spf(spf)

    dmarc = get_dmarc_record(domain)
    dmarc_present, dmarc_record, dmarc_policy, dmarc_assessment = assess_dmarc(dmarc)

    dkim_checked, dkim_sel, dkim_present, dkim_record = get_dkim_record(domain, dkim_selector)

    notes_parts: List[str] = []
    if not spf_present:
        notes_parts.append("SPF missing.")
    if not dmarc_present:
        notes_parts.append("DMARC missing.")
    if dmarc_present and dmarc_policy == "none":
        notes_parts.append("DMARC monitoring only (p=none).")
    if dkim_checked and not dkim_present:
        notes_parts.append(f"DKIM selector '{dkim_sel}' not found for this domain.")

    return DomainEmailPosture(
        domain=domain,
        spf_present=spf_present,
        spf_record=spf_record,
        spf_assessment=spf_assessment,
        dmarc_present=dmarc_present,
        dmarc_record=dmarc_record,
        dmarc_policy=dmarc_policy,
        dmarc_assessment=dmarc_assessment,
        dkim_checked=dkim_checked,
        dkim_selector=dkim_sel if dkim_checked else "",
        dkim_present=dkim_present,
        dkim_record=dkim_record,
        notes=" ".join(notes_parts),
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Check SPF/DMARC (and optional DKIM) posture for one or more domains.")
    parser.add_argument(
        "--domain",
        "-d",
        action="append",
        help="Domain name to check (can be used multiple times).",
    )
    parser.add_argument(
        "--input",
        "-i",
        help="Path to a text file with one domain per line.",
    )
    parser.add_argument(
        "--output",
        "-o",
        help="Optional CSV file path to export results.",
    )
    parser.add_argument(
        "--dkim-selector",
        help="Optional DKIM selector to check (e.g. 'default').",
    )
    return parser.parse_args()


def load_domains(args: argparse.Namespace) -> List[str]:
    domains: List[str] = []
    if args.domain:
        domains.extend(args.domain)
    if args.input:
        with open(args.input, "r", encoding="utf-8") as f:
            for line in f:
                d = line.strip()
                if d and not d.startswith("#"):
                    domains.append(d)
    # Deduplicate and normalise
    cleaned = sorted(set(d.lower() for d in domains if d))
    return cleaned


def print_human_report(results: List[DomainEmailPosture]) -> None:
    if not results:
        print("No domains to report.")
        return

    print("=" * 72)
    print("Email Authentication Posture Report (SPF / DMARC / DKIM)")
    print("=" * 72)
    for res in results:
        print(f"\nDomain: {res.domain}")
        print("-" * 72)
        print(f"SPF Present:   {res.spf_present}")
        if res.spf_present:
            print(f"SPF Record:    {res.spf_record}")
            print(f"SPF Assessment:{' ' if res.spf_assessment else ''}{res.spf_assessment}")
        else:
            print("SPF Record:    (none)")

        print(f"\nDMARC Present: {res.dmarc_present}")
        if res.dmarc_present:
            print(f"DMARC Record:  {res.dmarc_record}")
            print(f"DMARC Policy:  {res.dmarc_policy}")
            print(f"DMARC Assessment:{' ' if res.dmarc_assessment else ''}{res.dmarc_assessment}")
        else:
            print("DMARC Record:  (none)")

        if res.dkim_checked:
            print(f"\nDKIM Checked:  True (selector = {res.dkim_selector})")
            if res.dkim_present:
                print(f"DKIM Record:   {res.dkim_record}")
            else:
                print("DKIM Record:   (no DKIM record found for this selector)")
        else:
            print("\nDKIM Checked:  False (no selector provided)")

        if res.notes:
            print(f"\nNotes:         {res.notes}")
        print("-" * 72)


def export_csv(results: List[DomainEmailPosture], path: str) -> None:
    fieldnames = list(asdict(results[0]).keys())
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for r in results:
            writer.writerow(asdict(r))


def main() -> None:
    args = parse_args()
    domains = load_domains(args)

    if not domains:
        print("No domains provided. Use --domain or --input.")
        return

    results: List[DomainEmailPosture] = []
    for d in domains:
        try:
            res = check_domain(d, dkim_selector=args.dkim_selector)
            results.append(res)
        except Exception as e:
            print(f"Error checking domain {d}: {e}")

    print_human_report(results)

    if args.output and results:
        export_csv(results, args.output)
        print(f"\nCSV report written to: {args.output}")


if __name__ == "__main__":
    main()
