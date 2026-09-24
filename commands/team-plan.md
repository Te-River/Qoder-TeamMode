---
name: team-plan
description: "Create a comprehensive implementation plan — architecture, task breakdown, and risk analysis."
---

Dispatch the brief below VERBATIM to the `TeamMode:architect` sub-agent with the
`Agent` tool.  When its reply arrives, relay the
STATUS/CHANGES/FINDINGS/EVIDENCE/HANDOFF skeleton to the user as-is.  Do not do
the design yourself, and do not fill in verification a sub-agent did not run.

Analyze the following task and produce a detailed implementation plan.

## Task
$ARGUMENTS

## Required output
1. **Overview** — What we are building and why.
2. **Architecture** — Module structure, key interfaces, data flow.
3. **File manifest** — Every file to create or modify, with a one-line summary.
4. **Task breakdown** — Ordered steps the implementer can execute, noting dependencies.
5. **Risks & open questions** — Anything uncertain.

Read existing project files as needed to ground your plan in reality.
Do not write implementation code — only the plan.
