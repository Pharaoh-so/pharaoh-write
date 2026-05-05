---
name: anti-ai-filter
description: Final-pass filter to strip AI tells from any writing. Run this over finished drafts to catch and fix patterns that read as machine-generated.
---

# Anti-AI Filter Skill

> A last-pass checklist and transformation guide to make any writing read as unmistakably human.
>
> **Purpose:** Run this over finished drafts - yours or AI-assisted - to catch and eliminate patterns that signal machine generation.

---

## When to Use This Skill

Apply as the **final editing pass** on any writing before publishing:
- Blog posts, articles, landing pages
- Marketing copy, product descriptions
- Internal docs, reports, presentations
- Emails, social posts, any professional communication

This is not a voice/style guide - it's a detection-evasion filter. Pair with a voice skill for full effect.

---

## The Core Problem

AI detection works by identifying:
1. **Vocabulary tells** - Words that spiked 50%+ in usage post-2023
2. **Structural patterns** - Predictable rhythms, uniform lengths, formulaic organization
3. **Low perplexity** - Text that's too "expected" / predictable
4. **Low burstiness** - Sentences that don't vary in length or complexity

Human writing is messy, varied, and surprising. AI writing is smooth, uniform, and predictable. The goal is to reintroduce messiness.

---

## SECTION 1: Vocabulary Blacklist

These words spiked in usage post-2023 and are now detection signals. Grep your draft for these and replace every instance.

### Tier 1: Instant Tells (Kill on Sight)

These are the strongest AI signals. One or two might be coincidence; three or more is a red flag.

| Kill | Replace With |
|------|--------------|
| delve / delving | dig into, look at, explore |
| tapestry | mix, blend, combination |
| nuance / nuanced | detail, subtlety, complexity |
| multifaceted | complex, varied, many-sided |
| realm | area, field, space, world |
| landscape | field, space, market, world |
| paradigm | model, approach, framework |
| synergy | combination, teamwork, working together |
| holistic | complete, whole, full-picture |
| robust | strong, solid, reliable |
| leverage (verb) | use, apply, take advantage of |
| utilize | use |
| facilitate | help, enable, make easier |
| optimize | improve, make better, tune |
| foster | encourage, support, build |
| bolster | strengthen, support, back up |
| underscore | highlight, emphasize, show |
| underpin | support, back, form the basis of |
| pivotal | key, critical, important |
| paramount | most important, top priority |
| crucial / vital | important, key, essential |
| comprehensive | complete, full, thorough |
| myriad | many, countless, lots of |
| plethora | many, lots of, abundance |
| endeavour / endeavor | try, attempt, effort |
| embark | start, begin, launch |
| encompass | include, cover, contain |
| elucidate | explain, clarify, make clear |
| meticulous | careful, thorough, detailed |
| commendable | impressive, praiseworthy, good |
| noteworthy | notable, significant, worth mentioning |
| bespoke | custom, tailored, made-to-order |
| cutting-edge | latest, newest, advanced |
| groundbreaking | new, innovative, first-of-its-kind |
| revolutionary | major, significant, game-changing |
| transformative | powerful, significant, impactful |
| seamless | smooth, easy, effortless |
| streamline | simplify, speed up, make efficient |

### Tier 2: Transition Crutches

AI loves these formal connectors. Humans rarely use them in casual/professional writing.

| Kill | Replace With |
|------|--------------|
| moreover | also, and, plus |
| furthermore | also, and, on top of that |
| additionally | also, and |
| consequently | so, as a result |
| nevertheless | but, still, even so |
| nonetheless | but, still |
| henceforth | from now on, going forward |
| thereby | so, which means |
| thus | so |
| hence | so, that's why |
| accordingly | so |
| whereby | where, by which |
| herein | here, in this |
| thereof | of that, of it |
| notwithstanding | despite, even though |

### Tier 3: Formulaic Phrases

These multi-word patterns are almost never used by humans but appear constantly in AI output.

**Opening killers:**
- "In today's fast-paced world..."
- "In the ever-evolving landscape of..."
- "In the realm of..."
- "As we navigate the complexities of..."
- "In an increasingly digital world..."
- "It's no secret that..."

**Signaling killers:**
- "It's important to note that..."
- "It's worth noting that..."
- "It cannot be overstated..."
- "This is a testament to..."
- "This serves as a reminder that..."
- "Needless to say..."

**Conclusion killers:**
- "In conclusion..."
- "In summary..."
- "To summarize..."
- "All in all..."
- "At the end of the day..."
- "Moving forward..."
- "Going forward..."
- "Overall, it is clear that..."

**Filler killers:**
- "a wide range of"
- "a variety of"
- "a multitude of"
- "a plethora of"
- "plays a vital role"
- "plays a crucial role"
- "serves as a catalyst"
- "paves the way for"
- "stands as a beacon"
- "represents a significant"
- "offers a unique opportunity"
- "provides valuable insights"

### Tier 4: Industry Buzzwords

These aren't inherently AI tells but are overused enough to trigger suspicion when clustered.

- actionable insights
- best practices
- deep dive
- game-changer
- low-hanging fruit
- move the needle
- pain point
- scalable
- stakeholders
- thought leadership
- value proposition
- synergize
- circle back
- touch base
- bandwidth (non-technical)

---

## SECTION 2: Structural Patterns to Break

AI writing has predictable architecture. Human writing doesn't.

### Pattern 1: Uniform Paragraph Length

**The tell:** Every paragraph is roughly the same length (typically 3-4 sentences, 50-80 words).

**The fix:** Vary wildly. Some paragraphs should be one sentence. Some should be 6-7 sentences. Mix it up.

**Bad (AI):**
> The new feature improves user experience significantly. Users can now access their data more quickly and efficiently. The interface has been redesigned for clarity and ease of use. Early feedback has been overwhelmingly positive.
>
> Implementation was challenging but ultimately successful. The team worked through several iterations before finding the right approach. Testing revealed some edge cases that required additional attention. The final product reflects these refinements.

**Good (Human):**
> The new feature improves user experience significantly - users can now access their data in under 2 seconds, down from 8. The interface got a full redesign.
>
> Implementation was brutal.
>
> We went through four major iterations, discovered edge cases nobody anticipated (timezone handling alone took a week), and the final week was basically a war room. But the feedback has been great. Users are noticing the speed. That's what matters.

### Pattern 2: Uniform Sentence Length

**The tell:** All sentences are 15-25 words. No punchy short ones. No complex long ones.

**The fix:** Mix aggressively. Short sentence. Then a longer one that builds and expands and maybe even runs on a bit. Then punch again.

**Metric to hit:** Sentence lengths should range from 3 words to 40+ words within any given paragraph.

### Pattern 3: The Tricolon

**The tell:** Lists of exactly three items, usually with parallel structure. "It's fast, reliable, and secure." "We design, build, and deploy."

**The fix:** Break the pattern. Sometimes two items. Sometimes four. Sometimes just one stated with conviction.

### Pattern 4: The Topic-Evidence-Conclusion Sandwich

**The tell:** Every paragraph follows: topic sentence → supporting evidence → concluding thought.

**The fix:** Start with the conclusion. Bury the topic. Meander. Real thinking doesn't follow essay structure.

### Pattern 5: The Mirror Structure

**The tell:** "From X to Y, from A to B." "Not only X, but also Y."

**The fix:** Use these sparingly - max once per piece. They're not wrong, just overused.

### Pattern 6: The Correlative Conjunction

**The tell:** Heavy use of "not just... but also", "not only... but", "whether... or", "both... and".

**The fix:** Rephrase. "It's X and Y" instead of "It's not only X but also Y."

### Pattern 7: Em Dashes and En Dashes

**The tell:** Em dashes (—) and en dashes (–) appear throughout. These are strong AI tells. LLMs default to typographic dashes that most humans never type. Real people use single hyphens (-).

**The fix:** Replace ALL em dashes (—) and en dashes (–) with single hyphens (-). This is a hard rule. Zero tolerance. Grep for both Unicode characters (U+2014 and U+2013) on every pass.

### Pattern 8: The Challenges Section

**The tell:** "Despite its [positive words], [subject] faces challenges..." followed by vague reassurance.

**The fix:** If you discuss challenges, be specific. Name them. Quantify them. Don't soften.

### Pattern 9: Over-Assurance (The "Doth Protest Too Much")

**The tell:** Preemptively denying something the reader wasn't thinking. AI does this constantly because it's trained to be reassuring and remove friction. The effect is the opposite - it plants the exact suspicion it's trying to remove.

**Examples:**
- "No agenda beyond that." → tells them you have an agenda
- "No strings attached." → tells them you considered attaching strings
- "Your discount stays either way." → tells them you considered revoking it
- "I'm not trying to sell you anything." → tells them this is a sales pitch
- "This isn't a guilt trip." → congratulations, it's now a guilt trip
- "Just to be clear, this is completely optional." → it clearly isn't
- "I'm not upset." → you're upset
- "No pressure at all." → there is pressure

**The rule:** Humans don't preemptively deny things they aren't thinking. If the denial would plant a thought the reader didn't have, cut it. If the reader WOULD have that thought independently, address it directly instead of waving it away.

**The fix:** Delete the assurance entirely. If you need to address a real concern, state the fact without framing it as a denial. "Your account is on Pro with a full discount" - not "Your discount stays no matter what you decide, no strings attached."

### Pattern 10: Defensive Justification (The "But Here's Why")

**The tell:** Explaining the reasoning behind the thing you're apologizing for or the thing that went wrong. AI is trained to provide context and reasoning for everything, so it can't resist justifying a mistake in the same breath as apologizing for it. The effect: you sound like you're defending the decision, not owning the outcome.

**Examples:**
- "We broke your session - which is the whole reason we did this upgrade in the first place." → you're selling the upgrade that broke their stuff
- "The deploy was late, but only because we were being thorough with testing." → you're defending the delay while apologizing for it
- "We had to remove the feature, which honestly needed a full rewrite anyway." → you're justifying the removal instead of acknowledging the impact
- "Sorry for the downtime - we were migrating to a more reliable infrastructure." → nobody cares why when their thing is down

**The rule:** An apology that contains a justification isn't an apology. It's a defense. If you broke something, say you broke it. The "why" only matters if the reader asks or if it's directly relevant to what they need to do next.

**The fix:** Delete the justification clause. If the reason is genuinely useful context (helps them understand what to do next), put it in a separate sentence. Never staple it to the apology.

### Pattern 11: Surveillance Overshare (The "We've Been Watching")

**The tell:** Demonstrating you've been monitoring someone's behavior in a level of detail they didn't know about. AI does this because it treats all available data as fair game for "personalization." Humans recognize it instantly as creepy.

**Examples:**
- "Your usage patterns over the last month show consistent peak activity around 9pm" → you have a dashboard about them
- "I noticed you've been logging in mostly on weekends." → you're tracking their schedule
- "You've been one of our most engaged users - 47 sessions in the last two weeks." → you've been counting

**The rule:** There's a gap between what you know and what you should say. Just because you have analytics doesn't mean you should reveal the resolution of your tracking. "You've been getting real use out of it" is fine. Specific behavioral patterns at specific times reads as surveillance.

**The fix:** Generalize. Reference the relationship, not the data. "You've been one of our most active users" - not the specific behavioral signal that proves it. If specificity is needed, reference something they did publicly or told you directly.

---

## SECTION 3: Rhythm and Perplexity Fixes

AI detection tools measure:
- **Perplexity:** How predictable each word is given the context
- **Burstiness:** How much sentence length varies

Low perplexity + low burstiness = AI. High perplexity + high burstiness = human.

### How to Increase Perplexity

1. **Use unexpected word choices** - Not weird, just less obvious. "The team crushed it" instead of "The team performed exceptionally well."

2. **Break grammatical patterns** - Fragment sentences. Start with conjunctions. End mid-thought-

3. **Add informal register** - Contractions, colloquialisms, the occasional curse word (if appropriate to context).

4. **Include specific details** - Names, numbers, dates, places. AI generalizes; humans specify.

5. **Inject opinion** - Take a stance. AI hedges everything; humans have views.

### How to Increase Burstiness

1. **Vary sentence length consciously** - After writing, check: do you have sentences under 5 words? Over 30 words? Both should exist.

2. **Use fragments** - "Brutal." "Not even close." "Exactly what we needed."

3. **Vary paragraph length** - One-sentence paragraphs are powerful. Use them.

4. **Break rhythm intentionally** - If you've written three medium sentences, follow with something very short or very long.

---

## SECTION 4: The Human Touch

AI can't do these things. Add them.

### 1. Specific Details

**AI:** "The team worked hard to deliver the project on time."

**Human:** "The team pulled three all-nighters in the final week - one engineer literally slept under his desk on Thursday."

### 2. Personal Opinion

**AI:** "This approach has both advantages and disadvantages."

**Human:** "I think this approach is the right call, even though the timeline scares me."

### 3. Genuine Emotion

**AI:** "The results were impressive."

**Human:** "When the numbers came in, I actually yelled. Like, out loud. In the office."

### 4. Self-Correction / Hedging

**AI:** "The solution addresses all requirements."

**Human:** "The solution covers most of what we need - though honestly, the reporting piece is still shaky."

### 5. Casual Asides

**AI:** "The implementation required careful planning."

**Human:** "The implementation required careful planning (and about 400 Slack messages, but who's counting)."

### 6. Direct Address

**AI:** "Users will appreciate the new features."

**Human:** "You're going to love this."

### 7. Imperfection

**AI:** Perfect grammar, perfect spelling, perfect punctuation.

**Human:** Occasional fragments. Maybe a typo left in. Dashes where commas "should" go. Starting sentences with "And" or "But."

---

## SECTION 5: Final Checklist

Run this before publishing:

### Vocabulary Check
- [ ] Grepped for Tier 1 words (delve, tapestry, nuance, etc.)
- [ ] Killed all formal transitions (moreover, furthermore, etc.)
- [ ] Removed formulaic phrases (It's important to note, In today's world)
- [ ] No opening clichés (In the ever-evolving landscape...)
- [ ] No conclusion clichés (In conclusion, At the end of the day)

### Structure Check
- [ ] Paragraph lengths vary (1 sentence to 6+ sentences)
- [ ] Sentence lengths vary (3 words to 35+ words)
- [ ] No more than one tricolon (list of three)
- [ ] No mirror structures (From X to Y, from A to B)
- [ ] Em dashes (—) and en dashes (–) replaced with single hyphens (-). Zero tolerance.
- [ ] Not every paragraph follows topic→evidence→conclusion

### Behavioral Pattern Check
- [ ] No over-assurance ("no agenda," "no strings," "no pressure" - if you're denying it, you're planting it)
- [ ] No defensive justification (apologies don't contain "because" or "which is why" clauses)
- [ ] No surveillance overshare (reference the relationship, not the analytics resolution)

### Human Touch Check
- [ ] Contains specific details (names, numbers, dates)
- [ ] Contains at least one personal opinion
- [ ] Uses contractions (it's, don't, we're)
- [ ] Includes at least one fragment or unconventional structure
- [ ] Has emotional texture (not just information delivery)

### Read-Aloud Test
- [ ] Read the whole piece aloud
- [ ] Does any sentence make you cringe?
- [ ] Does any phrase sound like a press release?
- [ ] Would you actually say this to a colleague?

---

## SECTION 6: Enforcement Loop (Programmatic Pass)

The Final Checklist above is the human-eye review. This section is what the writer agent must run programmatically before returning a draft. The agent has historically failed to actually enforce the rules on its own output even when it claims to have run a final pass — because the "pass" is vibes-based.

This loop is mechanical. It uses tools (grep, character counts, regex) so the check can't be hand-waved.

### Step 1: Phrase blacklist grep

Run `grep -Fxf phrase-blacklist.md draft.md` (and against `phrase-blacklist-local.md` if it exists). For every match, rewrite the offending sentence to achieve the same intent without the trope. Don't just delete — rewriting closes the hole.

The phrase blacklist file lives next to this SKILL.md at `phrase-blacklist.md`. It contains universal AI tells (closer tropes, formal transitions, formulaic openers) that grep against the draft will catch. Add new entries when a phrase has been published before and shouldn't be reused, or when a new AI tell is identified.

### Step 2: Capitalization audit

Count post-period sentence-starts in the body. Compare against the format-aware target tier from `natural-voice/SKILL.md` § Format-Aware Casing Tiers:

- Reddit incident-style post → 5-15% caps target
- Reddit essay-style post → 50-70% caps target
- Blog post / longform → 70-90% caps target
- Casual reply / chat → 5-15% caps target

If the draft is outside the target range, adjust. If outside by more than 5 percentage points in either direction, rewrite. The voice anchor (if provided in the brief) is for cadence and structure only — never copy its casing wholesale.

### Step 3: Rhythm verification

Every body paragraph must contain at least one rambling sentence (60+ words OR 3+ commas without a hard break). If a paragraph is purely short fragments stacked together, the rhythm is its own AI tell. Add a longer breath-sentence somewhere in that paragraph or merge with the next paragraph.

The opposite check: a body paragraph cannot be entirely one long sentence either. Mix lengths. If a paragraph is 4 short fragments and a single long sentence, that's healthy. If it's 5 short fragments OR 1 long sentence, rebalance.

### Step 4: Em-dash count

Count em-dashes (—) and en-dashes (–) in the draft. Per `natural-voice/SKILL.md`: max 1 per 500 words, only as mid-clause appositive ("the formatter — which you wrote last quarter — is broken"). Sentence connectors and list separators must use single hyphens. If the count is over budget, replace until within budget.

### Step 5: Typo budget

In casual-register pieces (chat, Reddit, social, founder-voice posts): verify 1 light typo exists in the body (not in load-bearing words, not in the first sentence, not in the closing question). If the draft is grammatically perfect, introduce one acceptable typo per the `natural-voice` typo budget rules.

In formal-register pieces (blog post, marketing, email): verify 0 typos. The draft should be grammatically clean.

### Step 6: Voice anchor leak check

If the brief provided a voice anchor (a sample post or piece in the target voice), grep the draft for verbatim phrases longer than 5 words from the anchor. Voice anchors are for rhythm and structure, not phrasebanks. Any 5+ word string copied from the anchor must be rewritten, even if the phrasing was effective in the anchor.

This is the most-failed check. Agents that load a voice anchor as conditioning will pull signature phrases from it. Block this at the enforcement step, not the drafting step.

### Step 7: Repeat until clean

If any of steps 1-6 triggered a rewrite, run the loop again. Don't return the draft until a full pass produces zero changes.

If the loop runs more than 3 times without converging, the draft probably needs a structural rewrite (the format is wrong, the voice is mismatched to the audience, or the brief itself was self-contradictory). Return the draft with a craft note explaining what wouldn't converge — better to flag than to ship a draft that quietly violates the rules.

---

## Quick Reference: Search-and-Replace

Copy this into your editor's find-and-replace:

```
FIND → REPLACE WITH

— (em dash) → - (hyphen)
– (en dash) → - (hyphen)
delve → dig into
utilize → use
leverage → use
facilitate → help
moreover → also
furthermore → also
nevertheless → but
consequently → so
It's important to note → [delete]
It's worth noting → [delete]
In conclusion → [delete sentence]
at the end of the day → [delete]
a wide range of → many
a variety of → different
plays a vital role → matters
comprehensive → full
robust → solid
seamless → smooth
cutting-edge → latest
groundbreaking → new
transformative → [describe what actually changes]
innovative → [describe what's new]
paradigm → approach
synergy → [delete or describe collaboration specifically]
holistic → complete
nuanced → [be specific about the nuance]
multifaceted → complex
landscape → [market/field/space - or delete]
realm → [area/field - or delete]
```

---

## The Meta-Rule

If you're reading a sentence and it sounds like it could appear in any article, on any website, by any author - it's probably AI-like.

Good writing is **specific**. It couldn't have been written about any other subject, by any other person, at any other time.

Bad writing is **generic**. Swap out the nouns and it works for anything.

When in doubt: make it weirder, make it shorter, make it yours.
