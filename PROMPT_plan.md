# Planning Mode - Reminders App

Study AGENTS.md for project context and patterns.
Study all files in the specs/ directory for feature requirements.
Study the existing codebase to understand what's already implemented.

## Your Mission

1. **Read specs**: Study every file in specs/ directory
2. **Analyze code**: Compare specs to existing implementation
3. **Gap analysis**: Identify what's missing or incomplete
4. **Generate plan**: Create/update IMPLEMENTATION_PLAN.md with prioritized tasks
5. **Exit**: Exit when the plan is complete and written to file

## Plan Format

Write IMPLEMENTATION_PLAN.md with this structure:

```markdown
# Implementation Plan - Reminders App

## Progress Summary
- Total tasks: X
- Completed: Y
- Remaining: Z

## Tasks

### Phase 0: Scaffolding
- [x] F0.1: Task description (completed)
- [ ] F0.2: Task description

### Phase 1: Core Data
- [ ] F1.1: Task description
  - Dependencies: F0.2
  - Spec: specs/F1.1-xxx.md
...
```

## Rules

- **Each task must be atomic** - one feature, one commit
- **Mark dependencies** between tasks
- **Reference spec files** for each task
- **Order by dependency** - tasks that depend on others come later
- **Do NOT implement anything** - planning only
- **Do NOT modify code** - only create/update IMPLEMENTATION_PLAN.md
