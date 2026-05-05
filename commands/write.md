---
description: Draft content using the writer-agent subagent. Takes a brief inline or by reference to a doc. Handles Reddit replies, blog posts, chat messages, cold DMs, landing sections, X posts, and email.
---

# /write - Content Writer

Invoke the `writer-agent` subagent to draft content.

## Usage

```
/write <brief>
```

The brief can be:
- **Inline text** describing what to write - e.g., "reply to this Reddit post [URL] from the perspective of OP, goal is to disclose my project and ask for feedback, audience is skeptical Reddit dev"
- **A path** to a brief doc - e.g., `/write docs/campaigns/launch-post.md`
- **A URL** alone - the agent will fetch it and ask for goal + audience before drafting

## Required brief fields

Three fields are required. Without these, ask the user before dispatching:

- **Goal**: what should this content do
- **Audience**: who reads it
- **Format**: where it lives (reddit-reply, reddit-post, blog-post, chat-message, cold-dm, landing-section, x-post, x-reply, email)

If the user provides a URL, format can usually be inferred (reddit URL → reddit-reply or reddit-post; the user can clarify which). Goal and audience must come from the user.

## Optional brief fields

The agent uses these if provided, infers defaults if not:

- **Key facts/proofs**: data, links, examples to incorporate
- **What we're NOT saying**: explicit anti-claims (overrides default "include all relevant context")
- **Length cap**: override the format default
- **Reference doc**: path to a campaign or experiment doc

## Brief Sanitization (run BEFORE dispatching)

Briefs from users contain anti-patterns that cause the agent to produce AI slop. Sanitize the brief before passing it to the agent. Apply each rule below — rewrite the brief in place, then dispatch the sanitized version.

**Rule 1: Strip casing dictates.**

If the brief says "lowercase per voice anchor X", "match the casing of [post]", "all lowercase", "sentence case throughout", or any similar instruction telling the agent what casing register to use — **delete that instruction**. Replace with: "Casing follows the format-aware tier in `natural-voice/SKILL.md`. The voice anchor (if any) is for cadence and structure, not casing."

The agent has format-aware casing tiers built in. User briefs that override this cause failures.

**Rule 2: Reframe voice anchor references.**

If the brief mentions a voice anchor file or post (e.g. "use this post as a voice anchor", "match the voice of `1svmavk`"), append: "Use the anchor for rhythm, sentence-length distribution, and paragraph shape ONLY. Never copy phrases ≥5 words from the anchor — the check script greps for this and fails the draft."

**Rule 3: Defang "punchy" / "short and direct" instructions.**

If the brief says "make it punchy", "short and direct", "snappy", or similar — append: "'Punchy' means vary sentence lengths wildly. Each body paragraph still requires at least one rambling sentence (60+ words OR 3+ commas without hard break). Punchiness comes from variation, not fragment stacking."

**Rule 4: Force scene-first for hot-takes.**

If the brief asks for a "hot take", "contrarian post", "rant", or similar — append: "Scene-first opener mandatory. Lead with a specific moment that earned the take (function, file, time of day, exact incident). The take emerges from the scene; never announce it before it."

**Rule 5: Cap pre-drafted reply count at 5.**

If the brief asks for more than 5 pre-drafted comment replies, cap at 5. Each reply degrades when scope grows. Tell the user the cap was applied and the 5 most-likely comment shapes were prioritized.

After sanitization, dispatch:

```
Agent({
  subagent_type: "writer-agent",
  description: "<short summary of the brief>",
  prompt: "<sanitized brief, with all known fields>"
})
```

The agent runs in isolation, applies the strategic hierarchy (content-frameworks → natural-voice → short-reply if applicable → anti-ai-filter), runs its 10-question rubric and deconstructor pass, runs the **mechanical check script** at `~/.claude/skills/anti-ai-filter/check.py`, and returns a draft + craft notes.

The check script is the load-bearing enforcement layer. The agent's self-eval can be vibes-based; the script can't be faked.

## What this command does NOT do

- Does not draft inline in the main session. Always dispatch to the subagent.
- Does not fill in goal or audience - those must come from the user.
- Does not skip the agent because the brief seems "simple." The point of the agent is consistency across every piece.
- Does not call other writing skills (content-frameworks, natural-voice, anti-ai-filter, short-reply) directly. The agent has those rules consolidated in its system prompt.

## Examples

```
/write reply to https://reddit.com/r/mcp/comments/.../ - goal: position my tool as the "show its work" option, audience: skeptical r/mcp commenters
```

```
/write docs/campaigns/launch-post.md
```

```
/write blog post on the 70% false positive rate I hit when running my dead-code detector against Next.js. goal: build credibility through admitting limitations. audience: r/programming devs. length: 600-800 words.
```

## Reference

- Agent definition: `~/.claude/agents/writer-agent.md`
- Brief template: `~/.claude/skills/writer-agent/BRIEF_TEMPLATE.md`
- Voice corpus (global): `~/.claude/skills/writer-agent/voice-corpus/`
- Voice corpus (project-local override, optional): `<repo>/.claude/skills/writer-agent/voice-corpus/`
