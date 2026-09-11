---
name: pw-test-step-reporter
description: >-
  Structures a Playwright test so it explains itself in the HTML report —
  test.step for logical phases, testInfo.attach for evidence (screenshots,
  JSON, diffs), expect.soft with a hard gate for grouped checks, and
  annotations for issue/bug-ID traceability. Use when an SDET says "make
  this test's report readable", "group this into steps", "attach a
  screenshot to the report", "how do I do soft assertions", or "why can't
  I tell which step failed in CI". Produces a report a human can debug
  from without re-running the test — a draft the engineer reviews and runs.
license: MIT
metadata:
  author: Shivani Singh
  pack: playwright
  version: 1.0.0
---

# PW Test Step Reporter

You structure a test so that **when it fails in CI, a human understands
what happened from the HTML report alone** — never from re-running it
locally first. Every logical phase becomes a named `test.step`; evidence
gets attached, not logged; and annotations keep tests traceable to the
issues they cover — including the bug-ID references `pw-test-health-reporter`
looks for.

## When to use
- Writing a non-trivial multi-step flow that will be hard to debug from a
  bare stack trace.
- Someone asks to group a test into steps, attach evidence, use soft
  assertions, or add issue/known-issue annotations.
- A test fails in CI and nobody can tell which phase broke without
  re-running it.

## When *not* to use
- Generating the flow itself from a scenario → `pw-test-generator`.
- Diagnosing *why* a step actually fails (root cause) →
  `pw-flaky-debugger` / `pw-trace-analyzer`.
- Configuring CI-level reporters/artifacts at the pipeline level →
  `pw-ci-configurator`.

## Workflow
1. **Wrap each logical phase in `test.step`**, named like a test plan —
   imperative and business-readable ("Add Pro plan to cart"), never
   mechanical ("click button #3"). Steps appear as a collapsible, timed
   tree in the HTML report, turning a failure into "which step failed"
   instead of "which line number."
2. **Attach evidence, don't log it.** `console.log` never appears in the
   HTML report; `testInfo.attach` puts a screenshot, the relevant JSON
   payload, or a computed diff into the report at the step where it
   matters.
3. **Use `expect.soft` only for grouped, independent checks**, and always
   end with a hard gate (`expect(test.info().errors).toHaveLength(0)`, or
   a hard `expect`) so the test still fails — soft assertions with no hard
   gate silently pass a test that actually found problems.
4. **Annotate for traceability.** Push
   `{ type: 'issue', description: '<url or ID>' }` to link a test to a
   tracked bug, and use a real, checkable identifier for any
   `test.skip`/`fixme` reason — a vague "known issue" comment with no ID is
   exactly what `pw-test-health-reporter` flags as untracked.
5. **Box shared helper steps** (`{ box: true }`) so a failure inside a
   login/setup helper surfaces at the calling test, not buried in the
   helper's internals.
6. **Configure reporters to carry this evidence** —
   `trace: 'retain-on-failure'`, `screenshot: 'only-on-failure'`, and an
   `html` reporter so every attachment and step actually renders somewhere
   a human reads it.

## Output shape
```typescript
test('checkout flow', async ({ page }, testInfo) => {
  await test.step('Sign in', async () => {
    await page.getByLabel('Email').fill('buyer@example.com');
    await page.getByRole('button', { name: 'Sign in' }).click();
    await expect(page.getByText('Welcome back')).toBeVisible();
  });

  await test.step('Verify all profile fields at once', async () => {
    await expect.soft(page.getByLabel('Display name')).toHaveValue('Ada Lovelace');
    await expect.soft(page.getByLabel('Email')).toHaveValue('ada@example.com');
  });
  expect(test.info().errors).toHaveLength(0); // hard gate — soft failures still fail the test

  await test.step('Capture dashboard state', async () => {
    await testInfo.attach('dashboard.png', {
      body: await page.screenshot({ fullPage: true }),
      contentType: 'image/png',
    });
  });
});

test('payment retries on gateway 503', async ({ page }) => {
  test.info().annotations.push({ type: 'issue', description: 'PROJ-4821' }); // real ID, not a vague comment
  // ...
});
```

## Guardrails
- Never leave a test as a flat, unstepped wall of actions when it's
  non-trivial — a failure should point at a phase, not just a line number.
- Never use `console.log` as "evidence" — it doesn't appear in the HTML
  report; use `testInfo.attach`.
- Never use `expect.soft` without a following hard gate — a test with only
  soft assertions can go green while real checks failed.
- Never skip a test with a bare `test.skip()` and no reason string, and
  never use a vague "known issue" comment where a real, checkable bug ID
  belongs.
- Never attach a full-page screenshot on every step of a passing test —
  attach on failure or at genuine checkpoints; bloated reports get
  ignored.
- Name steps after intent, not mechanics ("Submit signup form", not
  "click button").
