# Connectors

## Team Mode registers nothing

`TeamMode` ships **no MCP server, no hooks, and no credentials**. It is skills,
agents and command templates only. Anything it does with the network or a
browser runs through connectors **you** installed, and it inherits whatever
account, proxy and permission mode those connectors already have.

The two roles that touch the outside world are the team lead and the
researcher; the tester carries browser tools for UI verification only. Open web
browsing stays with those two — an implementer, architect or reviewer has no
network grant in its `tools:` line.

## What each role expects to find

| Role | Wants | Used for |
|---|---|---|
| `TeamMode:researcher` | a docs MCP (e.g. context7), a search MCP, a browser MCP | library docs, external APIs, JS-rendered pages |
| `TeamMode:tester` | a browser MCP (`browser-use` tool names are referenced in its prompt) | verifying user-visible frontend changes |
| `TeamMode:team-lead` | the host's `WebSearch` / `WebFetch` | the discovery gate: real `--help` / docs before coding against an interface |

If a browser MCP is absent, nothing breaks — you get the behavior below instead.

## Missing-connector contract (inherited, not invented here)

These lines come straight from the OpenCode original's prompts and are the
reason this file exists:

- The tester ends its report with `UI NOT VERIFIED: <what still needs manual
  checking>` when no browser is available, when the action it needs is not
  offered, or when a route needs credentials it was not given. A
  `UI NOT VERIFIED:` line is relayed to you verbatim in the lead's final
  summary — it is honest output, not a failure being hidden.
- The researcher reports a gap instead of a result: an unfetchable claim stays
  unfetched, and a page blocked by a human-verification wall is a reason to
  change source.
- A blank or thin page is never evidence that a site has no content — it is
  reported with the blocker named.
- Any role asked to use a capability that is not on its tool surface says so
  rather than simulating the output.

If you see a sub-agent describing a page it never opened, that is a bug in this
port, not a graceful degradation.
