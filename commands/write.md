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

## Dispatch

Once required fields are present, dispatch to the agent via:

```
Agent({
  subagent_type: "writer-agent",
  description: "<short summary of the brief>",
  prompt: "<the full brief, with all known fields and any referenced URLs/docs>"
})
```

The agent runs in isolation, applies the strategic hierarchy (content-frameworks → natural-voice → short-reply if applicable → anti-ai-filter), runs its 10-question rubric and deconstructor pass, and returns a draft + craft notes.

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
