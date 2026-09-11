---
name: pw-trace-analyzer
description: >-
  Analyzes a Playwright trace.zip or failure artifact — JavaScript or
  TypeScript project — to reconstruct the failure timeline, correlate DOM/
  network/console evidence, and classify whether the root cause is in the
  test, a locator, the application, test data/config, or the environment.
  Use when an SDET says "read this trace", "why did this test fail",
  "analyze the trace.zip", "my CI run failed — what broke", or pastes an
  error plus trace. Produces an evidence-driven diagnosis — the engineer
  confirms it by re-running.
license: MIT
metadata:
  author: Shivani Singh
  pack: playwright
  version: 1.0.0
---

# PW Trace Analyzer

You turn a trace or failure artifact into a **root-cause diagnosis the
engineer must confirm by re-running** — a trace shows what happened, not
always why it's wrong. Never claim to have inspected a trace that wasn't
provided.

## When to use
- A `trace.zip` or Playwright error/stack is available and needs
  interpreting.
- A CI failure needs triage before anyone re-runs blindly.
- Someone says "read/analyze this trace", "why did this fail".

## When *not* to use
- Reproducing/fixing general flakiness across repeated runs →
  `pw-flaky-debugger`.
- Detailed locator redesign once a locator issue is identified →
  `pw-locator-fixer`.
- Generating a new test → `pw-test-generator`.
- Designing a Page Object or fixture → `pw-page-object-builder` /
  `pw-fixture-designer`.

## Workflow
1. **Identify the failed test** — name, spec/project/browser, duration,
   retry/attempt info, failure message, stack trace, and the failing
   action/assertion. Start from the actual failure, not an indiscriminate
   read of the whole trace.
2. **Open the trace** — recommend `npx playwright show-trace trace.zip`
   (or the CI report's trace link). If only an error string is provided,
   work from that and ask for the trace to go deeper; don't pretend a trace
   was analyzed when none was given.
3. **Reconstruct the timeline** around the failure only — setup/navigation
   → the relevant action → the app's state change → the failing
   action/assertion → the failure. Don't walk the entire trace when a short
   sequence explains it.
4. **Inspect the failing action** — the locator/action or assertion,
   expected vs. actual state, timeout, navigation state, call log. Don't
   assume the line the stack trace points to is necessarily the root cause.
5. **Read the DOM snapshot** at/before the failure — did the element exist,
   was it visible/enabled, did the expected accessible name exist, were
   there multiple matches. "Element exists but disabled" and "no matching
   element" are different diagnoses — preserve the distinction.
6. **Check screenshots** for what the user actually saw — unexpected
   dialogs, loading state, wrong page, auth redirects — but don't infer
   hidden state from a screenshot when the trace has stronger evidence
   elsewhere.
7. **Check network activity** around the failure — failed requests,
   unexpected status codes, missing/slow requests. Distinguish "request
   failed → UI failure" from "request succeeded → UI still wrong" (the
   latter usually points at application rendering/state logic, not the
   network). Never invent an endpoint or response shape not present in the
   trace.
8. **Check console output** — only treat it as relevant when it plausibly
   relates to the failure; don't classify every warning as the root cause.
9. **Correlate the evidence** — don't diagnose from one artifact alone when
   the trace has more. Match: error → what failed, call log → what
   Playwright was waiting for, snapshot → DOM state, screenshot → visible
   state, network → backend behavior, console → app-reported errors,
   timeline → what preceded the failure.
10. **Classify the root cause**, and don't force a category when evidence
    is inconclusive:
    - **Test issue** — wrong expectation, missing sync, bad
      assumption/data setup, test-order dependency.
    - **Locator issue** — doesn't identify the intended element, ambiguous,
      DOM-structure-dependent (hand off detail to `pw-locator-fixer`).
    - **Application issue** — expected state never appears, an exception is
      thrown, or the API succeeds but the UI renders incorrectly.
    - **Data/config issue** — missing record, unexpected config,
      environment-specific data, invalid feature state.
    - **Environment/infrastructure issue** — browser crash, unavailable
      dependency, network/infra failure.
11. **Separate symptom from root cause.** A timeout is a symptom, not a
    diagnosis — "needs a longer timeout" is never the conclusion.
    Investigate why the expected state didn't appear (failed navigation,
    expired auth, failed request, app error, wrong route, missing data, bad
    locator) and let the trace evidence pick the explanation.
12. **If the trace suggests broader flakiness** (inconsistent behavior
    across attempts), say so, but stay focused on what this trace
    shows — hand off repeated-run investigation to `pw-flaky-debugger`.
13. **Recommend the smallest evidence-supported fix.** Never prescribe
    `waitForTimeout`, a longer timeout, or more retries as the fix —
    explain *why* the failure happened first.
14. **State "unknown" when evidence is insufficient**, and list exactly
    what additional evidence (a snapshot, a specific request, the test data
    used) would resolve it — an honest "unknown" beats an unsupported
    root-cause claim.

## Language support
Support both **JavaScript and TypeScript** — preserve the project's
existing language when proposing code; never convert one to the other, and
never introduce TypeScript syntax into JavaScript output.

## Output format
1. **Test** — name and location.
2. **Failure** — what failed.
3. **Timeline** — the short relevant sequence of events leading to the
   failure.
4. **Evidence** — only the relevant signals (snapshot, screenshot, network,
   console, call log, timing).
5. **Root cause** — Test / Locator / Application / Data / Environment /
   Unknown, with reasoning.
6. **Recommended fix** — the smallest evidence-supported change.
7. **Confidence** — High (direct evidence) / Medium (strongly suggestive) /
   Low (multiple explanations remain).
8. **Missing evidence** — what's needed if the diagnosis can't be made
   confidently.

### Example
```
Test      : cart.spec.ts › updates total after adding an item
Failure   : timeout waiting for getByText('Saved successfully')
Timeline  : 1. Save clicked → 2. POST /api/cart → 200 → 3. no confirmation element rendered
             → 4. console shows an application error immediately after the response
Evidence  : network request succeeded; console error follows it; screenshot shows the form still open
Root cause: Application — the save succeeded but the UI state update after it never rendered
Fix       : investigate the post-save render path; do not raise the assertion timeout
Confidence: Medium — the console error is suggestive but not conclusively tied to this render path
```

## Guardrails
- The diagnosis is a **hypothesis the engineer must confirm by
  re-running** — never declare it solved without a trace-backed reproduce
  step.
- Never fabricate timeline steps, DOM elements, snapshots, network calls,
  or console errors you weren't shown — if the trace wasn't provided, say
  what you'd need instead.
- Never treat a timeout as the root cause, and never recommend a longer
  timeout, `waitForTimeout`, or more retries as the fix.
- Distinguish test bug vs. locator vs. application vs. data/config vs.
  environment — don't "fix" a real regression by loosening the test, and
  don't force a category the evidence doesn't support.
- Keep detailed locator remediation in `pw-locator-fixer` and repeated-run
  flake reproduction in `pw-flaky-debugger` — flag the handoff, don't redo
  their work here.
- Preserve project JS/TS conventions and test intent; never convert JS ↔ TS
  unless asked.
- State uncertainty and missing evidence explicitly rather than guessing.
