# Voice Corpus

Raw examples of writing, organized by format. The writer-agent reads 5-10 examples per draft as few-shot conditioning. Without a corpus, the agent falls back to rules - which is the failure mode this whole system is designed to escape.

## Why this exists

Skills like `natural-voice` and `anti-ai-filter` are rules ABOUT writing. Rules are abstract. They tell a model "be casual" and the model produces the most-trained version of "AI told to be casual." Examples beat rules. If every draft is conditioned on actual examples of how YOU write in this format, the model matches the corpus shape rather than drifting to its default architecture.

This corpus is the load-bearing piece. Without it, the agent is just another stack of style guides.

## What ships

This repo includes 4 synthetic seed examples (one per major format) so the agent has SOMETHING to read on day one. They demonstrate the file format and shape, not your voice.

**Replace them with your own writing as soon as you can.** Five real examples beats fifty synthetic ones.

## Structure

```
voice-corpus/
├── reddit-replies/
├── reddit-posts/
├── blog-posts/
├── chat-messages/
├── cold-dms/
├── x-posts/
├── x-replies/
├── landing-sections/
├── emails/
├── hn-replies/
├── linkedin-comments/
└── discord-messages/
```

The agent looks up the directory based on the brief's `format` field.

## File format

Each file is a single example or a small batch (≤5) of related examples. Frontmatter:

```markdown
---
date: 2026-05-04
format: reddit-reply
source: https://reddit.com/r/programming/comments/...
context: replying to skeptical commenter on dev tool thread
tags: [voice-test, disclosure]
---

[raw text of the message, exactly as written, including typos and capitalization quirks]
```

Multiple examples in one file:

```markdown
---
date_range: 2026-04-15 to 2026-04-30
format: reddit-reply
---

### Example 1
context: ...
[text]

### Example 2
context: ...
[text]
```

## How to seed

1. Pull 5-10 examples from each format you write often. Real ones - Reddit replies you posted, blog posts you published, cold DMs that worked.
2. Drop each into the matching subdirectory with the frontmatter above.
3. Don't clean them up. Typos, weird capitalization, fragments, and your specific tics are what the agent matches against.
4. Refresh quarterly. Voice drifts; the corpus should reflect how you write NOW, not 18 months ago.

## What NOT to include

- Synthesized examples ("here's what I would write if...")
- Examples written by AI you cleaned up
- Examples in voices that aren't yours (someone else's reply you liked)
- Marketing copy your team wrote - only your own writing

The whole point is fidelity to your actual register. Anything else pollutes the conditioning.

## Project-local override

If a project repo has its own `<repo>/.claude/skills/writer-agent/voice-corpus/<format>/` directory, the agent reads those files in addition to the global corpus, and they take precedence for that project's content. Useful if a specific project has a distinct voice (e.g., a brand persona that's slightly different from your personal voice).
