# Project SDD and agent entry points

Read AGENTS.md and agents.json. The agent registry is a projection of
.agents/manifest.json with a SHA-256 reference; keep both in sync. Roles are portable
instructions, not active processes or enforced vendor permission profiles.

For a bounded change: update the relevant SPEC first, record acceptance and open
decisions, plan paths/checks, assign a task with .agents/templates/task.md, implement,
verify, review when required and record results/limitations.

Multi-step packages live in sdd/specs/<descriptive-id>/ with SPEC.md, PLAN.md,
tasks.json and VERIFICATION.md. Expected first packages: `telegram-capture` and
`misinformation-response`. Keep small configuration changes proportionate:
docs/agent-setup.md holds this setup's scope, criteria, plan and evidence.

Only the coordinator integrates Git. A reviewer must differ from the implementer
when independent review is required. The owner accepts product behavior. Do not
mark pending reviews, missing field evidence or inferred outcomes as verified.
