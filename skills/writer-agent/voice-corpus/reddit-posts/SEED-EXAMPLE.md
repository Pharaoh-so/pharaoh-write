---
date: 2026-05-04
format: reddit-post
source: synthetic
context: top-level post on r/programming sharing an unflattering finding about your own tool
tags: [seed-example, replace-me, transparency-play]
---

> **NOTE:** This is a synthetic seed example. Replace with 3-5 of your own real Reddit posts before relying on the writer-agent for this format.

---

# I ran my own dead-code detector against next.js and it failed 70% of the time

Built a static analyzer to find unused functions across a codebase. Worked great on the 5 repos I tested with. Felt good about it. Shipped.

Then I pointed it at next.js itself.

70% false positive rate. It was flagging functions in `pages/api/` as dead because nothing in the codebase imports them. Vercel's whole convention is filesystem-as-router - those files ARE the entry points. Static call-graph analysis can't see that.

Same thing with barrel exports. A file does `export * from './stuff'` and my tool sees `./stuff` getting imported nowhere - flags every function inside as dead. Except the barrel file IS the import surface. The functions are reachable, just one level removed.

I knew about both of these patterns. I just didn't think they'd dominate the false positive rate the way they do. On a codebase that uses neither, you get clean output. On next.js, the entire framework is built on the patterns my tool can't see.

**The fixes are unglamorous:**

- For filesystem routers: hard-code a list of "files in this directory are entry points." Next.js, Remix, sveltekit, all have their own conventions. Maintain the list, ship it as data.
- For barrel exports: when you see `export * from`, follow the re-export and mark anything reachable through it as live. This was a 30-line change and dropped the FP rate from 70% to 22%.

The bigger lesson is that "static analysis works" is one of those statements that's true on the codebases the analyzer was built against. The codebases someone else cares about are different. If you're shipping a dev tool, run it against the most-starred repo in your target language before you write the readme.

I'd be curious to hear from anyone who's hit similar things - did the framework-specific entry points break your tool too, or did you build around them from the start?
