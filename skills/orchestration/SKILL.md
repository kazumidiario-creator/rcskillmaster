---
name: orchestration
description: >-
  Coordinate supervised Orca workers: threaded messages, blocking ask/reply,
  task dispatch, worker_done/escalation waits, task DAGs, decision gates,
  coordinator loops, and decomposing work across agents. Use `orca-cli` for full
  ownership handoffs — "hand off", "handoff", "handover", "give this to another
  agent", "another worktree" — unless asked to supervise, monitor, or coordinate
  a DAG, and for terminal control, lightweight terminal prompts, shell commands,
  Orca worktree management, and reading or waiting on terminals.
---
> Stub de descoberta do Orca (https://github.com/stablyai/orca, MIT), redistribuido por este pacote com uma secao acrescentada sobre o sandbox do Codex. O guia canonico vem do proprio binario: `orca skills get orchestration`.


# Orca Orchestration

This file is a discovery stub, not the usage guide. The full, version-matched Orca
orchestration reference is served by the `orca` binary itself — kept out of this file on
purpose so it can never drift from the binary that will actually run your commands.

Engage Orca orchestration whenever you need structured multi-agent coordination: threaded
messages, blocking ask/reply flows, task dispatch, worker_done/escalation waits, task DAGs,
decision gates, coordinator loops, or decomposing work across agents. Use the orca-cli skill
instead for full ownership handoffs ("hand off", "handoff", "handover", "give this to
another agent", "another worktree") when the user did not ask to supervise, monitor, wait
for results, or coordinate a DAG — and for ordinary terminal control, shell commands,
worktree management, and the built-in browser. Coordination requires real Orca runtime
state; never substitute a non-Orca subagent tool.

## Resolve the CLI for this session

Choose the executable once and reuse it for every later command:

- If the `ORCA_CLI_COMMAND` environment variable is set, use its value. Orca exports this
  for managed WSL sessions.
- Otherwise, in a dev checkout whose session exposes `ORCA_DEV_REPO_ROOT`, use `orca-dev`.
- Otherwise, on Linux outside an Orca-managed terminal, use `orca-ide`. Never run bare
  `orca` there — outside Orca's terminals it normally resolves to the
  GNOME Orca screen reader (`/usr/bin/orca`) and starts speech on the user's machine.
- Otherwise, use `orca`.

Below, `ORCA` is a placeholder for the executable you resolved. Substitute it before
running anything; do not create a shell variable or run `ORCA` literally. This works the
same way in POSIX shells, PowerShell, and cmd.exe.

If the selected executable cannot run, report its exact error and stop. Do not fall through
to another executable, which could silently target a different Orca build.

## Codex on Windows: the sandbox hides the runtime

Measured on 2026-09-25 (Codex CLI 0.155, Windows restricted-token sandbox): the same
`orca status --json` reports `"running": false` / `"state": "not_running"` inside the
sandbox and `"running": true` / `"ready"` outside it, with an identical environment. The
sandbox blocks the CLI's connection to the Orca app; it does not raise
`runtime_access_denied`. So, when you are running inside Codex:

- Treat `not_running` from inside the sandbox as "sandbox blocked", never as "Orca is
  off". Do NOT run `ORCA open --json` and do not restart Orca.
- Run every command that talks to the runtime (`status`, `orchestration *`, `terminal *`,
  `worker-*`) outside the sandbox: request escalated permissions (approval to run the
  command without the sandbox). `skills get` works inside the sandbox because it does not
  need the runtime.
- In non-interactive `codex exec` there is no approval, so orchestration is impossible:
  say so in one line and stop instead of retrying.
- Prefer `cmd /c ORCA ...` (substituting the executable you resolved above) or its full path over PowerShell: the sandboxed
  PowerShell runs in Constrained Language Mode and prints method-invocation errors.

## Load the version-matched guide before running Orca commands

```text
ORCA skills get orchestration
```

That prints the compact, version-matched guide for the exact binary that will handle your
next commands. It covers the normal local coordinator loop. For a conditional action gate
such as remote placement, uncertain release recovery, or expanded DAG work, load only the
reference that gate names with
`ORCA skills get orchestration --reference references/<file>.md`
(`--references` lists the names). If that binary rejects `--reference`, run
`ORCA skills get orchestration --full` and read the named bundled reference before acting.

Prefer `--json`. Use the selected executable's `--help` for commands or flags the guide does
not cover. If a command reports that Orca is not running, first check where you are: inside
the Codex sandbox on Windows `not_running` is FALSE (see the section above); re-run with
escalated permissions and do NOT run `ORCA open`. Only outside any sandbox, start it with
`ORCA open --json` and retry. If it fails with `runtime_access_denied`, your sandbox blocked
the connection: re-run it with escalated permissions, and do not run `ORCA open` or restart Orca. If
`skills get` is unknown, explain that updating Orca restores the guide; use `--help` for
read-only discovery and do not guess unsupported commands.
