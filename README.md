# pharaoh-write

A Claude Code toolkit for writing content that doesn't read like AI wrote it.

Ships one slash command, one subagent, and seven skills. Drop it into any Claude Code session and it routes your draft through structural frameworks, voice rules, and an anti-AI filter before returning the output. No API keys, no SaaS, no account. The whole thing runs against the agent you already have.

It covers the writing surfaces that most often leak AI defaults: long-form posts, landing pages, social replies, cold outreach, narrative work, and startup positioning copy. It does not cover product writing (UI strings, error messages, in-app microcopy) - that lives closer to the code and belongs in a different toolkit.

## What's included

- **`/write`** - the single entry point. Pass a brief, get a draft plus craft notes.
- **`writer-agent`** - a subagent that loads the relevant skills, drafts in isolation, and runs its own self-review before returning.
- **Seven skills:**
  - `content-frameworks` - router. Picks the right structural skills for the format.
  - `longform-writing` - blog posts, essays, anything past ~600 words.
  - `startup-narrative` - positioning, landing copy, pitch language.
  - `story-structure` - narrative pieces, founder updates, anything that needs a payoff.
  - `short-reply` - Reddit, X, HN, LinkedIn, Discord.
  - `natural-voice` - voice rules and corpus-driven conditioning. Edit this to match how you write.
  - `anti-ai-filter` - final pass. Strips banned vocabulary, em dashes, formulaic structure, and AI-default cadence.

## How it works

Clone the repo and run `./install.sh`. The installer copies the command, agent, and skills into `~/.claude/{commands,agents,skills}/`. Seed `voice-corpus/` with samples of your own writing and edit the rules in `natural-voice` to match your register. Then call `/write` from any Claude Code session.

MIT licensed. Self-hosted. Yours to fork.

---

## Install

```bash
git clone https://github.com/Pharaoh-so/pharaoh-write.git
cd pharaoh-write
./install.sh
```

The installer:
- Creates `~/.claude/{commands,agents,skills}/` if any are missing
- Copies the command, agent, and skill files in
- **Skips any file that already exists** - never overwrites
- Prints a summary of what was installed and what was skipped

To re-run after pulling updates, just run `./install.sh` again. Files you've already customized stay yours.

### Verify

After install, open a Claude Code session and type `/write` - the slash command should autocomplete and show its description. If it doesn't, check `~/.claude/commands/write.md` exists.

---

## Quick start

Once installed, drop a brief into Claude Code:

```
/write reply to https://reddit.com/r/programming/comments/.../ - goal: build credibility by sharing what didn't work, audience: skeptical r/programming devs, format: reddit-reply
```

Or point it at a brief doc:

```
/write docs/campaigns/launch-post.md
```

The writer-agent will load the relevant skills, read any examples in your `voice-corpus/`, draft the content, run its 10-question self-review rubric, run an anti-AI deconstructor pass, and return:

- The final draft
- Craft notes (which frameworks applied, what got rewritten, what assumptions were made)

---

## Customize

The toolkit ships with sensible defaults, but the agent's voice output is only as good as the corpus you seed and the voice rules you keep.

### 1. Seed the voice corpus

`~/.claude/skills/writer-agent/voice-corpus/` has subdirectories for each format (reddit-replies, blog-posts, cold-dms, etc). Drop your own real writing examples in. Five real examples per format beats fifty synthetic ones.

The shipped seed files are clearly marked `SEED-EXAMPLE.md` - replace them, don't add to them.

### 2. Edit the natural-voice skill

`~/.claude/skills/natural-voice/SKILL.md` ships with placeholder vocabulary tables. Replace them with your own most-used sentence starters, hedges, acknowledgments, and signature words. Pull these from your real writing - Slack messages, sent emails, posts you've published.

The skill's structural rules (rhythm, punctuation defaults, banned words) are universal and don't need editing. The vocabulary section is the part that needs to become yours.

### 3. Tune the agent if needed

`~/.claude/agents/writer-agent.md` is the orchestrator. It references the skills above and applies them in order. Most users won't need to edit it, but you can:

- Add a new format (e.g., `tweet-thread`) by extending the format table
- Adjust the rubric questions for what you most often catch in your own drafts
- Change the deconstructor's bias if your default failure mode isn't "too clean"

---

## What this is not

- **Not a SaaS.** No API keys, no account, no usage limits. Everything runs in your local Claude Code session.
- **Not a model wrapper.** It uses whatever model your Claude Code session uses.
- **Not voice impersonation.** It doesn't try to sound exactly like you. It tries to sound less like AI and more like a competent human writing in YOUR register, given the corpus and rules you've configured.
- **Not for product writing.** UI strings, error messages, in-app microcopy, button labels - those need product context the agent doesn't have. Keep those workflows separate.

---

## Uninstall

The installer doesn't track what it copied, but uninstalling is straightforward:

```bash
rm ~/.claude/commands/write.md
rm ~/.claude/agents/writer-agent.md
rm -rf ~/.claude/skills/{content-frameworks,longform-writing,startup-narrative,story-structure,natural-voice,short-reply,anti-ai-filter,writer-agent}
```

Your voice corpus and any local edits go with it. Back up `~/.claude/skills/writer-agent/voice-corpus/` first if you want to keep your seeded examples.

---

## License

MIT. Fork it, ship it, keep it private - whatever works.

See [LICENSE](LICENSE).
