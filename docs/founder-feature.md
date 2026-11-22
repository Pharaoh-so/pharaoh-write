# Founder-feature workflow

This is a human-gated workflow, not a mail or publishing integration. `/founder-feature` only writes a draft and an evidence list. It does not check inboxes, schedule reminders, create or alter Ghost drafts, publish to the web, send newsletters, or follow up on published posts.

| Stage | Proceed only when |
| --- | --- |
| 1. Outreach | Use the existing compliant outreach process. Check for an eligible contact, verified founder identity and address, permission to send, and no prior opt-out or duplicate outreach. No scrape-and-send or expansion of scope here. |
| 2. Founder reply | Verify the reply against the founder and the original thread before treating it as an acceptance. Extract the problem, product strengths, first-party sources, and any statements cleared for attribution. An acceptance to participate is not approval of a draft. |
| 3. Write and review | Run `/founder-feature` with the scoped brief. Read first-party docs, public repo and release notes, platform requirements, and attributable founder evidence as appropriate. Check every factual claim, surface gaps, and separate our work from documented features. Check title, H2s, founder fairness, and formatting at desktop and phone widths. |
| 4. Private Ghost preview | With authorization and access, prepare a private Ghost draft for the existing publication, not a public post or newsletter. Verify title, slug, excerpt, SEO fields, links and rendering. Record a private revision identifier for the exact review copy. Send the non-indexed preview to the verified founder only if authorized. |
| 5. Approval | Record the founder's explicit approval tied to that exact preview revision. No response, general enthusiasm, and approval of a previous version do not count. If the copy changes after approval, share the updated revision and get approval again. One reminder at most per feature, only if separately authorized and the founder has not replied or opted out. |
| 6. Publish and verify | Require both the founder's exact-revision approval and the publication owner's authority to publish. Compare the approved revision against the draft before using Ghost's web-only publish option. Never send a newsletter unless separately requested and authorized. Verify the public URL, expected title, description, canonical/indexability, and visible article content before reporting success. |
| 7. Post-live | Save the verified live URL privately. The post-live outreach CTA is **disabled / TBD**: do not send a share request, discount, or other follow-up by default. |

Keep founder emails, contact details, private briefs, preview URLs, credentials, and approval records out of the repository. Use authorized private storage. A record can contain the stage, product, verified thread reference, draft revision, approvals and publication URL. Record who approved what and when. If evidence, authority, access, or verification is missing, stop at that stage and record what is needed.

## Run without a Mac

Use a dedicated Linux cloud runner with a private workspace, a supported [Node.js](https://nodejs.org/en/download) release for the checker, and your own service account/home directory. If you choose Claude Code, install it from [Anthropic's supported setup instructions](https://code.claude.com/docs/en/setup), check its version, then run `./install.sh --sync-rules` from a reviewed toolkit checkout as the runner user. Do not run in an unrelated checkout whose Claude settings or hooks you have not reviewed. The Dot can instead run the same editorial workflow in its cloud workspace with approved tools; that path needs no Claude authentication.

For Claude only, use [runner-approved authentication](https://code.claude.com/docs/en/authentication), such as an `ANTHROPIC_API_KEY` injected by the runner's secret manager when policy permits. Inject the model credential only into the drafting process; it does not belong in a brief, command argument, checkout, or log. Keep Ghost and mail credentials out of the drafting runner. A cloud invocation can incur provider usage charges. Send Claude only material cleared for that provider.

Use a private directory outside the checkout as the working directory. Set restrictive file permissions and stage a sanitized `brief.md` and relevant first-party excerpts with their public URLs there. Obtain evidence separately using authorized read-only tools; unavailable sources remain open questions, not permission to fetch a private preview. From that directory, an example [non-interactive](https://code.claude.com/docs/en/headless) invocation is:

```sh
umask 077
claude -p --agent writer-agent --permission-mode dontAsk \
  --tools Read --strict-mcp-config --no-chrome --no-session-persistence \
  --output-format json \
  "Mode: founder-feature. Read brief.md and the installed founder-feature command for its editorial brief. Use only the staged evidence. Act as the writer directly. Return the draft, SEO suggestions, and private evidence notes; the runner will check the draft separately." \
  > result.json
```

This example uses the installed agent directly, with only file reads enabled. It relies on non-bare mode loading the installed agent; do not add `--bare` to this invocation. Keep the runner free of other hooks, plugins and connectors. It does not bypass permission prompts; a denied action stays denied. Inspect the JSON result and any blockers, save just the article as `draft.md` in private staging, then run the checker outside the model process:

```sh
node "$HOME/.claude/skills/anti-ai-filter/check.mjs" draft.md --format founder-feature
```

Do not call a draft checked until the checker and manual evidence review have run. Store artifacts and revision/approval records only in authorized private storage. Do not log prompts or responses into shared CI or commit them.

## Future Ghost integration

No Ghost Admin API or mail integration is wired in this version. A future publisher must use the specific HTTPS Admin API base verified from Ghost's Custom Integration settings for the intended publication, including its subdirectory if applicable. Do not derive it from the public blog URL or a private preview. Follow [Ghost's Admin API authentication guidance](https://docs.ghost.org/admin-api#authentication): use an authorized integration, keep its key in a server-side secret manager separate from the drafting runner, and send short-lived authentication tokens only to that approved endpoint. Keep draft and publish actions distinct. Before a web-only publish, verify the target site, post ID and exact approved revision, require both approvals above, and verify the result on the public site. Do not pass newsletter or recipient options without separate authorization.
