#!/usr/bin/env python3
"""
score_ir_readiness.py

Simple scoring engine for the SME IR Readiness Questionnaire.

Usage:
    python score_ir_readiness.py --input responses.csv --output report.md

Expected input format (CSV):
    question_id,score
    1,2
    2,3
    3,1
    ...

- question_id: integer from 1 to 34 (see questionnaire)
- score: integer 0–3
    0 = Not in place
    1 = Partially in place
    2 = Mostly in place
    3 = Fully in place

The script will:
- Validate scores
- Calculate per-category and overall scores
- Normalise to a 30-point maturity scale
- Determine maturity level (Initial / Basic / Intermediate / Advanced)
- Print a human-readable summary to stdout
- Optionally save a Markdown report if --output is provided
"""

import argparse
import csv
import sys
from dataclasses import dataclass, field
from typing import Dict, List, Tuple

# Category mapping based on questionnaire
CATEGORY_MAP = {
    # 1. Preparation & Governance (Q1–7)
    **{q: "Preparation & Governance" for q in range(1, 8)},
    # 2. Detection & Reporting (Q8–14)
    **{q: "Detection & Reporting" for q in range(8, 15)},
    # 3. Containment (Q15–18)
    **{q: "Containment" for q in range(15, 19)},
    # 4. Eradication (Q19–22)
    **{q: "Eradication" for q in range(19, 23)},
    # 5. Recovery (Q23–27)
    **{q: "Recovery" for q in range(23, 28)},
    # 6. Lessons Learned (Q28–31)
    **{q: "Lessons Learned" for q in range(28, 32)},
    # 7. Optional Advanced Controls (Q32–34)
    **{q: "Advanced Controls" for q in range(32, 35)},
}

MIN_Q_ID = 1
MAX_Q_ID = 34
MIN_SCORE = 0
MAX_SCORE = 3


@dataclass
class CategoryScore:
    name: str
    total: int = 0
    max_total: int = 0
    questions: List[int] = field(default_factory=list)

    @property
    def percentage(self) -> float:
        if self.max_total == 0:
            return 0.0
        return round((self.total / self.max_total) * 100, 1)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Score SME IR Readiness Questionnaire.")
    parser.add_argument(
        "--input",
        "-i",
        required=True,
        help="Path to CSV file with columns: question_id,score",
    )
    parser.add_argument(
        "--output",
        "-o",
        required=False,
        help="Optional path to save a Markdown report.",
    )
    return parser.parse_args()


def read_responses(path: str) -> Dict[int, int]:
    scores: Dict[int, int] = {}
    try:
        with open(path, newline="", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            expected_cols = {"question_id", "score"}
            if not expected_cols.issubset(reader.fieldnames or []):
                raise ValueError(
                    f"Input CSV must contain columns: {', '.join(sorted(expected_cols))}. "
                    f"Found: {reader.fieldnames}"
                )
            for row in reader:
                try:
                    q_id = int(row["question_id"])
                    score = int(row["score"])
                except (ValueError, TypeError):
                    raise ValueError(f"Invalid data row: {row}")

                if q_id < MIN_Q_ID or q_id > MAX_Q_ID:
                    raise ValueError(f"Question ID out of range (1–34): {q_id}")
                if score < MIN_SCORE or score > MAX_SCORE:
                    raise ValueError(f"Score for Q{q_id} out of range (0–3): {score}")

                scores[q_id] = score
    except FileNotFoundError:
        print(f"Error: input file not found: {path}", file=sys.stderr)
        sys.exit(1)

    if not scores:
        raise ValueError("No responses found in the input file.")
    return scores


def build_category_scores(responses: Dict[int, int]) -> Dict[str, CategoryScore]:
    categories: Dict[str, CategoryScore] = {}

    # Initialise categories with all questions (even if unanswered, treated as 0)
    for q_id in range(MIN_Q_ID, MAX_Q_ID + 1):
        cat_name = CATEGORY_MAP.get(q_id, "Uncategorised")
        if cat_name not in categories:
            categories[cat_name] = CategoryScore(name=cat_name)
        cat = categories[cat_name]
        cat.questions.append(q_id)
        cat.max_total += MAX_SCORE

    # Add actual scores
    for q_id, score in responses.items():
        cat_name = CATEGORY_MAP.get(q_id, "Uncategorised")
        categories[cat_name].total += score

    return categories


def compute_overall_score(categories: Dict[str, CategoryScore]) -> Tuple[int, int, float]:
    total = sum(cat.total for cat in categories.values())
    max_total = sum(cat.max_total for cat in categories.values())
    if max_total == 0:
        return 0, 0, 0.0
    normalized = round((total / max_total) * 30, 1)  # normalize to 30-point scale
    return total, max_total, normalized


def classify_maturity(normalized_score: float) -> str:
    if normalized_score <= 10:
        return "Initial"
    elif 10 < normalized_score <= 18:
        return "Basic"
    elif 18 < normalized_score <= 25:
        return "Intermediate"
    else:
        return "Advanced"


def generate_markdown_report(
    categories: Dict[str, CategoryScore],
    total: int,
    max_total: int,
    normalized: float,
    maturity: str,
) -> str:
    lines: List[str] = []
    lines.append("# Incident Response Readiness Report")
    lines.append("")
    lines.append(f"**Overall Score:** {total} / {max_total}")
    lines.append(f"**Normalised Score (0–30):** {normalized}")
    lines.append(f"**Maturity Level:** **{maturity}**")
    lines.append("")
    lines.append("## Category Breakdown")
    lines.append("")
    lines.append("| Category | Score | Max | % |")
    lines.append("|----------|-------|-----|----|")

    # Consistent order
    order = [
        "Preparation & Governance",
        "Detection & Reporting",
        "Containment",
        "Eradication",
        "Recovery",
        "Lessons Learned",
        "Advanced Controls",
    ]
    for cat_name in order:
        cat = categories.get(cat_name)
        if not cat:
            continue
        lines.append(
            f"| {cat.name} | {cat.total} | {cat.max_total} | {cat.percentage}% |"
        )

    lines.append("")
    lines.append("## Interpretation")
    lines.append("")
    lines.append("- **Initial (0–10):** Ad-hoc response, high risk of prolonged incidents.")
    lines.append("- **Basic (11–18):** Some processes exist, but response is mostly reactive.")
    lines.append("- **Intermediate (19–25):** Documented IR processes with regular checks.")
    lines.append("- **Advanced (26–30):** Proactive, repeatable incident response capability.")

    lines.append("")
    lines.append("## Suggested Next Steps")
    lines.append("")
    if maturity == "Initial":
        lines.append("- Establish a basic Incident Response Plan and assign clear roles.")
        lines.append("- Enable logging on key systems and train staff to report suspicious activity.")
    elif maturity == "Basic":
        lines.append("- Formalise incident procedures for containment, eradication, and recovery.")
        lines.append("- Introduce regular mailbox rule checks, MFA enforcement, and basic monitoring.")
    elif maturity == "Intermediate":
        lines.append("- Conduct at least one annual tabletop exercise.")
        lines.append("- Improve centralised logging and monitoring of privileged accounts.")
    else:  # Advanced
        lines.append("- Refine automation and orchestration where possible.")
        lines.append("- Continuously review lessons learned and feed them into policy updates.")

    return "\n".join(lines)


def main() -> None:
    args = parse_args()
    responses = read_responses(args.input)
    categories = build_category_scores(responses)
    total, max_total, normalized = compute_overall_score(categories)
    maturity = classify_maturity(normalized)

    # Print human-readable summary
    print("=== Incident Response Readiness Score ===")
    print(f"Total score: {total} / {max_total}")
    print(f"Normalised (0–30): {normalized}")
    print(f"Maturity level: {maturity}")
    print("\nCategory breakdown:")
    for cat_name, cat in categories.items():
        print(f" - {cat.name}: {cat.total} / {cat.max_total} ({cat.percentage}%)")

    # Optionally write Markdown report
    if args.output:
        report_md = generate_markdown_report(categories, total, max_total, normalized, maturity)
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(report_md)
        print(f"\nMarkdown report written to: {args.output}")


if __name__ == "__main__":
    main()
