# Portable project agents

Read AGENTS.md, manifest.json, the assigned role and templates/task.md.
Paths in the manifest resolve from the repository root. sdd/agents.json records
its hash and projects the same role settings for the shared SDD workflow.

These are portable task instructions, not native vendor profiles, a dispatcher,
or enforced permissions. No agents are started by creating them. A runtime must
apply the actual sandbox and read/write boundaries. The owner controls delegation,
architecture and installations. Executor is a command runner without a model.

See MULTIAGENT_ROLES.md and docs/agent-setup.md for responsibilities and evidence.
