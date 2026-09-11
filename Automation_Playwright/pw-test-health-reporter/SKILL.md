---
name: pw-test-health-reporter
description: >-
  Analyzes Playwright suite health across multiple runs — JavaScript or
  TypeScript project — preferring the playwright-flaky-analyzer CLI/reporter
  when the project has it (deterministic passing/flaky/fixed/newly-failing/
  consistently-failing/skipped classification, 21 root-cause rules, Common
  Errors grouping, HTML/JSON/Markdown output, an opt-in --max-flaky CI gate),
  and falling back to manual multi-run analysis when it doesn't. Use when
  someone asks "how healthy is our test suite", "which tests are flakiest",
  "show me tests linked to open bugs", "find stale skipped tests", or wants
  to run/interpret a playwright-flaky-analyzer report. Also cross-references
  tests skipped/fixme'd against a real bug ID in source — something the tool
  itself doesn't check — flagging stale or untracked ones. Does not diagnose
  any single failure in depth.
license: MIT
metadata:
  author: Shivani Singh
  pack: playwright
  version: 1.0.0
---

# PW Test Health Reporter

You produce a **suite-level health report the team must act on** — never a
verdict on any single failure. Prefer real, deterministic tooling over
prose reconstruction: when the project has `playwright-flaky-analyzer`
available, run it and treat its classification and root-cause output as
authoritative rather than re-deriving flaky/regression judgments by hand.
On top of whatever tool produced the run-history analysis, you add one
thing neither the tool nor a human skim reliably catches: cross-referencing
a skipped/failing test against a *real* bug ID in its source, and flagging
when that reference looks stale.

## When to use
- Someone wants a pass/fail/flake trend across multiple CI runs, not one
  failure.
- Someone wants to know which tests are flakiest, which regressed, or
  which are skipped/muted against a known bug.
- Someone wants to run or interpret a `playwright-flaky-analyzer` report.
- Someone wants stale "known issue" skips surfaced for re-verification.

## When *not* to use
- Root-causing one flaky test in depth → `pw-flaky-debugger` (this skill
  reports the *tool's* per-test root-cause rule output; deep single-test
  investigation is that skill's job).
- Analyzing one failure's trace → `pw-trace-analyzer`.
- Wiring the CI pipeline itself (sharding, retries, artifact upload) →
  `pw-ci-configurator` — this skill only interprets what a health/flake
  analysis produces, including an existing `--max-flaky` gate's result.
- Filing, triaging, or closing a bug — this skill only reads bug
  *references* already in the test suite or already produced by the
  analyzer; it never files, updates, or closes an issue itself.

## Language and project conventions
Support both **JavaScript and TypeScript** test suites — read the
project's config and test files as-is; never rewrite a test file as part
of this skill.

## Workflow
1. **Check whether `playwright-flaky-analyzer` is available** — look for
   it in `package.json` (dependencies/devDependencies), a
   `playwright-flaky-analyzer/reporter` entry in `playwright.config`, or
   an existing `flaky.config.json` / `flaky-results/` directory. Prefer it
   when present; don't require it.
2. **If the tool is available, use its real CLI and schema — don't
   reconstruct its logic in prose:**
   - It needs **2+ report files** to compare; one run is a snapshot only
     ("Need at least 2 valid reports for comparison" is the tool's own
     message for this, not a guess).
   - It accepts either its own reporter's output or **Playwright's
     native JSON reporter** output directly — no conversion needed either
     way.
   - If the custom reporter isn't wired up yet, propose adding it (so
     evidence — screenshots/videos/traces — survives Playwright's own
     output-dir cleanup between runs):
     ```js
     reporter: [
       ['list'],
       ['playwright-flaky-analyzer/reporter', { outputFile: './flaky-results/results.json' }],
     ],
     ```
   - Run the analysis with the flags the request actually calls for —
     `analyze <dir> --format html|json|markdown`, `-o <path>`,
     `--also-json`, `--lookback <n>`, `--files <run list>` (exact runs,
     last one listed = latest), `--max-flaky <n>` (opt-in CI gate,
     evaluated after the report is written). Never invent a flag that
     isn't in its CLI reference.
   - Treat its classification — **passing / flaky / fixed / newly
     failing / consistently failing / skipped** — and its 21 deterministic
     root-cause rules and **Common Errors** fingerprint grouping as
     authoritative. Don't re-derive a different flaky/regression judgment
     by hand when the tool already computed one.
3. **If the tool isn't available**, fall back to whatever run history is
   actually given — pasted JSON/HTML report data or a pass/fail table
   across runs — and say so explicitly. A single run is a snapshot, not a
   trend, regardless of which path produced it. Suggest wiring up
   `playwright-flaky-analyzer` (or at minimum Playwright's own JSON
   reporter across runs) as a concrete improvement, the same way
   `pw-flaky-debugger` suggests enabling trace capture when it's missing.
4. **Layer the bug-ID scan on top of either path** — this is the one
   thing the tool itself does not do. Scan test source for structured
   bug references, prioritizing structured signals over freeform text:
   - `test.skip(condition, reason)`, `test.fixme(condition, reason)`,
     `test.fail()` with a reason string.
   - `test.info().annotations` (e.g. `{ type: 'issue', description }`).
   - Comments near the test referencing a ticket-style ID (`PROJ-1234`), a
     GitHub issue (`#1234`), or an issue-tracker URL.
   A vague comment ("known issue", "flaky, ignore") with no actual
   identifier is **not** a tracked reference — flag it separately as
   *untracked*, distinct from the tool's own free-form "Known Failure"
   triage marking (which isn't tied to a real tracker ID either).
5. **Flag stale bug references.** A test that's been skipped/fixme'd
   against a bug ID for a long time is worth re-verifying — the
   underlying bug may already be fixed. If an issue-tracker integration
   (e.g. Jira MCP) is available, you may optionally check whether that
   bug ID is still open, but never assume a status you haven't confirmed,
   and never un-skip a test or close/reopen the bug yourself — recommend
   the re-check to a human.
6. **Recommend, don't act.** Quarantine candidates, re-triage candidates,
   and regressions needing attention are recommendations — never edit a
   test file, remove a `skip`/`fixme`, change a bug annotation, or modify
   `flaky.config.json`/CI gate thresholds as part of this skill.
7. **State confidence** based on how much run history was actually
   available and which path produced the analysis — a tool-generated
   report across many runs is stronger evidence than a hand-reconstructed
   summary from one pasted run.

## Output format
1. **Method** — whether `playwright-flaky-analyzer` was used (and which
   flags) or a manual fallback, and how many runs were actually analyzed.
2. **Health breakdown** — the tool's own categories when it ran
   (passing/flaky/fixed/newly failing/consistently failing/skipped), or
   the closest equivalent from manual analysis.
3. **Root cause / Common Errors** — the tool's rule-based findings and
   error groupings when available; otherwise say root-causing wasn't
   performed here and point to `pw-flaky-debugger`/`pw-trace-analyzer`.
4. **Bug-ID cross-reference** — tests skipped/failing with a tracked bug
   ID (and whether it looks stale) vs. an untracked vague reference.
5. **CI gate status** — if `--max-flaky` was set, whether it passed or
   would fail the build, and at what threshold.
6. **Recommendations** — quarantine/re-triage candidates.
7. **Confidence / assumptions** — run count, method, and what would
   sharpen the report further.

### Example
```bash
npx playwright-flaky-analyzer analyze ./flaky-results --format json --max-flaky 5
```
```typescript
// in the suite
test.skip(true, 'PROJ-4821: checkout total misrenders on Safari, tracked');
```
```
Method: playwright-flaky-analyzer, 12 runs analyzed, --max-flaky 5
Health: 3 flaky, 1 newly failing, 1 consistently failing, 58 passing
Common Errors: "Timeout waiting for locator('[data-testid=cart-total]')" — 3 tests, RC-004 (timing)
Known issue (tracked)
  Test      : checkout.spec.ts › shows correct total on Safari
  Reference : PROJ-4821 (via test.skip reason)
  Status    : skipped for 94 days across available run history — flagged stale, recommend re-verifying PROJ-4821 is still open
CI gate: PASS (3 flaky ≤ threshold 5)
```

## Guardrails
- This is a **report for the team to act on** — never edit a test file,
  remove or add a `skip`/`fixme`, change a bug annotation, or modify
  `flaky.config.json`/CI thresholds yourself.
- Never invent a CLI flag, config key, or output field the tool doesn't
  actually have — check its real CLI reference rather than guessing.
- Never invent run history, pass/fail counts, or a bug's ID/status you
  weren't given or couldn't confirm through an available integration.
- Never assume a referenced bug is still open or already resolved
  without confirming it — state it as unverified otherwise, and never
  close or reopen a bug yourself.
- Treat a vague "known issue" comment with no real identifier as
  **untracked**, not equivalent to a tracked bug reference — don't let it
  suppress a failure that actually needs attention.
- When the tool is available, don't re-derive its classification or
  root-cause judgment by hand — use its output; when it isn't, say
  explicitly that the report is a manual fallback, not tool-verified.
- Don't root-cause a flaky or regressed test in depth here — that's
  `pw-flaky-debugger`'s or `pw-trace-analyzer`'s job; this skill reports
  and cross-references, it doesn't perform the deep investigation.
- State confidence honestly based on the run history and method actually
  used — a single run is a snapshot, not a trend, regardless of path.
- Preserve the project's JS/TS conventions when quoting test source.
