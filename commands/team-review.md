---
name: team-review
description: "Review code with a single focused dimension — completeness, correctness, or impact (default: correctness)."
---

Dispatch the brief below VERBATIM to the `team-mode:reviewer` sub-agent with the
`Agent` tool.  When its reply arrives, relay the
STATUS/CHANGES/FINDINGS/EVIDENCE/HANDOFF skeleton to the user as-is.  Do not
review it yourself, and do not fill in verification a sub-agent did not run.
If the change profile is high-risk (auth/security surface, cross-module data
contracts, public APIs across ≥3 files), dispatch three reviewers in one round
instead — completeness, correctness, impact — and merge their reports into one
severity-grouped list.

Perform a single-dimension code review on the following scope.

## Scope
$ARGUMENTS

## Dimension
$ARGUMENTS may name one dimension: completeness (requirements coverage),
correctness (logic & security), or impact (regressions & blast radius).
If no dimension is named, review correctness.  Ignore the other dimensions
— parallel reviewers own them.

If no specific scope is given, review all recently modified files in the project.

Use the standard severity scale (drives the team's feedback loop — grade honestly):
- 🔴 Critical (must fix — broken behavior or security hole)
- 🟠 Major (must fix — real defect or significant risk)
- 🟡 Minor (should fix, non-blocking)
- 🔵 Nit (style/preference, take-it-or-leave-it)
- ✅ Praise (good patterns worth keeping visible)

Include file paths, line numbers, and concrete fix suggestions.
