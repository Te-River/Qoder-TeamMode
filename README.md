# Team Mode — a lead plus five specialists for Qoder

Orchestration-only plugin for Qoder: one team lead, five tool-restricted
specialists, a deterministic routing table, a count-based approval gate, and a
structured `STATUS / CHANGES / FINDINGS / EVIDENCE / HANDOFF` handoff contract.

It ships **no tool layer of its own**. Every capability it uses is a tool the
host already provides.

Lineage: this is the orchestration layer ported from
[Opencode-TeamMode](https://github.com/Te-River/Opencode-TeamMode), an OpenCode
Desktop plugin. The port deliberately keeps the coordination logic and deletes
the governance tooling that only existed to fill OpenCode's gaps.

## What you get

| Command | What it does |
|---|---|
| `/team-mode:team-run` | Full workflow: triage → route → count dispatches → plan-and-approval-gate → execute pipeline → adaptive review → feedback loop → summary. This is the one to reach for. |
| `/team-mode:team-plan` | One dispatch to `architect`. |
| `/team-mode:team-implement` | One dispatch to `implementer`. |
| `/team-mode:team-review` | One dispatch to `reviewer` (three in one round when the change is high-risk). |
| `/team-mode:team-test` | One dispatch to `tester`. |
| `/team-mode:team-research` | One dispatch to `researcher`. |

Sub-agents are addressable by name too: `@team-mode:architect`, and the
`team-lead` skill auto-triggers on multi-specialist work.

## Layout

```text
.qoder-plugin/plugin.json     manifest — name/version + the three component paths
skills/team-lead/SKILL.md     the lead contract, as an invocable skill
agents/team-lead.md           the same body, as an agent (see "Two shapes for the lead")
agents/{architect,implementer,reviewer,tester,researcher}.md
commands/{team-run,team-plan,team-implement,team-review,team-test,team-research}.md
scripts/pack.ps1              builds dist/team-mode-<version>.zip for upload
scripts/validate.ps1          runs Qoder's own `plugins validate` against a dir or zip
```

## Ported vs dropped

The OpenCode original is ~19,000 lines of TypeScript. Only the orchestration
layer survived the port, because everything else compensated for a gap Qoder
does not have.

| OpenCode side | Where it went |
|---|---|
| `tm_read` / `tm_grep` / `tm_bash` | host `Read` / `Grep` / `Glob` / `Bash` |
| `tm_search` (7 no-key engines) | host `WebSearch` |
| `tm_webfetch` (domain allowlist + SERP folding) | host `WebFetch`; consent is the permission system's job here |
| `tm_browser` (own CDP/Playwright driver) | the user's browser MCP (`browser-use`) |
| `tm_join` + dispatch registry + wait budget | host `Agent` tool, foreground or `run_in_background` |
| `tm_pty` | `Bash { run_in_background: true }` |
| `tm_memory` three tiers + dedup + compaction | host memory (project / user `MEMORY.md`) |
| offload store + HMAC handles + ≤80-token previews + `tm_fetch` paging | **deleted**; only the discipline survived (≤50-line replies, oversize → gap) |
| `tm_ptc_run` zero-round-trip batch programs | batching independent calls into one round |
| `tm_board_write` + blackboard layout | **deleted**; the lead writes oversized artifacts and names the path |
| R6 env red line, `ctx.ask` dialogs, approval-gate TTL timer | host permission modes |
| bash timeout clamp, arg coercion, tool-description append, capability probe | **no mount point** — Qoder plugins are declarative packages, not a runtime API |

### Kept verbatim (this is the actual product)

Deterministic routing table · fixed minimum pipelines · ANTI-SPLITTING ·
discovery gate · `GOAL:` / `ACCEPTANCE:` directive with exactly two legitimate
stops · count-based approval gate (≥2 dispatches → plan, then end turn) ·
batched blocking questions · TodoList ledger (insertion-not-replacement,
`blocked` is a state, re-read after compaction) · adaptive review (1 → 3
dimensions) · 2-loop feedback ceiling · four-class retry policy · evidence
standard · research confidence tags · reply skeleton · repo and pre-commit
hygiene · "a capability you don't have is a gap, never a simulation".

## Known differences (honest list)

1. **The tool matrix may not be enforced.** The `tools:` / `disallowedTools:`
   keys in `agents/*.md` come from Qoder's subagent documentation. On the
   machine this was built on, none of the three installed plugins that ship
   agents restrict tools the same way (one uses `allowed-tools`, two ship no
   tool key at all), so whether the host *enforces* a whitelist is unverified.
   The real lock is prompt-level: every specialist is told that a tool it was
   not given does not exist and must be reported as a gap. If you verify
   enforcement (see checklist item 4 below), say so here.
2. **No per-agent temperature.** "All six agents at 0.2" is not portable; the
   host exposes `model` and effort levels instead. Nothing here pretends to be
   equivalent.
3. **No token ledger.** There is no `tm_stats`, so this plugin cannot show you
   what it saved. Throughput claims are unfalsifiable by design in v0.1.0.
4. **Oversized artifacts cost lead context.** With the board and the offload
   store gone, a >50-line deliverable comes back to the lead, which then writes
   it. That is exactly the token cost the OpenCode version existed to avoid.
5. **Two shapes for the lead.** Qoder plugins cannot replace the main session's
   persona, so the lead ships both as a skill (works today, loaded into the
   main session) and as `agents/team-lead.md` (the shape for a host that lets
   you run a session as a named agent). The bodies are generated from the same
   text; nothing else in the package duplicates.
6. **Native Agent Teams is not used.** Qoder has a multi-agent team feature,
   but it is enterprise-only, has no shared task board or member-to-member
   messaging documented, and its members are configured by hand in settings.
   This plugin therefore implements its own routing rather than riding on it.
7. **Two manifest fields are decorative.** The CLI validator reports
   `descriptionZh` as "unknown field, ignored by the current runtime", yet the
   desktop app's own package reader does pull it for display — so it is kept for
   the UI and does nothing for the CLI. `category` and `tags` were removed
   because the validator says they belong in `marketplace.json`; add them back
   only when this repo grows a marketplace entry.

## Install

```powershell
powershell -ExecutionPolicy Bypass -File scripts\pack.ps1
```

Then in Qoder: **扩展 → 插件 → 添加插件 → 上传**, pick `dist/team-mode-<version>.zip`,
and **fully quit and restart** Qoder. Updating is the same three steps after
bumping `version`.

Offline check before uploading — this runs **Qoder's own validator**, the same
`plugins validate` call the upload path makes:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\validate.ps1 -Target dist\team-mode-0.1.0.zip
```

It resolves the package through the installed Qoder executable, so it reports
what the host will accept rather than what a reference script believes. Expect
`"valid":true`, 13 components, and one warning about `descriptionZh`.

Do **not** gate on the `create-plugin` skill's `validate_qoder_plugin.py`: it
requires `agents` to be a single string path, while the host's schema requires
`.md` paths and rejects `"./agents/"` with `Path must end with .md`. The two
disagree; the host wins. (That rejection is what surfaces in the UI as the
generic "扩展内容与当前版本不兼容" toast.)

### Four things to verify after the restart

1. Typing `/team-mode:` offers the six commands.
2. `team-mode:architect` appears among the sub-agent types.
3. A dispatch returns a reply that starts with the five skeleton lines.
4. **The load-bearing one:** ask `team-mode:architect` to run `ls`. It should
   answer that the capability is not on its tool surface — not run the command.
   If it runs it, item 1 of *Known differences* is confirmed and this section's
   wording must change from "restricted" to "advisory".

## Uninstall

Remove it from **扩展 → 插件**; that also drops the namespaced commands.

## Requirements

`team-mode` registers no MCP server and needs no credentials. Network and
browser capability comes entirely from connectors the user has installed — see
[CONNECTORS.md](CONNECTORS.md).

## License

Apache-2.0.
