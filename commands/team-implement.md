---
name: team-implement
description: "Implement a feature or task — write production code following the project's conventions."
---

Dispatch the brief below VERBATIM to the `team-mode:implementer` sub-agent with
the `Agent` tool.  When its reply arrives, relay the
STATUS/CHANGES/FINDINGS/EVIDENCE/HANDOFF skeleton to the user as-is.  Do not do
the implementation yourself, and do not fill in verification a sub-agent did
not run.

Implement the following task.  Follow the project's existing code style and
conventions.

## Task
$ARGUMENTS

## Rules
- Read relevant existing files before writing code.
- Handle errors properly.
- After finishing, list every file you created or modified.
