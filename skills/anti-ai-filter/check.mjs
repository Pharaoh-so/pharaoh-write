#!/usr/bin/env node
/**
 * Anti-AI Filter check script.
 *
 * Mechanical evaluator that runs after the writer-agent returns a draft.
 * Replaces the vibes-based "final pass" - the agent can't claim to have run
 * this without actually invoking it.
 *
 * Zero dependencies. Uses only Node.js standard library. Anyone running
 * Claude Code already has Node, so nothing extra to install.
 *
 * Usage:
 *   node check.mjs <draft.md> --format <format-tier> [--voice-anchor <path>]
 *
 * Format tiers (caps target):
 *   reddit-post-incident   5-15%   (lead with scene)
 *   reddit-post-essay      50-70%  (lead with claim)
 *   reddit-reply           5-15%
 *   chat                   5-15%
 *   blog-post              70-90%
 *   longform               70-90%
 *   marketing              85-95%
 *   email                  70-90%
 *
 * Exit code 0 = pass, 1 = fail. Failures printed to stdout in structured
 * form the agent can parse and act on.
 */

import { readFileSync, existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));

const FORMAT_TIERS = {
  "reddit-post-incident": [5, 15],
  "reddit-post-essay": [50, 70],
  "reddit-reply": [5, 15],
  chat: [5, 15],
  "casual-reply": [5, 15],
  "blog-post": [70, 90],
  longform: [70, 90],
  marketing: [85, 95],
  landing: [85, 95],
  email: [70, 90],
  "email-cold": [70, 90],
  "email-warm": [70, 90],
};

// ---------------- arg parsing ----------------

function parseArgs(argv) {
  const args = { _: [], format: null, voiceAnchor: null, blacklist: null, blacklistLocal: null };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--format") args.format = argv[++i];
    else if (a === "--voice-anchor") args.voiceAnchor = argv[++i];
    else if (a === "--blacklist") args.blacklist = argv[++i];
    else if (a === "--blacklist-local") args.blacklistLocal = argv[++i];
    else if (a === "-h" || a === "--help") {
      printHelp();
      process.exit(0);
    } else args._.push(a);
  }
  return args;
}

function printHelp() {
  console.log(`Anti-AI Filter check

Usage: node check.mjs <draft.md> --format <tier> [--voice-anchor <path>]

Format tiers: ${Object.keys(FORMAT_TIERS).join(", ")}

Optional:
  --voice-anchor <path>     File to check for 5+ word verbatim copies
  --blacklist <path>        Override default phrase-blacklist.md path
  --blacklist-local <path>  Additional local blacklist to check`);
}

// ---------------- helpers ----------------

function readFile(path) {
  return readFileSync(path, "utf8");
}

function stripFrontmatter(text) {
  if (text.startsWith("---\n")) {
    const end = text.indexOf("\n---\n", 4);
    if (end !== -1) return text.slice(end + 5);
  }
  return text;
}

function getBodyParagraphs(text) {
  const stripped = stripFrontmatter(text);
  const paragraphs = stripped.split(/\n\s*\n/);
  const body = [];
  for (let p of paragraphs) {
    p = p.trim();
    if (!p) continue;
    if (p.startsWith("#") || p.startsWith("```") || p.startsWith("|")) continue;
    if (p.startsWith("---")) continue;
    body.push(p);
  }
  return body;
}

function countWords(text) {
  const matches = text.match(/\b[\w']+\b/g);
  return matches ? matches.length : 0;
}

function countSentenceStarts(bodyText) {
  const sentences = bodyText.split(/(?<=[.!?])\s+/).map((s) => s.trim()).filter(Boolean);
  let total = 0;
  let caps = 0;
  const lowercaseExamples = [];
  for (const s of sentences) {
    if (!s) continue;
    const first = s[0];
    if (!/[a-zA-Z]/.test(first)) continue;
    total++;
    if (first === first.toUpperCase()) caps++;
    else if (lowercaseExamples.length < 3) {
      lowercaseExamples.push(s.length > 60 ? s.slice(0, 60) + "..." : s);
    }
  }
  return { total, caps, lowercaseExamples };
}

function checkPhraseBlacklist(bodyText, blacklistPath) {
  if (!existsSync(blacklistPath)) return [];
  const matches = [];
  const bodyLower = bodyText.toLowerCase();
  const blacklist = readFile(blacklistPath).split("\n");
  for (let line of blacklist) {
    line = line.trim();
    if (!line.startsWith("- ")) continue;
    let phrase = line.slice(2).trim();
    // Strip surrounding quotes and trailing parenthetical
    phrase = phrase.replace(/^["']|["']$/g, "");
    phrase = phrase.replace(/\s*\([^)]*\)\s*$/, "");
    if (!phrase || phrase.length < 4) continue;
    // Skip pattern entries (placeholders)
    if (/[ (]X[ )]|[ (]Y[ )]|\[X\]|\[Y\]/.test(phrase)) continue;
    if (bodyLower.includes(phrase.toLowerCase())) matches.push(phrase);
  }
  return matches;
}

function countEmDashes(bodyText) {
  return (bodyText.match(/—/g) || []).length + (bodyText.match(/–/g) || []).length;
}

function checkVoiceAnchorLeak(bodyText, anchorPath, minWords = 5) {
  if (!existsSync(anchorPath)) return [];
  const anchorText = stripFrontmatter(readFile(anchorPath));

  function normalize(text) {
    return (text.toLowerCase().match(/\b[\w']+\b/g) || []);
  }

  const anchorWords = normalize(anchorText);
  const draftWords = normalize(bodyText);

  const anchorNgrams = new Set();
  for (let i = 0; i <= anchorWords.length - minWords; i++) {
    anchorNgrams.add(anchorWords.slice(i, i + minWords).join(" "));
  }

  const seen = new Set();
  const leaks = [];
  for (let i = 0; i <= draftWords.length - minWords; i++) {
    const ngram = draftWords.slice(i, i + minWords).join(" ");
    if (anchorNgrams.has(ngram) && !seen.has(ngram)) {
      seen.add(ngram);
      leaks.push(ngram);
    }
  }
  return leaks;
}

function checkRhythm(paragraphs) {
  const failures = [];
  for (let i = 0; i < paragraphs.length; i++) {
    const p = paragraphs[i];
    if (p.length <= 200) continue; // only flag substantial paragraphs

    const sentences = p.split(/(?<=[.!?])\s+/);
    let rambling = false;
    for (const s of sentences) {
      const words = countWords(s);
      const commas = (s.match(/,/g) || []).length;
      const breaks = (s.match(/[:;]/g) || []).length;
      const commasWithoutBreaks = commas - breaks;
      if (words >= 60 || commasWithoutBreaks >= 3) {
        rambling = true;
        break;
      }
    }
    if (!rambling) {
      const preview = p.length > 80 ? p.slice(0, 80) + "..." : p;
      failures.push(`P${i + 1}: ${preview}`);
    }
  }
  return failures;
}

// ---------------- main ----------------

function main() {
  const args = parseArgs(process.argv);

  if (args._.length === 0) {
    console.error("ERROR: missing draft file. Use --help for usage.");
    process.exit(2);
  }
  if (!args.format) {
    console.error("ERROR: --format is required. Use --help for usage.");
    process.exit(2);
  }
  if (!FORMAT_TIERS[args.format]) {
    console.error(
      `ERROR: unknown format "${args.format}". Choices: ${Object.keys(FORMAT_TIERS).join(", ")}`,
    );
    process.exit(2);
  }

  const draftPath = args._[0];
  if (!existsSync(draftPath)) {
    console.error(`ERROR: draft file not found: ${draftPath}`);
    process.exit(2);
  }

  const blacklistPath = args.blacklist || join(__dirname, "phrase-blacklist.md");
  const draftText = readFile(draftPath);
  const paragraphs = getBodyParagraphs(draftText);
  const bodyText = paragraphs.join("\n\n");
  const wordCount = countWords(bodyText);

  const failures = [];

  console.log("=== Anti-AI Filter Check ===");
  console.log(`Draft: ${draftPath}`);
  console.log(`Format tier: ${args.format}`);
  console.log(`Word count: ${wordCount}`);
  console.log();

  // 1. Phrase blacklist
  let blacklistHits = checkPhraseBlacklist(bodyText, blacklistPath);
  if (args.blacklistLocal) {
    blacklistHits = blacklistHits.concat(checkPhraseBlacklist(bodyText, args.blacklistLocal));
  }
  if (blacklistHits.length > 0) {
    console.log(`PHRASE BLACKLIST: FAIL (${blacklistHits.length} matches)`);
    for (const hit of blacklistHits) console.log(`  - ${hit}`);
    failures.push(`phrase-blacklist: ${blacklistHits.length} match(es)`);
  } else {
    console.log("PHRASE BLACKLIST: PASS");
  }
  console.log();

  // 2. Casing
  const [targetMin, targetMax] = FORMAT_TIERS[args.format];
  const { total, caps } = countSentenceStarts(bodyText);
  const pct = total === 0 ? 0 : Math.round((100 * caps) / total);
  console.log(
    `CASING: target ${targetMin}-${targetMax}% caps, measured ${pct}% (${caps}/${total} starts)`,
  );
  if (total > 0 && (pct < targetMin - 5 || pct > targetMax + 5)) {
    console.log("  FAIL: outside target range");
    if (pct < targetMin) {
      const need = Math.floor(((targetMin - pct) * total) / 100) + 1;
      console.log(`  needs: ${need} more capital sentence-start(s)`);
    } else {
      const need = Math.floor(((pct - targetMax) * total) / 100) + 1;
      console.log(`  needs: ${need} fewer capital sentence-start(s)`);
    }
    failures.push(`casing: ${pct}% (target ${targetMin}-${targetMax}%)`);
  } else if (total > 0 && (pct < targetMin || pct > targetMax)) {
    console.log("  WARN: just outside target (within ±5pp tolerance)");
  } else {
    console.log("  PASS");
  }
  console.log();

  // 3. Em-dashes
  const emCount = countEmDashes(bodyText);
  const emBudget = Math.max(1, Math.floor(wordCount / 500));
  console.log(`EM-DASHES: count=${emCount}, budget=${emBudget} (1 per 500 words)`);
  if (emCount > emBudget) {
    console.log(`  FAIL: over budget by ${emCount - emBudget}`);
    failures.push(`em-dashes: ${emCount} (budget ${emBudget})`);
  } else {
    console.log("  PASS");
  }
  console.log();

  // 4. Voice anchor leak
  if (args.voiceAnchor) {
    const leaks = checkVoiceAnchorLeak(bodyText, args.voiceAnchor);
    console.log(`VOICE ANCHOR LEAK: ${leaks.length} match(es) ≥5 words`);
    if (leaks.length > 0) {
      for (const leak of leaks) console.log(`  - "${leak}"`);
      failures.push(`voice-anchor-leak: ${leaks.length} 5+word match(es)`);
    } else {
      console.log("  PASS");
    }
  } else {
    console.log("VOICE ANCHOR LEAK: skipped (no --voice-anchor provided)");
  }
  console.log();

  // 5. Rhythm
  const rhythmFailures = checkRhythm(paragraphs);
  if (rhythmFailures.length > 0) {
    console.log(`RHYTHM: FAIL (${rhythmFailures.length} paragraph(s) without rambling sentence)`);
    for (const f of rhythmFailures) console.log(`  - ${f}`);
    failures.push(`rhythm: ${rhythmFailures.length} paragraph(s)`);
  } else {
    console.log("RHYTHM: PASS (all body paragraphs have ≥1 rambling sentence or are short)");
  }
  console.log();

  // Overall
  if (failures.length > 0) {
    console.log("=".repeat(40));
    console.log(`OVERALL: FAIL (${failures.length} issue(s))`);
    for (const f of failures) console.log(`  - ${f}`);
    console.log();
    console.log("Rewrite the draft to address each failure, then re-run this check.");
    process.exit(1);
  } else {
    console.log("=".repeat(40));
    console.log("OVERALL: PASS");
    process.exit(0);
  }
}

main();
