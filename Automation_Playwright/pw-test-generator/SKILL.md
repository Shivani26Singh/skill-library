---
name: pw-test-generator
description: >-
  Generates a Playwright test spec — JavaScript or TypeScript, matched to the
  target project's existing conventions — from a described user flow or
  scenario. Use when an SDET says "write a Playwright test for login",
  "generate a spec for the checkout flow", "turn this scenario into a test",
  or pastes acceptance criteria that need automating. Detects the project's
  language and conventions, reuses existing fixtures/page objects, and
  produces a runnable draft using semantic locators and web-first assertions
  — the engineer still runs it.
license: MIT
metadata:
  author: Shivani Singh
  pack: playwright
  version: 1.0.0
---

# PW Test Generator

You draft a **Playwright spec the engineer must still run and review** — never
a "finished" test. Your job is to translate a described flow into resilient,
best-practice Playwright code that matches the target project's existing
language and conventions, whether that project is JavaScript or TypeScript.

## When to use
- A user flow, scenario, or acceptance criteria needs a Playwright spec.
- A manual test case needs converting to automation.
- Someone says "write/generate a Playwright test for X".

## When *not* to use
- Designing reusable fixtures → `pw-fixture-designer`.
- Building a Page Object Model → `pw-page-object-builder`.
- Diagnosing an existing flaky test → `pw-flaky-debugger`.
- Analyzing a Playwright trace → `pw-trace-analyzer`.
- Testing an API without browser interaction → `pw-api-tester`.
- Mocking/intercepting network requests → `pw-network-mocker`.
- Visual/screenshot regression → `pw-visual-regression`.

## Language and project conventions
Support both **JavaScript and TypeScript**.

Before generating code, inspect the project when files are available:
- `playwright.config.js` / `playwright.config.ts`
- existing `*.spec.js` / `*.test.js` or `*.spec.ts` / `*.test.ts` files
- `package.json`
- existing fixtures, page objects, and utilities

Match the detected language and style. If the user states a language
explicitly, follow it. If the project is new and the language is
unspecified, ask only when the choice materially affects the output. Never
convert an existing JS project to TS, or vice versa, unless explicitly
requested.

- **TypeScript** — use types where they aid clarity; don't over-annotate.
- **JavaScript** — standard Playwright JS syntax; no TS annotations or
  interfaces.

## Workflow
1. **Understand the scenario.** Extract test objective, preconditions, user
   role/auth state, starting route, actions, expected outcomes, required
   data, edge cases, and environment dependencies. Frame as
   Arrange → Act → Assert. Don't invent missing application behavior — ask,
   or mark it as an assumption.
2. **Identify the entry point.** Prefer an existing authenticated session,
   fixture, or Page Object over recreating setup the project already has.
3. **Choose locators**, in order of preference: `getByRole` (with accessible
   name) → `getByLabel` → `getByPlaceholder` → `getByText` (only for stable
   visible text) → `getByTestId` → CSS/XPath only with a justified
   project-specific reason. Never invent an accessible name, test ID, ID,
   CSS class, DOM structure, URL, or form field — mark any unconfirmed
   selector `// TODO: confirm locator against the rendered DOM`.
4. **Assert user-visible behavior** (`toBeVisible`, `toHaveText`,
   `toHaveURL`) over implementation details or internal state.
5. **Use web-first, auto-retrying assertions.** No `waitForTimeout`, no
   arbitrary sleeps, no `networkidle` as a generic wait — wait for the
   specific signal the scenario needs (a status message, a triggered
   request).
6. **Keep each test focused** on one scenario — valid input, missing input,
   and invalid input are separate tests, not one combined test. Don't add
   scenarios beyond what was asked; note useful follow-up coverage
   separately instead.
7. **Use `test.step()`** for multi-step readability; don't wrap every single
   locator action in its own step.
8. **Reuse existing fixtures, Page Objects, auth helpers, and test-data
   utilities** instead of duplicating them, e.g.
   `test('...', async ({ authenticatedPage }) => { ... })`.
9. **Handle test data carefully.** Don't fabricate application-specific data
   requirements — use existing data utilities, a clearly marked placeholder,
   or ask when required data is missing. Flag the cleanup strategy for any
   data the test creates.
10. **Preserve isolation.** No shared mutable state, no dependency on
    execution order, no reuse of data another parallel test can change.
11. **Review every assertion** against "what behavior does this prove?" and
    drop assertions on unrelated elements.

## Output format
1. **Test intent** — one line on what the test verifies.
2. **Assumptions** — anything not provided but required to implement the
   test.
3. **Generated test** — in the project's detected (or requested) language.
4. **Verification notes** — what the engineer must confirm: locators, URLs,
   test data, auth state, fixture names, expected messages, app-specific
   behavior.

### Example (JavaScript)
```javascript
import { test, expect } from '@playwright/test';

test.describe('Example user flow', () => {
  test('completes the flow successfully', async ({ page }) => {
    await test.step('open the page', async () => {
      await page.goto('/example');
      await expect(page.getByRole('heading', { name: 'Example' })).toBeVisible();
    });
    await test.step('complete the action', async () => {
      await page.getByLabel('Input').fill('example value');
      await page.getByRole('button', { name: 'Submit' }).click();
    });
    await test.step('verify the result', async () => {
      await expect(page.getByRole('status')).toHaveText(/success/i);
    });
  });
});
```

### Example (TypeScript)
```typescript
import { test, expect } from '@playwright/test';

test.describe('Example user flow', () => {
  test('completes the flow successfully', async ({ page }) => {
    await test.step('open the page', async () => {
      await page.goto('/example');
      await expect(page.getByRole('heading', { name: 'Example' })).toBeVisible();
    });
    await test.step('complete the action', async () => {
      await page.getByLabel('Input').fill('example value');
      await page.getByRole('button', { name: 'Submit' }).click();
    });
    await test.step('verify the result', async () => {
      await expect(page.getByRole('status')).toHaveText(/success/i);
    });
  });
});
```

Names, routes, selectors, and expected behavior above are illustrative —
replace or verify each against the real application.

## Guardrails
- Draft only — never claim a generated test passes without it being run.
- Never invent selectors, routes, accessible names, test IDs, API endpoints,
  test data, or credentials you weren't shown.
- Never hardcode real credentials or secrets — use env vars or existing
  fixtures for auth.
- Match the project's actual JS/TS convention; never convert one to the
  other unless asked, and never introduce TypeScript syntax into JavaScript
  output.
- Prefer existing fixtures, Page Objects, and utilities over duplicating
  setup.
- Don't wrap a single Playwright call in a helper merely to shorten the
  test — keep meaningful behavior visible in the spec.
- No `waitForTimeout`, no arbitrary sleeps, no `networkidle` as a generic
  wait strategy.
- No XPath / `nth-child` / CSS-class selectors unless semantic locators are
  genuinely unavailable.
- Keep each test focused on one scenario; preserve isolation; flag cleanup
  needs for created data.
- Mark uncertain selectors or assumptions for engineer verification — never
  silently weaken an assertion just to make a test pass.
