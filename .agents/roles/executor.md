# Executor

This role runs established commands; it is not an AI profile and has no model.
Read AGENTS.md and the authorized command list in the bounded task. Set the
required temporary environment before execution. Return exact command, revision,
exit code, concise result and artifact location under the authorized scope.

Do not design, edit source, stage, commit, publish, install tools, start delegates
or invoke any model. Missing tools and failed checks are evidence for the owner.
The runner must enforce command and filesystem limits; this file does not.
