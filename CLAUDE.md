@AGENTS.md

## Claude Code

Read AGENTS.md as the single source of project rules, then the assigned role from
.agents/manifest.json and its bounded task contract. Shared decisions and handoffs
belong in the repository, not private tool memory. Preserve the current session's
authorized launcher, authentication and model; do not change global configuration.
Creating this catalog does not activate agents.
