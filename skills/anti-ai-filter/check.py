#!/usr/bin/env python3
"""
Anti-AI Filter check script.

Mechanical evaluator that runs after the writer-agent returns a draft.
Replaces the vibes-based "final pass" — the agent can't claim to have run
this without actually invoking it.

Usage:
    python3 check.py <draft.md> --format <format-tier> [--voice-anchor <path>]

Format tiers:
    reddit-post-incident    5-15% caps target (lead with scene)
    reddit-post-essay       50-70% caps target (lead with claim)
    reddit-reply            5-15% caps target
    chat                    5-15% caps target
    blog-post               70-90% caps target
    longform                70-90% caps target
    marketing               85-95% caps target
    email                   70-90% caps target

Exit code 0 = pass, 1 = fail. Failures printed to stdout in structured form
the agent can parse and act on.
"""

import argparse
import re
import sys
from pathlib import Path

FORMAT_TIERS = {
    "reddit-post-incident": (5, 15),
    "reddit-post-essay": (50, 70),
    "reddit-reply": (5, 15),
    "chat": (5, 15),
    "casual-reply": (5, 15),
    "blog-post": (70, 90),
    "longform": (70, 90),
    "marketing": (85, 95),
    "landing": (85, 95),
    "email": (70, 90),
    "email-cold": (70, 90),
    "email-warm": (70, 90),
}

EM_DASH_BUDGET_PER_500_WORDS = 1


def read_file(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def strip_frontmatter(text: str) -> str:
    """Strip leading YAML frontmatter if present."""
    if text.startswith("---\n"):
        end = text.find("\n---\n", 4)
        if end != -1:
            return text[end + 5 :]
    return text


def get_body_paragraphs(text: str) -> list[str]:
    """Split into non-empty paragraphs (separated by blank lines)."""
    text = strip_frontmatter(text)
    paragraphs = re.split(r"\n\s*\n", text)
    # Skip headers, code blocks, frontmatter remnants
    body = []
    for p in paragraphs:
        p = p.strip()
        if not p:
            continue
        if p.startswith("#") or p.startswith("```") or p.startswith("|"):
            continue
        if p.startswith("---") or p == "---":
            continue
        body.append(p)
    return body


def count_sentence_starts(body_text: str) -> tuple[int, int, list[str]]:
    """Return (total_starts, capital_starts, examples_of_lowercase_starts)."""
    sentences = re.split(r"(?<=[.!?])\s+", body_text)
    sentences = [s.strip() for s in sentences if s.strip()]
    total = 0
    caps = 0
    lowercase_examples = []
    for s in sentences:
        if not s:
            continue
        first = s[0]
        if not first.isalpha():
            continue
        total += 1
        if first.isupper():
            caps += 1
        else:
            if len(lowercase_examples) < 3:
                lowercase_examples.append(s[:60] + ("..." if len(s) > 60 else ""))
    return total, caps, lowercase_examples


def check_phrase_blacklist(draft_body: str, blacklist_path: Path) -> list[str]:
    """Return list of blacklisted phrases found in the draft (case-insensitive)."""
    if not blacklist_path.exists():
        return []
    matches = []
    body_lower = draft_body.lower()
    for line in blacklist_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line.startswith("- "):
            continue
        phrase = line[2:].strip()
        # Strip surrounding quotes and trailing parenthetical
        phrase = phrase.strip('"').strip("'")
        phrase = re.sub(r"\s*\([^)]*\)\s*$", "", phrase)
        if not phrase or len(phrase) < 4:
            continue
        # Skip pattern entries (contain X / Y / [X] placeholders)
        if any(token in phrase for token in [" X ", " Y ", "[X]", "[Y]", "(X)", "(any"]):
            continue
        if phrase.lower() in body_lower:
            matches.append(phrase)
    return matches


def count_em_dashes(draft_body: str) -> int:
    return draft_body.count("—") + draft_body.count("–")


def check_voice_anchor_leak(draft_body: str, anchor_path: Path, min_words: int = 5) -> list[str]:
    """Return list of 5+ word substrings copied verbatim from voice anchor."""
    if not anchor_path.exists():
        return []
    anchor_text = strip_frontmatter(anchor_path.read_text(encoding="utf-8"))

    # Tokenize both into normalized words
    def normalize(text: str) -> list[str]:
        return re.findall(r"\b[\w']+\b", text.lower())

    anchor_words = normalize(anchor_text)
    draft_words = normalize(draft_body)

    # Build set of N-grams from anchor
    anchor_ngrams = set()
    for i in range(len(anchor_words) - min_words + 1):
        anchor_ngrams.add(" ".join(anchor_words[i : i + min_words]))

    # Scan draft for matches
    leaks = []
    for i in range(len(draft_words) - min_words + 1):
        ngram = " ".join(draft_words[i : i + min_words])
        if ngram in anchor_ngrams:
            leaks.append(ngram)
    return list(dict.fromkeys(leaks))  # Dedupe, preserve order


def check_rhythm(paragraphs: list[str]) -> list[str]:
    """Return list of paragraphs lacking at least one rambling sentence."""
    failures = []
    for i, p in enumerate(paragraphs):
        sentences = re.split(r"(?<=[.!?])\s+", p)
        rambling = False
        for s in sentences:
            words = re.findall(r"\b[\w']+\b", s)
            commas_without_breaks = s.count(",") - s.count(":") - s.count(";")
            if len(words) >= 60 or commas_without_breaks >= 3:
                rambling = True
                break
        if not rambling and len(p) > 200:  # Only flag substantial paragraphs
            failures.append(f"P{i+1}: {p[:80]}{'...' if len(p) > 80 else ''}")
    return failures


def main():
    parser = argparse.ArgumentParser(description="Anti-AI filter check")
    parser.add_argument("draft", type=Path, help="Path to draft file")
    parser.add_argument(
        "--format",
        required=True,
        choices=list(FORMAT_TIERS.keys()),
        help="Format tier (determines casing target)",
    )
    parser.add_argument("--voice-anchor", type=Path, help="Optional voice anchor file to check for leakage")
    parser.add_argument(
        "--blacklist",
        type=Path,
        default=Path(__file__).parent / "phrase-blacklist.md",
        help="Path to phrase-blacklist.md",
    )
    parser.add_argument(
        "--blacklist-local",
        type=Path,
        help="Optional path to phrase-blacklist-local.md",
    )
    args = parser.parse_args()

    if not args.draft.exists():
        print(f"ERROR: draft file not found: {args.draft}", file=sys.stderr)
        sys.exit(2)

    draft_text = read_file(args.draft)
    body = strip_frontmatter(draft_text)
    paragraphs = get_body_paragraphs(draft_text)
    body_text = "\n\n".join(paragraphs)
    word_count = len(re.findall(r"\b[\w']+\b", body_text))

    failures = []
    summary_lines = []

    print("=== Anti-AI Filter Check ===")
    print(f"Draft: {args.draft}")
    print(f"Format tier: {args.format}")
    print(f"Word count: {word_count}")
    print()

    # 1. Phrase blacklist
    blacklist_hits = check_phrase_blacklist(body_text, args.blacklist)
    if args.blacklist_local:
        blacklist_hits.extend(check_phrase_blacklist(body_text, args.blacklist_local))
    if blacklist_hits:
        print(f"PHRASE BLACKLIST: FAIL ({len(blacklist_hits)} matches)")
        for hit in blacklist_hits:
            print(f"  - {hit}")
        failures.append(f"phrase-blacklist: {len(blacklist_hits)} match(es)")
    else:
        print("PHRASE BLACKLIST: PASS")
    print()

    # 2. Casing
    target_min, target_max = FORMAT_TIERS[args.format]
    total_starts, caps_starts, lowercase_examples = count_sentence_starts(body_text)
    if total_starts == 0:
        pct = 0
    else:
        pct = round(100 * caps_starts / total_starts)
    print(f"CASING: target {target_min}-{target_max}% caps, measured {pct}% ({caps_starts}/{total_starts} starts)")
    if total_starts > 0 and (pct < target_min - 5 or pct > target_max + 5):
        print("  FAIL: outside target range")
        if pct < target_min:
            print(f"  needs: {(target_min - pct) * total_starts // 100 + 1} more capital sentence-start(s)")
        else:
            print(f"  needs: {(pct - target_max) * total_starts // 100 + 1} fewer capital sentence-start(s)")
        failures.append(f"casing: {pct}% (target {target_min}-{target_max}%)")
    elif total_starts > 0 and (pct < target_min or pct > target_max):
        print(f"  WARN: just outside target (within ±5pp tolerance)")
    else:
        print("  PASS")
    print()

    # 3. Em-dashes
    em_count = count_em_dashes(body_text)
    em_budget = max(1, word_count // 500)
    print(f"EM-DASHES: count={em_count}, budget={em_budget} (per {EM_DASH_BUDGET_PER_500_WORDS}/500 words)")
    if em_count > em_budget:
        print(f"  FAIL: over budget by {em_count - em_budget}")
        failures.append(f"em-dashes: {em_count} (budget {em_budget})")
    else:
        print("  PASS")
    print()

    # 4. Voice anchor leak
    if args.voice_anchor:
        leaks = check_voice_anchor_leak(body_text, args.voice_anchor)
        print(f"VOICE ANCHOR LEAK: {len(leaks)} match(es) ≥5 words")
        if leaks:
            for leak in leaks:
                print(f'  - "{leak}"')
            failures.append(f"voice-anchor-leak: {len(leaks)} 5+word match(es)")
        else:
            print("  PASS")
    else:
        print("VOICE ANCHOR LEAK: skipped (no --voice-anchor provided)")
    print()

    # 5. Rhythm
    rhythm_failures = check_rhythm(paragraphs)
    if rhythm_failures:
        print(f"RHYTHM: FAIL ({len(rhythm_failures)} paragraph(s) without rambling sentence)")
        for f in rhythm_failures:
            print(f"  - {f}")
        failures.append(f"rhythm: {len(rhythm_failures)} paragraph(s)")
    else:
        print("RHYTHM: PASS (all body paragraphs have ≥1 rambling sentence or are short)")
    print()

    # Overall
    if failures:
        print("=" * 40)
        print(f"OVERALL: FAIL ({len(failures)} issue(s))")
        for f in failures:
            print(f"  - {f}")
        print()
        print("Rewrite the draft to address each failure, then re-run this check.")
        sys.exit(1)
    else:
        print("=" * 40)
        print("OVERALL: PASS")
        sys.exit(0)


if __name__ == "__main__":
    main()
