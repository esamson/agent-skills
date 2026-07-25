---
name: address-review-findings
description: Addresses code review findings one at a time with TDD, incremental slices, and one commit per finding. Use when the user asks to fix review feedback, address review findings, triage PR comments, or implement review remediation incrementally.
---

# Address Review Findings

## Overview

Turn a review into a stack of small, verifiable commits — **one finding at a time**. Each finding gets its own RED → GREEN → VERIFY → COMMIT cycle. Do not batch unrelated fixes into one commit.

**Compose with:**
- `incremental-implementation` — one slice per finding
- `test-driven-development` — prove each fix with a test
- `git-workflow-and-versioning` — atomic commits and message style

## When to Use

- User says "address review findings", "fix review feedback", "implement the review"
- After `/review` or a PR review with categorized findings
- When remediating Critical / Required / Important items from a structured review

**When NOT to use:** Exploratory refactors with no review input, or a single trivial one-line fix.

## Workflow

```
Review findings (ordered by severity)
    │
    ▼
For EACH finding ─────────────────────────────┐
    │                                          │
    ├─ 1. Scope to ONE finding only            │
    ├─ 2. RED: write/adjust failing test       │
    ├─ 3. GREEN: minimal fix                   │
    ├─ 4. VERIFY: focused tests → full suite     │
    ├─ 5. COMMIT: one finding, one message     │
    └─ 6. Next finding ◄───────────────────────┘
```

### Step 0: Triage

1. Read the review. Order work: **Critical → Required → Important → Optional/Nit**.
2. Skip **FYI** and pre-existing nits unless the user asked to include them.
3. If fetch + render are both broken for the same finding, fix **both** in that finding's slice (one commit) — a render-only fix that still blocks on a bad fetch is incomplete.

### Step 1: One Finding, One Slice

Before touching code, state:

```
FINDING N: [severity] — [one-line summary]
FILES: [expected touch set]
TEST PLAN: [what will fail before the fix]
OUT OF SCOPE: [other findings, drive-by refactors]
```

**Scope discipline:** Do not fix adjacent findings, rename unrelated code, or "clean up while here."

### Step 2: RED — Test First

Discover the repo's test commands before writing tests (see `test-driven-development`).

| Finding type | Test strategy |
|---|---|
| Pure logic / compute | Unit test on the function |
| API / route | Route or contract test |
| UI not directly testable | Extract a **pure policy/helper** (e.g. `*IdlePolicy`, `formatDelta`) and test that; wire the UI to the helper |
| Refactor / perf | Existing tests must stay green; add a regression test if coverage is thin |
| Nit / formatting | Test only when behavior changes (e.g. rounding before display) |

The test must **fail** (or would have failed) on the pre-fix code. A test that passes immediately proves nothing.

### Step 3: GREEN — Minimal Fix

- Smallest diff that satisfies the finding and the test.
- Prefer extracting policy over scattering new conditionals in UI entry points.
- Reuse existing patterns in the codebase (naming, module placement, test file location).

### Step 4: VERIFY

Per finding, in order:

1. Focused test: `testOnly *RelevantSpec*` (or repo equivalent)
2. Broader suite if the change crosses modules
3. Build / compile if tests don't cover the layer
4. Project formatting/lint gate if the repo requires it before commit

Do not repeat the same command on unchanged code.

### Step 5: COMMIT — One Finding Each

Only commit when the user asked for commits (or project rules require it).

```bash
git add <only files for this finding>
# run project format/lint gate if required
git commit -m "$(cat <<'EOF'
<type>: <imperative summary>

<Why this fixes the review finding — not a diff recap.>
EOF
)"
```

**Message types:** `fix` for bugs/regressions, `refactor` for internal structure with same behavior, `test` for test-only (rare as standalone finding commit).

After all findings:

```bash
git log --oneline -N   # N = number of findings addressed
```

## Patterns from Real Reviews

### UI gated on wrong data

**Symptom:** Non-idle surfaces wait on idle-only API feeds.

**Move:** Extract phase-aware policy; test loading/fetch rules separately; update fetch **and** render in the same finding when both cause the bug.

```
*IdlePolicy.needsX(phase)     # what the surface needs
*IdlePolicy.loadingState(...) # when UI can render
*IdlePolicy.refreshFetchesX(phase)  # when poll/refresh hits the endpoint
```

### Performance / redundant work

**Symptom:** Recomputing full history twice, or polling endpoints the current phase never uses.

**Move:** Refactor to incremental work (fold once, apply delta) or conditional fetch. Keep behavior identical — existing tests are the safety net; add a test only if the contract was untested.

### Display nits

**Symptom:** Float equality, `+0` / `-0`, formatting edge cases.

**Move:** Extract formatter; test rounded output strings, not raw floats.

## Finding → Commit Map

Track progress explicitly:

| # | Severity | Summary | Test added | Commit |
|---|----------|---------|------------|--------|
| 1 | Required | … | `FooSpec` | `abc1234` |
| 2 | Required | … | `BarSpec` | `def5678` |

Mark FYI items as skipped with reason.

## Anti-Patterns

| Don't | Do instead |
|---|---|
| One commit for all review fixes | One commit per finding |
| Fix render but leave fetch coupled | Fix both when the finding is "blocks live UI" |
| Skip tests because "it's just UI" | Extract and test pure policy |
| Batch Important + Optional nits | Optional only if user asked |
| Run full suite before every sub-step | Focused test per finding; full suite after cross-cutting changes or at end |
| Drive-by refactors in a finding commit | Note separately; separate commit if user wants it |

## Red Flags

- Multiple findings in one commit
- No test for a Required/Critical behavior fix
- Render fix that still fails when the idle-only endpoint errors
- `git add -A` sweeping unrelated files
- Claiming "all findings addressed" while FYI/manual items were intentionally deferred but not listed

## Verification

After the last finding:

- [ ] Each Critical/Required/Important finding has its own commit (or user-approved grouping)
- [ ] Each fix has a test or is covered by existing tests that would fail on regression
- [ ] Focused tests passed per finding; full suite green at end
- [ ] No unrelated files in any commit
- [ ] Skipped items (FYI, manual smoke) listed for the user

## See Also

- `code-review-and-quality` — how findings are categorized
- `incremental-implementation` — slice sizing and increment cycle
- `test-driven-development` — RED/GREEN/REFACTOR and Prove-It for bugs
- `git-workflow-and-versioning` — atomic commits and message format
