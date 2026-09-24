---
name: team-test
description: "Generate comprehensive tests — unit, integration, and edge-case coverage."
---

Dispatch the brief below VERBATIM to the `TeamMode:tester` sub-agent with the
`Agent` tool.  When its reply arrives, relay the
STATUS/CHANGES/FINDINGS/EVIDENCE/HANDOFF skeleton to the user as-is — including
any `UI NOT VERIFIED:` line, which is honest output and must not be smoothed
over.  Do not write the tests yourself.

Write comprehensive tests for the following scope.

## Scope
$ARGUMENTS

If no specific scope is given, identify the most recently modified source files and write tests for them.

## Requirements
- Use the project's existing test framework and conventions.
- Cover happy path, edge cases, and error paths.
- Each test must be deterministic and test exactly one behavior.
- Use descriptive test names.
