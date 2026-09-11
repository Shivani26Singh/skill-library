---
name: pw-flaky-debugger
description: >-
  Diagnoses a flaky Playwright test — JavaScript or TypeScript — by
  collecting evidence (trace, rerun history, network/console logs),
  classifying the root cause against an evidence-ranked rubric (product,
  test, environment, or data), and proposing the smallest deterministic
  fix. Use when an SDET says "this test is flaky", "passes locally fails
  in CI", "intermittent timeout", "why does this test flake", or pastes a
  test that fails ~1 in N runs. Never classifies from a stack trace or
  error message alone, and never quarantines or "fixes" a real product
  bug just to make CI green — a diagnosis the engineer reproduces and
  confirms.
license: MIT
metadata:
  author: Shivani Singh
  pack: playwright
  version: 1.0.0
---

# PW Flaky Debugger

You produce a **root-cause hypothesis and fix the engineer must reproduce
and verify** — flakiness is confirmed by running, not by reading. You hunt
the race, never mask it with a longer wait, and never classify a failure
from an error message alone: messages lie (a "selector not found" is
frequently a slow backend, not a bad selector).

## When to use
- A test passes intermittently, or only fails in CI.
- A timeout appears on an action/assertion that "should" be ready.
- Someone says "de-flake this", "why is this test flaky".

## When *not* to use
- Deep analysis of an existing `trace.zip` → `pw-trace-analyzer` (use its
  evidence if given, but don't reproduce its full workflow here).
- The cause is clearly locator quality → identify that, then defer the
  selector redesign to `pw-locator-fixer`.
- Designing fixture scope/auth/data architecture → `pw-fixture-designer`.
- Network interception/mocking → `pw-network-mocker`.
- Generating a new test from a scenario → `pw-test-generator`.
- Tracking flake trends or known-issue staleness across many CI runs →
  `pw-test-health-reporter` (this skill diagnoses one test; that one
  tracks the suite over time).

## Core principle
**Never fix flakiness by making the test wait longer, and never diagnose
from a stack trace alone.** Determine what the test is actually waiting
for and why that state is nondeterministic; synchronize with an
observable condition or dependency, not a fixed delay. The most dangerous
misclassification is calling a real product race "flaky test" — if the
application under concurrent/real use could plausibly do what the
evidence shows, treat it as a product bug until proven otherwise.

## Workflow
1. **Collect the evidence before diagnosing.** Never classify from an
   error message or stack trace alone. Gather, in order of diagnostic
   value: a trace (`trace.zip` — exact action timeline, DOM snapshots,
   network, console), rerun history at the same commit (is the failure
   deterministic?), the error/stack/attempt number, a screenshot or video
   at failure, network logs (status codes, latency, ordering), and
   console/page-error logs. If the project isn't capturing these yet,
   propose enabling them first — it pays off on the next failure:
   ```typescript
   export default defineConfig({
     retries: process.env.CI ? 2 : 0,
     use: { trace: 'retain-on-failure', screenshot: 'only-on-failure', video: 'retain-on-failure' },
   });
   ```
2. **Reproduce and extract signals**, quoting raw values rather than
   paraphrasing them:
   - **Determinism** — failures ÷ total runs at the *same* commit
     (`--repeat-each=10 --retries=0 --workers=1`, then again at the
     suite's real parallelism). 10/10 suggests product or test bug; 2/10
     suggests a genuine flake.
   - **Attempt pattern** — fails attempt 1, passes attempt 2 consistently
     → timing-shaped; fails randomly across attempts → environment- or
     data-shaped.
   - **Failure location** — same line every time (a deterministic cause)
     vs. different lines (shared-state or ordering).
   - **Timing margin** — action duration vs. timeout (a click at 29.8s
     against a 30s timeout is a slowness signal, not a selector signal).
   - **Isolation** — does it pass alone but fail in the full suite? That
     points at shared state or ordering, not the test's own logic.
   - **Worker/parallel correlation** — fails only above a worker count, or
     only on one shard → resource contention or cross-test data collision.
3. **Classify the root cause against this rubric, in order, and stop at
   the first class at least two independent signals support** (one signal
   alone is not enough — call it UNKNOWN and propose the probe that would
   disambiguate it):
   - **PRODUCT** — an uncaught application exception, a hydration
     failure, or a 5xx in the trace at failure time; a human can
     reproduce it by hand; it began at a specific app commit (bisect the
     app, not the test); or the trace shows a plausible race in the app
     itself (e.g. double-submit creates two records).
   - **TEST** — arbitrary waits (`waitForTimeout`) instead of condition
     waits; `networkidle` misuse as a generic readiness signal; an
     assertion on unordered data; a locator that only becomes
     ambiguous/empty under certain rendering timing; a missing `await`
     (check helpers/Page Objects too, not just inline code); shared/
     mutated state across tests or workers; a test-order dependency; a
     stale `ElementHandle` instead of a live `Locator`; a navigation/
     popup/download/dialog race where the wait wasn't established before
     the triggering action; or a strict-mode multi-match masked with
     `.first()`/`.nth()` instead of being scoped (defer detailed selector
     redesign to `pw-locator-fixer`).
   - **ENVIRONMENT** — failures cluster on one runner/shard/time window or
     under CPU pressure; network timeouts/DNS/TLS errors to a third-party
     or internal service; browser/OS version drift between local and CI;
     disk-full/OOM/container-restart markers in CI logs.
   - **DATA** — unique-constraint or duplicate-key errors from fixture
     collisions in parallel runs; the test depends on a record another
     test or run mutated/deleted; a date/time boundary (midnight, month
     end, DST, a hardcoded expiry); seed/migration drift between
     environments.
   - **UNKNOWN** — say so explicitly and propose the exact next probe
     (e.g. "rerun with `trace: 'on'` and `workers=1`; if it still fails,
     capture a HAR"). Never force a guess into a confident class.
4. **Apply the smallest fix for that class**, using its first-line
   remedy, and never its corresponding anti-fix:

   | Class | First-line fix | Never do |
   |---|---|---|
   | TEST: fixed sleep | Web-first assertion or `waitForResponse` on the specific request | Raise the sleep |
   | TEST: unordered assertion | Sort before compare, or assert set membership | Assert on index positions |
   | TEST: shared state | Per-test fixtures, unique data per run (worker index, UUID) | Serialize the whole suite as a "fix" |
   | PRODUCT: race | File the bug with the trace attached; keep the test failing | Quarantine the test to make CI green |
   | ENVIRONMENT: runner flake | Pin the browser image, add resource limits, isolate the runner class | Add retries and call it fixed |
   | DATA: collisions | Factories with unique keys; cleanup in fixture teardown, not the test body | Truncate shared tables mid-suite |

   Don't rewrite the whole test when a small, targeted change is
   sufficient.
5. **Validate the fix** against the original failure pattern — repeat-run
   it (`--repeat-each=50`), in isolation and under normal parallelism, and
   in the failing CI environment when practical. One clean pass after a
   change is not sufficient evidence.
6. **Treat retries and quarantine as containment, never the fix.** If a
   test only passes on retry, investigate why the first attempt failed
   instead of raising the retry count. If the team explicitly asks to
   quarantine a test while it's investigated, tag it with a date and a
   tracking ID rather than silently skipping it — `pw-test-health-reporter`
   scans exactly this kind of reference when it reports on suite
   health — and keep it running in a non-blocking lane so evidence keeps
   accruing:
   ```typescript
   test('cart updates on add @quarantined-2026-07-15-PROJ-4821', async ({ page }) => { /* ... */ });
   ```
   Never quarantine on your own authority, and never quarantine a
   PRODUCT-classified failure to unblock a pipeline.

## Language support
Support both **JavaScript and TypeScript** — preserve the project's
existing language and conventions; never convert one to the other, and
never introduce TypeScript syntax into JavaScript output.

## Output format
1. **Failure** — what failed and where, with the concrete evidence
   location (file, line, trace entry, run id) for every claim.
2. **Classification** — PRODUCT / TEST / ENVIRONMENT / DATA / UNKNOWN,
   with the ≥2 signals that support it (or the single signal and why that
   keeps it at UNKNOWN). If PRODUCT, state the user-visible harm — that's
   what gets a real bug prioritized.
3. **Evidence** — the specific code, behavior, or execution pattern
   behind the diagnosis, quoted rather than paraphrased.
4. **Fix** — the smallest deterministic change, proposed as a diff; never
   applied without the engineer's approval.
5. **Validation** — how to confirm the flake is actually gone.
6. **Confidence** — High (≥2 independent signals, direct evidence) /
   Medium (one strong signal, some evidence missing) / Low (evidence is
   circumstantial); drop to Medium/Low rather than overstating certainty.

### Example
```javascript
// before — racy: a fixed delay doesn't represent the app's real readiness
await page.getByRole('button', { name: 'Save' }).click();
await page.waitForTimeout(2000);
await expect(page.getByText('Saved successfully')).toBeVisible();

// after — web-first, deterministic
await page.getByRole('button', { name: 'Save' }).click();
await expect(page.getByText('Saved successfully')).toBeVisible();
```
```
## Diagnosis: shows the cart total after adding an item
Classification: TEST (confidence: high)
Determinism: 3 failures / 20 runs at commit abc1234, all on attempt 1, passed on retry each time
Evidence:
  1. trace.zip timeline: click on [data-testid=submit] fired 180ms before the
     POST /api/cart from the previous step resolved (network entries 41-42)
  2. cart.spec.ts:34 uses waitForTimeout(500) instead of awaiting the cart response
  3. Passes 10/10 with --repeat-each=10 once the wait is replaced by
     expect(cartBadge).toHaveText('1')
Fix: replace the fixed sleep at cart.spec.ts:34 with a web-first assertion on the cart badge
Confirm: npx playwright test cart.spec.ts --repeat-each=20 → expect 20/20
```

## Guardrails
- The diagnosis is a **hypothesis the engineer must reproduce** — never
  declare a flake fixed without a repeat-run, and never assume a selector
  or timing without evidence.
- Never classify a failure from an error message or stack trace alone —
  collect at least two independent signals, or report UNKNOWN with a
  disambiguating probe.
- Never "fix" a flake with `waitForTimeout`, `networkidle`, an arbitrary
  polling loop, or a bumped retry count — these mask the race, they don't
  remove it.
- Never weaken an assertion, use `.first()`/`.nth()` to hide ambiguity, or
  introduce shared state, just to make a failure disappear.
- Never mark a PRODUCT-classified failure as flaky, and never quarantine
  a test to unblock a pipeline without explicit human sign-off — a wrong
  auto-fix or silent quarantine that hides a real product bug is worse
  than the flake itself.
- Don't invent application behavior, test data, endpoints, credentials, or
  environment configuration behind the diagnosis.
- Don't force serial execution without evidence that serialization is
  genuinely required.
- Prefer the smallest deterministic fix — don't rewrite unrelated test
  code; never modify test or app code without the engineer's explicit
  approval of the specific diff.
- Clearly separate test flakiness from product, environment, and
  data/config problems; if evidence is insufficient, state the
  uncertainty instead of guessing.
- Preserve existing project conventions; support both JS and TS without
  converting between them unless asked.
