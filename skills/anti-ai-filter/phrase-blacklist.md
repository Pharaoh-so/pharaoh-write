---
name: phrase-blacklist
description: Phrases the writer agent must NEVER reuse. Anti-ai-filter pass greps drafts against this file before returning. Add entries when an AI tell or overused phrase is identified.
---

# Phrase Blacklist

Phrases the writer agent must never reuse in any draft. The anti-ai-filter pass runs `grep -F` against this file as part of its enforcement loop. Any match means the offending sentence gets rewritten before the draft is returned.

This file ships with universal AI-tell phrases. Add to it when you discover a new one in your own drafts, or when a phrase has been used in a prior published piece and should not be reused (signature lines, in-jokes, pet phrases that lose their effect on repetition).

For project-specific or personal phrases, edit `phrase-blacklist-local.md` instead — that file is not overwritten by `install.sh --sync-rules`.

## Closer tropes

These show up at the end of opinion posts and arguments. They signal "I'm performing confidence" rather than "I'm confident."

- "tell me i'm wrong"
- "i'll eat my words"
- "fight me"
- "cope harder"
- "do better"
- "this is the way" (as a closer)
- "just saying" (as standalone closer)

## One-word ironic punctuation

LLM's idea of "punchy." Real human writing uses these maybe once a year, not once a paragraph.

- "exactly." (as standalone single-word sentence)
- "cool." (as ironic standalone closer)
- "anyway." (as paragraph end)
- "right?" (as standalone follow-up)
- "lol." (as standalone — `lol` mid-sentence is fine)

## Tidy metaphors / formulaic phrases

Patterns that sound like the writer is reaching for cleverness. They flatten thought into shape.

- "X dressed up as Y" (any noun pair)
- "the X layer is rotting" / "the X layer is dying"
- "the X cult is dying"
- "the bit that's [verb]" (e.g. "the bit that's broken")
- "[X] is just [Y] with extra steps"
- "[X] is a [Y] at this point"
- "let that sink in"
- "make X great again" (any variant)

## Engagement-bait closers

Performative invitations to comment. Real questions are specific and answerable.

- "what do you think?"
- "thoughts?"
- "am i missing something?"
- "discuss." (as standalone)
- "change my mind"

## Formal transitions

Hard AI tells in any register. Real writers use "but / and / so / also."

- "moreover"
- "furthermore"
- "additionally"
- "consequently"
- "nevertheless"
- "nonetheless"
- "henceforth"
- "thereby"
- "thus"
- "hence"
- "accordingly"
- "whereby"
- "herein"
- "thereof"
- "notwithstanding"

## Formulaic openers

Anything that resembles a press release lede.

- "in today's fast-paced world"
- "in an ever-evolving landscape"
- "it's worth noting that"
- "as we navigate"
- "in the realm of"
- "at the end of the day" (as a transition)
- "moving forward"
- "going forward"
- "let's dive in"
- "let's unpack"
- "needless to say"

## Hype words

Already in `natural-voice/SKILL.md` banned vocabulary, repeated here for the grep:

- "leverage" (as verb)
- "empower"
- "unlock"
- "comprehensive"
- "robust"
- "seamless"
- "world-class"
- "game-changer"
- "groundbreaking"
- "cutting-edge"
- "revolutionary"
- "transformative"

## Setup-shaped phrasings

Phrases that signal "I'm building toward a payoff" rather than just stating something. These are bait disguised as observation.

- "are we all just" + [verb]ing
- "here's the thing"
- "plot twist:"
- "spoiler:"
- "hot take:" (as a label — hot takes can EXIST without announcing themselves)
- "unpopular opinion:"

## How the agent uses this file

After drafting and the deconstructor pass, the anti-ai-filter pass runs:

```bash
grep -Fxf phrase-blacklist.md draft.md
```

Any match = rewrite that sentence. The agent should also check `phrase-blacklist-local.md` if it exists.

If a draft contains a blacklisted phrase, the agent doesn't just delete it — the agent rewrites the sentence in a way that achieves the same intent without the trope. Deleting often leaves a hole; rewriting closes it.

## Adding new entries

When a new AI tell is identified — through reader feedback, comparing against published baseline, or because a phrase was used in a recent published piece — add it here with one bullet. No commentary needed; the grep doesn't read explanations.

Format: a single bullet under the most-relevant section header. Lowercase phrasing matches how the grep will see it.
