#!/bin/bash
# Ralph Wiggum Loop - Reminders App
# Usage: ./loop.sh [mode] [max_iterations]
# Modes: build (default), plan

MODE=${1:-build}
MAX_ITERATIONS=${2:-100}
ITERATION=0

echo "=== Ralph Wiggum Loop ==="
echo "App: Reminders"
echo "Mode: $MODE"
echo "Max iterations: $MAX_ITERATIONS"
echo ""

while [ $ITERATION -lt $MAX_ITERATIONS ]; do
    echo "=== Iteration $((ITERATION + 1)) of $MAX_ITERATIONS (mode: $MODE) ==="

    if [ "$MODE" = "plan" ]; then
        cat PROMPT_plan.md | claude -p --dangerously-skip-permissions --verbose
    else
        cat PROMPT_build.md | claude -p --dangerously-skip-permissions --verbose
    fi

    EXIT_CODE=$?
    ITERATION=$((ITERATION + 1))

    # Push changes if any
    git push origin main 2>/dev/null || git push origin master 2>/dev/null || true

    # Check if we should stop
    if [ $EXIT_CODE -ne 0 ]; then
        echo "Claude exited with code $EXIT_CODE"
    fi

    echo ""
    echo "Sleeping 2 seconds before next iteration..."
    sleep 2
done

echo "=== Loop complete after $ITERATION iterations ==="
