---
name: team-research
description: "Research a topic — grounded in the local repository (code, configs, installed packages, shipped docs)."
---

Dispatch the brief below VERBATIM to the `team-mode:researcher` sub-agent with
the `Agent` tool.  When its reply arrives, relay the
STATUS/CHANGES/FINDINGS/EVIDENCE/HANDOFF skeleton to the user as-is, keeping
every confidence tag.  Do not research it yourself, and never let an unverified
claim become a recommendation.

Research the following topic and provide actionable findings.

## Topic
$ARGUMENTS

## Required output
1. **Summary** — Key findings in 2-3 sentences.
2. **Details** — Structured findings with sources and confidence tags.
3. **Recommendation** — What the team should do, with trade-offs.
4. **Sources** — Local file paths consulted (file:line) and URLs actually read.

Cite your sources with file:line paths.  Do not fabricate APIs or citations.
