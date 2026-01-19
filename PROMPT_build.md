# Build Mode - Reminders App

Study AGENTS.md for project-specific guidance and patterns.
Study IMPLEMENTATION_PLAN.md for the current task list.
Study the specs/ directory for detailed feature requirements.

## Your Mission

1. **Orient**: Read IMPLEMENTATION_PLAN.md to understand current progress
2. **Select**: Pick the FIRST uncompleted task (marked with `[ ]`)
3. **Investigate**: Using parallel subagents, study relevant existing code and the corresponding spec file
4. **Implement**: Write code following patterns in existing codebase
5. **Validate**: Run `./gradlew check` (use only 1 subagent for builds/tests)
6. **Fix**: If tests fail, debug and fix until green
7. **Update**: Mark task complete in IMPLEMENTATION_PLAN.md (change `[ ]` to `[x]`)
8. **Commit**: Commit with descriptive message capturing the WHY
9. **Exit**: Exit when task is complete

## Rules

- **One task per iteration** - do not start a second task
- **Don't assume functionality is missing** - study the code first
- **Follow existing patterns** - match the code style already in the project
- **Tests are mandatory** - every feature needs corresponding tests
- **Capture the WHY** in commit messages, not just the WHAT
- **If blocked**: Document the blocker in IMPLEMENTATION_PLAN.md and move to next task

## Commands

```bash
# Build
./gradlew build

# Run tests
./gradlew check

# Run Android app
./gradlew :composeApp:installDebug

# Clean build
./gradlew clean build
```

## Linux Server (no iOS)

If running on Linux (Hetzner, CI, etc.), check the `SKIP_IOS` environment variable.
When `SKIP_IOS=true`, skip iOS-related tasks (F3.x, F4.3, F4.4) and use these commands:

```bash
# Build (skip iOS)
./gradlew build -x linkDebugTestIosX64 -x linkReleaseTestIosX64

# Run tests (skip iOS)
./gradlew check -x iosX64Test -x iosSimulatorArm64Test -x linkDebugTestIosX64

# If a task is iOS-only (F3.x, F4.3, F4.4), mark it SKIPPED in IMPLEMENTATION_PLAN.md:
# - [SKIPPED] F3.1: iOS Navigation (requires macOS)
```

## Exit Conditions

Exit after:
- Successfully completing one task and committing
- Encountering an unresolvable blocker (document it first)
- All tasks are complete
