---
name: humanize
description: Rewrite text to remove signs of AI-generated writing — inflated significance, promotional language, em-dash overuse, rule of three, AI vocabulary, copula avoidance, passive voice, filler and hedging. Use when asked to humanize, de-AI, or make copy sound like a real person wrote it, or to fix violations from `$copy-review`. Works on UI strings, docs, READMEs, emails, blog posts, or any prose.
---

# Humanize: remove AI writing patterns

The rewrite counterpart to `$copy-review`. That skill finds and flags AI tells with file:line references; this skill rewrites the text so they're gone. Use `$copy-review` for an audit and this skill when the user wants the prose fixed.

Based on [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) (WikiProject AI Cleanup) and the MIT-licensed [humanizer skill](https://github.com/blader/humanizer) by blader.

> **Project profile:** if a `.codex/essentials-profile.md` file exists in the repo, read it first for the codebase's voice, audience, and conventions, and match the rewrite to them.

## Your task

When given text to humanize:

1. **Identify the patterns** below. Look for *clusters*, not isolated hits (see Detection guidance).
2. **Rewrite, don't delete.** Replace each AI-ism with a natural alternative and cover everything the original covered. Five paragraphs in, five paragraphs out.
3. **Preserve meaning.** Keep the core message intact.
4. **Match the voice.** Fit the register (formal, casual, technical, product-UI). Add personality only when the content and author's voice call for it (see Voice).

When editing files in a repo, only touch user-facing strings and prose — never variable names, code, or logic. Show the change with file:line context.

## Voice calibration (optional)

If the user provides a writing sample, read it first and note: sentence-length rhythm, word-choice level, how paragraphs open, punctuation habits, recurring phrases, how transitions are handled. Then match those patterns in the rewrite — don't just strip AI tells, replace them with the sample's habits. If they write "stuff" and "things", don't upgrade to "elements" and "components". With no sample, fall back to a natural, varied, plain voice.

For encyclopedic, technical, legal, reference, or UI-string text, neutral and plain *is* the correct human voice — don't inject opinions or first person there. Apply personality only to blog posts, essays, opinion, and personal writing.

## The patterns

### Content
1. **Significance inflation** — "marks a pivotal moment in the evolution of…", "stands as a testament to…", "setting the stage for…", "reflects broader trends". Cut the puffery; state the plain fact.
2. **Notability padding** — listing media outlets or follower counts without context. Replace with one concrete, sourced detail.
3. **Superficial `-ing` tails** — participle phrases tacked on for fake depth ("…, highlighting the connection", "…, ensuring scalability"). Cut or make a real clause.
4. **Promotional / ad language** — "nestled in the heart of", "boasts", "vibrant", "breathtaking", "must-visit", "rich cultural heritage". Drop to neutral.
5. **Vague attributions / weasel words** — "Experts argue", "Industry reports", "Observers have noted". Name a source or cut.
6. **Formulaic "Challenges and Future Prospects" sections** — "Despite its…, it faces challenges…". Replace with specific, dated facts.

### Language
7. **AI vocabulary** — actually, additionally, align with, crucial, delve, emphasizing, enduring, enhance, fostering, garner, highlight (verb), interplay, intricate, key (adj.), landscape (abstract), pivotal, showcase, tapestry, testament, underscore, valuable, vibrant. They co-occur; when several cluster, rewrite hard.
8. **Copula avoidance** — "serves as / stands as / represents / boasts / features / offers" where plain **is / are / has** reads better.
9. **Negative parallelism & tailing negation** — "Not only X but Y", "It's not just X, it's Y", and clipped tails ("…, no guessing"). Write the real clause.
10. **Rule of three** — ideas forced into groups of three to sound comprehensive. Keep what's true, drop the filler third.
11. **Synonym cycling** — the same referent renamed every sentence. Pick one noun.
12. **False ranges** — "from X to Y" where the endpoints aren't on a real scale. Replace with the list.
13. **Passive voice / subjectless fragments** — "No configuration needed", "Results are preserved automatically". Use active voice with a real subject when it's clearer.

### Style
14. **Em & en dashes — cut them.** The final rewrite contains **no `—` or `–`**, and no ` -- ` standing in for one. Treat this as a hard constraint. Replace each with a period, comma, colon, parentheses, or restructure. Scan the final draft for `—` and `–` before delivering; any hit means it isn't done.
15. **Overused boldface** — mechanical emphasis. Strip to plain text.
16. **Inline-header vertical lists** — bullets opening with "**Label:** …". Turn into prose or a clean list.
17. **Title case in headings** — sentence case instead ("Strategic negotiations and global partnerships").
18. **Emojis** decorating headings/bullets. Remove.
19. **Curly quotes** → straight quotes, when consistency calls for it.

### Communication
20. **Chatbot artifacts** — "I hope this helps!", "Certainly!", "Let me know if…", "Would you like me to…". Delete.
21. **Knowledge-cutoff & speculative gap-fill** — "as of [date]", "while specific details are limited…", invented filler ("likely grew up…", "maintains a low profile"). Say what isn't known, or cut.
22. **Sycophantic tone** — "Great question!", "You're absolutely right". Delete.

### Filler and hedging
23. **Filler phrases** — "in order to" → "to", "due to the fact that" → "because", "at this point in time" → "now", "has the ability to" → "can".
24. **Excessive hedging** — stacked qualifiers ("could potentially possibly") → one.
25. **Generic positive conclusions** — "The future looks bright", "exciting times ahead" → a concrete fact or nothing.
26. **Hyphenated-pair overuse** — keep the hyphen attributive ("a high-quality report"), drop it after the noun ("the report is high quality").
27. **Persuasive authority tropes** — "the real question is", "at its core", "what really matters", "fundamentally". State the point plainly.
28. **Signposting** — "Let's dive in", "here's what you need to know", "without further ado". Just do the thing.
29. **Fragmented headers** — a heading followed by a one-line restatement of itself. Cut the warm-up.
30. **Diff-anchored writing** — prose narrating a change instead of describing the thing (outside changelogs/migration guides).
31. **Manufactured punchlines / staccato drama** — a run of short fragments engineered for impact. One is fine; a stack is a tell.
32. **Aphorism formulas** — "X is the language of Y", "X becomes a trap", "the architecture of Z". Replace with the concrete claim.
33. **Conversational rhetorical openers** — "Honestly?", "Look,", "Here's the thing" as fake-candid hooks. A person being honest just says the thing.

## Voice (when the register allows it)

Stripping tells is half the job; voiceless prose is just as obviously machine-made. For blog/essay/opinion/personal copy: have an actual opinion, vary the rhythm (short punchy sentences, then a longer one), and let some mess in — asides, half-formed thoughts. Don't do this to UI strings or reference docs.

**Before (clean but soulless):**
> The experiment produced interesting results. The agents generated 3 million lines of code. Some developers were impressed while others were skeptical.

**After (has a pulse):**
> 3 million lines of code, generated while the humans presumably slept. Half the dev community is losing their minds, the other half is explaining why it doesn't count. The truth is probably somewhere boring in the middle.

## Detection guidance

A clean human writer can hit several patterns above without any AI involvement. Before rewriting, sanity-check you're not gutting legitimate prose. Not reliable on their own: polish, formal vocabulary, mixed registers, one em dash, one curly quote, one short emphatic sentence, unsourced claims. Look for **clusters**.

**Preserve these human signals** — don't edit them out: specific hard-to-fabricate detail, mixed feelings and unresolved tension, dated era-bound references, genuine asides and self-corrections, varied sentence length.

## Process and output

1. Read the input and find every instance of the patterns above.
2. Write a **draft rewrite** — reads naturally aloud, varied sentence length, prefers `is/are/has` and concrete detail, keeps the register.
3. Ask: **"What still makes this read as AI-generated?"** Answer in a few bullets.
4. Revise into a **final rewrite** that addresses them and contains no em or en dashes.

Deliver: the final rewrite, the brief "still-AI" bullets, and a one-line summary of what changed. Include the draft too if the user wants to see the working. When rewriting files in place, apply the final version and report the edits with file:line.
