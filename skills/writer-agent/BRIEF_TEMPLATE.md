# Brief Template

The structured input format for the writer-agent. Required fields must be present before dispatch. Optional fields shape the output but the agent will infer sensible defaults if missing.

## Required fields

### Goal

What should this content DO. Not "write a Reddit reply" - that's the format. Goal is the outcome.

Examples:
- "Drive signups for my new dev tool from r/programming"
- "Build relationship with skeptical commenter without pitching"
- "Position the product as the show-its-work option in the category"
- "Get a churned user to reactivate their account"
- "Convert this finding into a 600-word insight post that demonstrates the product without naming it for the first 200 words"

The clearer the goal, the better the agent calibrates angle, register, and CTA strength.

### Audience

Who reads this. Be specific. "Reddit r/mcp users skeptical of graph tools" beats "developers."

Examples:
- "r/mcp regulars who've tried alternatives in the category and are actively shopping"
- "a specific commenter username - thoughtful skeptic, lowercase Reddit voice, hates marketing"
- "Solo founder vibecoder who's used Cursor for 6 months but doesn't know what an MCP is yet"
- "VC investor reviewing the deck for a pre-seed round"

Audience drives register, vocabulary, what objections to address, what assumptions to make about prior knowledge.

### Format

Pick one. Each format has length defaults and structural conventions baked into the agent.

| Format | Length default | Notes |
|---|---|---|
| `reddit-reply` | 1-3 lines, default 1 | Replying to someone else's comment |
| `reddit-post` | 400-600 words | Top-level Reddit post (showcase, discussion, etc.) |
| `blog-post` | 1,000-2,000 words | Medium-style long-form |
| `chat-message` | 1-3 sentences | Internal team chat |
| `cold-dm` | 3-5 sentences | Cold outreach DM |
| `landing-section` | varies | A section on a landing page |
| `x-post` | <280 chars, often shorter | Twitter/X post |
| `x-reply` | <280 chars | Twitter/X reply |
| `email` | 50-150 (cold), 100-300 (warm) | Cold or warm outreach |
| `hn-reply` | 1-3 lines | Hacker News comment reply |
| `linkedin-comment` | 1-3 lines | LinkedIn comment reply |
| `discord-message` | 1-3 sentences | Discord public server |

## Optional fields

### Key facts / proofs

Data, links, specific examples to incorporate. Without these the agent works from general knowledge; with them, the draft can be specific.

Examples:
- "70% false positive rate on Next.js dead code detection"
- "Experiment 002 doc at docs/experiments/002-insight-post-flywheel.md"
- "The api/ folder convention is the main culprit for FPs"
- "specific quote from the commenter: 'if it can't show its work, it's another context-shaped hallucination machine'"

### What we're NOT saying

Explicit anti-claims. Things to avoid even if they'd be tempting to include.

Examples:
- "Don't claim source code is stored - only metadata"
- "No specific pricing numbers - pricing is dynamic"
- "Don't compare directly to competitors by name"
- "No 'first MCP for X' claims unless verified"
- "Don't pitch - frame as past-tense decided ('what I ended up using')"

### Length cap

Override the format's default. Use sparingly - defaults are calibrated to the format.

Examples:
- `length: 600 words max`
- `length: one sentence`
- `length: 280 chars hard cap`

### Reference doc

Path to a campaign doc, experiment doc, positioning doc, or earlier draft the agent should read for context.

Examples:
- `reference: docs/campaigns/launch-post.md`
- `reference: docs/positioning/v1.md`
- `reference: docs/sessions/insight-flywheel.md`

### URL to fetch

If the brief is responding to a Reddit/X/HN thread, give the URL. The agent fetches it and uses the thread context.

## Sample brief

```
goal: build relationship with a specific commenter, demonstrate the product's "show its work" design without pitching it
audience: the commenter specifically + r/mcp readers watching the thread (skeptical devs)
format: reddit-reply
key facts:
  - the product returns file:line citations from queries, not summaries
  - 70% FP rate on next.js dead code first run, the api/ folder convention broke static call graph
  - "if it can't show its work, it's another context-shaped hallucination machine" was the commenter's exact line
not saying:
  - no link to the product page
  - no comparison to specific competitors by name
  - no engagement-bait closing question
length: 3-4 sentences max
reference: docs/campaigns/launch-post.md
url: https://www.reddit.com/r/mcp/comments/.../
```

## Why this format

The six fields are derived from what actually shapes the output. Goal sets the strategic angle. Audience sets the register. Format sets the structure. Key facts give the agent specifics it can't infer. "Not saying" prevents drift into marketing-speak. Length cap and reference doc are the most common overrides. Anything else is noise that distracts the agent from voice.
