---
description: Break work into small verifiable tasks with acceptance criteria and dependency ordering
---

Invoke the agent-skills:planning-and-task-breakdown skill.

Read the existing spec (SPEC.md or equivalent) and the relevant codebase sections. Then:

1. Operate read-only for research — no product/code implementation. Do **not**
   switch to Cursor Plan mode and do **not** use CreatePlan. The skill owns
   the plan format and file outputs.
2. Identify the dependency graph between components
3. Slice work vertically (one complete path per task, not horizontal layers)
4. Write tasks with acceptance criteria and verification steps
5. Add checkpoints between phases
6. Write the plan and task list to disk (required deliverables):
   - `tasks/plan.md` — full plan per the skill template
   - `tasks/todo.md` — checklist-style task list
7. Present those files for human review (summarize; point at the paths)

Create `tasks/` if missing. Do not treat a Cursor Plan UI card as a substitute
for `tasks/plan.md` / `tasks/todo.md`.
