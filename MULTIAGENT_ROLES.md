# Portable development roles

Adapted from the portable roles used in gorra-hacking and archimedianTillings.
CuentaConmigo owns these local instructions; no other project's model, deployment
or infrastructure permissions are inherited.

| Role | Responsibility | Access guidance |
| --- | --- | --- |
| planner | Scope, SPEC, task ownership, acceptance, handoff and Git integration | coordinate |
| electoral_counsel | Continuous legal risk analysis of every decision; recommends lines of action; can block (⛔) until the owner decides | read-only (writes docs/legal, checks) |
| design_coordinator | Human-in-the-loop decisions: opens issues for kenarab and andytow, compares answers, applies consensus | coordinate |
| implementer | Bounded implementation of an agreed task | scoped-write |
| capture_engineer | Telegram photo capture, upload, queueing and processing pipeline | scoped-write |
| electoral_analyst | Electoral law, telegram/acta formats, scrutiny process and evidence | read-only |
| trust_safety_analyst | Misinformation response, abuse, privacy, moderation and threat model | read-only |
| ux_designer | Mobile flows for poll workers and volunteers, accessibility | scoped-write |
| reviewer | Independent findings against SPEC, diff and evidence | read-only |
| executor | Established commands, exit codes and artifact references | script-only; no model |

Only planner integrates Git. Each writer receives exclusive paths. Product rules in
AGENTS.md always apply. Roles do not choose models, grant system permissions,
publish to external services or activate processes by themselves.

Start from .agents/templates/task.md. Delegation requires an explicit owner
instruction; the limits are two active AI agents here and four globally across
tools, counting coordinators. A configured reviewer is not a completed independent
review. The executor never launches another model to perform deterministic checks.
