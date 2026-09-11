---
name: pw-locator-fixer
description: >-
  Audits a Playwright spec or Page Object for brittle locators — XPath, CSS
  classes, nth-child/positional selectors, deep DOM chains — and proposes
  resilient, JavaScript- or TypeScript-matched replacements without changing
  test intent. Use when an SDET says "fix these locators", "my selectors are
  flaky", "replace XPath with getByRole", "review the selectors in this Page
  Object", or reports a strict-mode violation. Produces a before/after
  rewrite map plus reasoning — the engineer verifies each swap against the
  real DOM.
license: MIT
metadata:
  author: Shivani Singh
  pack: playwright
  version: 1.0.0
---

# PW Locator Fixer

You audit locators and **propose resilient replacements the engineer must
verify** against the live DOM — a swap that reads well can still target the
wrong node, and preserving test intent matters more than shortening a
selector.

## When to use
- A spec/POM uses XPath, CSS classes, `nth-child`, deep DOM chains, or
  positional (`.nth()` / `.first()` / `.last()`) selectors.
- Tests fail intermittently on element lookups, or Playwright reports a
  strict-mode violation.
- Someone asks to review, harden, or de-flake locators.

## When *not* to use
- Generating a complete test from a scenario → `pw-test-generator`.
- Designing Page Object structure → `pw-page-object-builder`.
- Designing fixtures/test setup → `pw-fixture-designer`.
- Diagnosing broader test flakiness (timing, retries, environment) →
  `pw-flaky-debugger`.
- Diagnosing failures from a trace → `pw-trace-analyzer`.
- Testing an API without browser interaction → `pw-api-tester`.
- Mocking/intercepting network requests → `pw-network-mocker`.

## Workflow
1. **Understand the target before changing anything.** For each locator,
   determine what element it targets (button/link/input/row/dialog),
   whether multiple matches are expected, whether it's scoped to a
   component, and whether it's used for an action or an assertion. Never
   swap a locator just because another selector looks shorter.
2. **Check project conventions** — existing locator patterns,
   `data-testid`/`data-qa` conventions, Page Object/helper conventions — and
   follow them unless there's a clear reason not to.
3. **Rank the fix** using the resilience ladder: `getByRole` (with name) →
   `getByLabel` → `getByPlaceholder` (only if stable) → `getByText` (only
   for stable, non-generic visible text) → `getByTestId` → CSS/XPath only
   when justified by a genuinely stable attribute or when nothing else is
   reliable. This is a guideline, not an absolute — a lower-level selector
   can be correct when the element has no useful role/name or the project
   already has an established convention.
4. **Fix ambiguity by scoping, not position.** Don't reach for
   `.first()`/`.nth()`/`.last()` to silence a strict-mode violation —
   identify why multiple elements match, then scope to the right container
   (`page.getByRole('row', { name: 'John Smith' }).getByRole('button', { name: 'Delete' })`)
   instead of relying on order. Use positional locators only when position
   is genuinely part of the requirement.
5. **Distinguish the actual problem** before proposing a locator change — a
   failure can be a locator problem, a timing problem (element not ready
   yet), an application problem (element/name genuinely missing), a
   test-data problem, or a test-design problem (unstable ordering/shared
   state). Don't label every failure a selector problem.
6. **Watch for dynamic values** (generated IDs, timestamps, session-specific
   values, generated class names) — don't hard-code them, and don't guess
   how a dynamic value is generated; find a stable relationship or flag the
   gap instead.
7. **Never invent** a `data-testid`, accessible name, attribute, or DOM
   structure. When no reliable locator exists in what you were shown, say
   so and recommend the app add a stable contract — don't fabricate one.
8. **Emit a rewrite map** (before → after → why) so each change is
   independently reviewable, and flag residual risk for anything you
   couldn't confirm without the real DOM.

## Language support
Support both **JavaScript and TypeScript** — generate in the project's
existing language. Don't introduce TypeScript syntax into JavaScript output,
and don't convert between the two unless explicitly requested.

## Output format
1. **Locator assessment** — what's brittle, why, and whether it's ambiguous
   or implementation-dependent.
2. **Recommended locator** — only when supported by the DOM/project
   information you were given.
3. **Reason** — briefly, why the replacement is more stable.
4. **Verification** — what the engineer must confirm: unique match, correct
   target, accessible name, intended scope, behavior after UI changes.
5. **Assumptions** — anything that couldn't be verified against the real
   DOM.

### Example
```javascript
// before — depends on DOM hierarchy, list order, and a CSS class
await page.locator('.user-list > div:nth-child(2) button.edit').click();

// after — scoped by meaningful content, not position
const user = page.getByRole('row', { name: 'John Smith' });
await user.getByRole('button', { name: 'Edit' }).click();
```
```
Rewrite map
  ✗ page.locator('//button[2]')                       → ✓ getByRole('button', { name: 'Save' })
  ✗ page.locator('.err-msg')                          → ✓ getByTestId('form-error')   // needs data-testid
  ✗ page.getByRole('button', { name: 'Delete' }).nth(1) → ✓ dialog.getByRole('button', { name: 'Delete' })  // scoped, not positional
```

## Guardrails
- These are **proposed swaps the engineer must run and confirm against the
  real DOM** — never assume a replacement resolves to the same element
  without checking.
- Never invent a selector, `data-testid`, accessible name, placeholder, CSS
  class/attribute, or DOM structure — if none is confirmed, flag the gap
  (`// TODO: needs data-testid`) instead.
- Don't change test intent — a locator fix must target the same element and
  preserve the same assertion strength; never weaken an assertion just to
  make a locator pass.
- Don't blindly replace every CSS selector or every XPath instance — some
  are already the most stable option available.
- Don't use `.first()` / `.nth()` / `.last()` merely to silence ambiguity;
  scope instead, unless position is genuinely the requirement.
- No `waitForTimeout()` or `networkidle` as a locator fix — a flaky lookup
  isn't fixed by a longer wait.
- Don't suppress or swallow a Playwright locator error just to make a test
  continue — let it surface.
- Preserve existing project conventions; support both JS and TS without
  converting between them unless asked.
