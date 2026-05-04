---
date: 2026-05-04
format: blog-post
source: synthetic
context: blog post about a counter-intuitive lesson from running a dev tool experiment
tags: [seed-example, replace-me, longform]
---

> **NOTE:** This is a synthetic seed example. Replace with 2-3 of your own real blog posts before relying on the writer-agent for this format.

---

# The dev tool you built works on your own codebase. That's the problem.

Most internal tools are forged on a single team's pain. The author hits a problem, builds the thing that fixes it, ships it, and within a week three teammates depend on it daily. Confidence shoots up. Then the tool goes public, and the bug reports start.

Half of them are easy. The other half are users describing problems you've never seen before in patterns you've never seen before, and your first instinct is to think they're using it wrong.

This is where most internal-tools-turned-products die. Not at the code, at the assumption.

## Where the assumption hides

The assumption is that the codebases your tool will run on look like the codebase you built it on. Same conventions, same scale, same language mix, same edge cases.

For most tools that's roughly true within an order of magnitude. The standard library is the standard library. The framework conventions are mostly stable. But the moment you cross into the long tail - codebases that use unusual patterns, codebases at 10x your scale, codebases in languages your team doesn't write daily - the assumption shatters.

I ran an internal static analyzer against next.js last month. False positive rate on dead code: 70%. The tool was flagging entire framework conventions as bugs because the conventions weren't in its model.

The honest reaction is: the tool is wrong. The framework isn't broken; my analyzer just can't see how it works.

## The cheap version of the fix

There are two kinds of fixes for this class of problem.

The first is the cheap one. Walk a list of high-profile open-source codebases in your target language. Run your tool. Skim the output. For every false positive, ask why. Most of the time, the answer is a convention you didn't know about, a framework pattern you've never used, or a build step that produces files your tool can't trace.

That's it. Half a day's work, every quarter. You won't catch every edge case but you'll catch the categorical ones - the ones where one missed pattern produces 40% of the false positives.

I missed barrel exports because nobody on my team uses them. I missed filesystem-router conventions because we used a different router. The pattern shows up in five minutes of looking; you just have to actually look.

## The expensive version

The expensive fix is to admit that your tool's correctness depends on knowledge it doesn't have, and to build the missing knowledge as data. Not as patches. As a maintained registry.

For my analyzer, that meant a tiny config file per framework: "for next.js, treat these directories as entry points." Three lines per framework. Probably 40 frameworks worth covering, eventually. None of it interesting code; all of it load-bearing.

Most tool authors balk at this because it feels like the long tail will eat them. Forty configs! Maintained forever! Who's going to do that!

The trick is realizing that the long tail is what justifies your tool's existence in the first place. Anyone can write a static analyzer for THEIR codebase. The reason your tool is interesting is that it works on codebases you've never seen. And it can only do that if you've decided to actually invest in the knowledge that makes it work.

## What this looks like in practice

The signal that you've got this right isn't that the tool never produces false positives. It's that when someone reports a new pattern that breaks the tool, you can fix it in 10 lines and ship the fix the same day, because the architecture is set up to absorb new patterns instead of resist them.

If every new framework is a 200-line patch to your core analyzer, you've built the wrong thing. If every new framework is a 5-line addition to a config file, you've built the right thing.

I learned this by getting it wrong first. The instinct to bake conventions into the analyzer's logic is so natural that it took shipping a 70% false positive rate before I went back and pulled them out. The tool is much smaller now than it was three months ago. It also works on more codebases.

## The honest part

I still don't know how this scales. If forty configs work, will four hundred? Will the configs themselves accumulate enough rot that they become their own maintenance burden?

Probably. Eventually. But the alternative - pretending the tool works on every codebase out of the box - is a much worse failure mode. Better to ship something that admits its dependence on framework knowledge than to ship something confident in its own coverage.

The tools that ship and survive are the ones whose authors keep being surprised by other people's codebases. The ones that don't survive are the ones built by people who think they've already seen the relevant patterns.

You haven't.
