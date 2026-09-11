---
name: pw-page-object-builder
description: >-
  Designs and generates maintainable Playwright Page Object Model (POM)
  classes — JavaScript or TypeScript, matched to the target project's
  conventions — from a described page, existing test, UI flow, or provided
  page structure. Use when an SDET says "create a page object", "build a
  POM", "extract locators into a page class", "refactor this test into a
  page object", or wants reusable page interaction methods. Produces
  locators-as-lazy-methods and action methods — a draft the engineer must
  review and verify against the real application.
license: MIT
metadata:
  author: Shivani Singh
  pack: playwright
  version: 1.0.0
---

# PW Page Object Builder

You design **maintainable Page Object classes the engineer must review and
verify** — never a finished, guaranteed-correct class. A Page Object
encapsulates page-specific locators and interactions; test intent and
assertions stay in the test layer.

## When to use
- A page needs a reusable Page Object.
- Inline locators/interactions in a test should be extracted into a class.
- Multiple tests repeat the same page interactions.
- An existing Page Object needs refactoring.
- Someone says "create/build a page object/POM for X".

## When *not* to use
- Generating a complete test from a scenario → `pw-test-generator`.
- Designing fixture architecture → `pw-fixture-designer`.
- Fixing brittle locators across existing tests → `pw-locator-fixer`.
- Diagnosing a flaky test → `pw-flaky-debugger`.
- Analyzing a Playwright trace → `pw-trace-analyzer`.
- Testing an API → `pw-api-tester`.
- Mocking network requests → `pw-network-mocker`.

A Page Object may be *used by* those workflows, but shouldn't replace them.

## Language and project conventions
Support both **JavaScript and TypeScript**.

Before generating a Page Object, inspect the project when files are
available: existing Page Objects, test files, fixtures,
`playwright.config.js` / `.ts`, naming and import conventions. Match what's
there. Never convert an existing JS project to TS, or vice versa, unless
explicitly requested.

- **TypeScript** — `import { type Page, type Locator } from '@playwright/test'`;
  explicit return types where they aid readability; no unnecessary generics.
- **JavaScript** — standard syntax; no type annotations, interfaces, or
  TS-only imports.

## Workflow
1. **Identify the page's responsibility** — full page, section, dialog/modal,
   form, table, nav, or reusable component. Don't default to one class per
   large application page; split by responsibility instead.
2. **Identify the entry point.** If a stable route is known, expose it as a
   class constant (`static readonly PATH = '/example'`) and add a `goto()`.
   Never invent a route, and don't force a single hard-coded path onto a
   Page Object that's used from multiple routes.
3. **Choose locators**, in order of preference: `getByRole` (with accessible
   name) → `getByLabel` → `getByPlaceholder` (only if stable/meaningful) →
   `getByText` (only for stable visible text) → `getByTestId` → CSS/XPath
   only with a documented, justified reason. This is a decision order, not
   an absolute rule — don't replace an already-stable locator just because a
   "better" option exists in theory. Never fabricate a test ID, accessible
   name, ID, class, placeholder, or DOM relationship — mark unconfirmed
   locators `// TODO: confirm locator against the rendered DOM`.
4. **Keep locators lazy.** Return a `Locator` (getter or method — match the
   project's existing style, don't mix both within one project) so it
   re-queries the current DOM; never resolve to an `ElementHandle` or cache
   an element at construction time.
5. **Add action methods** for meaningful user actions (`submitForm`,
   `openDetails`, `searchForItem`) — not thin wrappers around a single
   Playwright call (`clickSubmit()`) that add no meaning. Return useful
   state when it helps composition (e.g. `openDetails()` returning a
   `new DetailsPage(this.page)`), not for its own sake.
6. **Keep assertions in the test.** The Page Object exposes locators,
   navigation, interactions, and state; `expect()` calls stay in the test
   (`await expect(pageObject.successMessage).toBeVisible()`). Only add a
   Page Object–level assertion helper if the project has already
   established that pattern — say so explicitly if you do.
7. **Split into components/sub-pages** when a page has independent reusable
   areas (header, search, results table) — judge by responsibility and
   reuse, not by locator count. Don't split every small group of locators
   into its own class, and don't let one class become a dumping ground for
   an entire application page either.
8. **When refactoring an existing test into a POM**: preserve its intent and
   behavior, move repeated locators/interactions into the class, keep
   scenario-specific assertions in the test, and flag any locator that
   can't be safely converted without inspecting the real DOM.
9. **List assumptions** — guessed selectors, routes, component boundaries —
   for the engineer to confirm.

## Synchronization and errors
- Use Playwright's built-in waiting (`await expect(locator).toBeVisible()`);
  no `waitForTimeout`, no arbitrary sleeps, no `networkidle` as a generic
  strategy. Wait for a specific signal only when an action genuinely
  depends on one.
- Let Playwright errors propagate — don't catch and suppress a failed
  interaction just to keep a test running.

## Test data and fixtures
- Don't hard-code application-specific data; accept it as method parameters,
  or pull from existing test-data utilities/fixtures/constants.
- Page Objects may be constructed directly in a test or supplied via a
  fixture — follow whichever the project already does. Don't create a new
  fixture just because a Page Object exists; that's `pw-fixture-designer`'s
  job.

## Output format
1. **Page Object purpose** — the class's responsibility.
2. **Structure** — page/component represented, main interaction areas,
   navigation, potential sub-components.
3. **Generated Page Object** — JavaScript or TypeScript, per the
   project/user's request.
4. **Usage example** — how a test consumes it.
5. **Assumptions and verification items** — locators, accessible names,
   test IDs, routes, component boundaries that must be confirmed against
   the real app.

### Example (JavaScript)
```javascript
import { expect } from '@playwright/test';

export class ExamplePage {
  static PATH = '/example';

  constructor(page) {
    this.page = page;
  }

  get input() { return this.page.getByLabel('Input'); }
  get submitButton() { return this.page.getByRole('button', { name: 'Submit' }); }
  get resultMessage() { return this.page.getByRole('status'); }

  async goto() {
    await this.page.goto(ExamplePage.PATH);
  }

  async submit(value) {
    await this.input.fill(value);
    await this.submitButton.click();
  }
}
```
```javascript
import { test, expect } from '@playwright/test';
import { ExamplePage } from './pages/example-page.js';

test('completes the example flow', async ({ page }) => {
  const examplePage = new ExamplePage(page);
  await examplePage.goto();
  await examplePage.submit('example value');
  await expect(examplePage.resultMessage).toHaveText(/success/i);
});
```

### Example (TypeScript)
```typescript
import { type Locator, type Page } from '@playwright/test';

export class ExamplePage {
  static readonly PATH = '/example';
  constructor(private readonly page: Page) {}

  get input(): Locator { return this.page.getByLabel('Input'); }
  get submitButton(): Locator { return this.page.getByRole('button', { name: 'Submit' }); }
  get resultMessage(): Locator { return this.page.getByRole('status'); }

  async goto(): Promise<void> {
    await this.page.goto(ExamplePage.PATH);
  }

  async submit(value: string): Promise<void> {
    await this.input.fill(value);
    await this.submitButton.click();
  }
}
```

Routes, accessible names, and selectors above are illustrative
placeholders — verify each against the real application.

## Guardrails
- Draft only — never claim a Page Object works without running it against
  the target app.
- Never invent routes, selectors, accessible names, IDs, test IDs, CSS
  classes, placeholders, or DOM structure.
- Match the project's actual JS/TS convention; never convert one to the
  other unless asked, and never introduce TypeScript syntax into JavaScript
  output.
- Locators stay lazy `Locator` returns — never cache resolved elements or
  use `ElementHandle` without a specific, justified reason.
- No XPath / `nth-child` / CSS-class selectors unless semantic locators are
  genuinely unsuitable; no `waitForTimeout`, arbitrary sleeps, or
  `networkidle`.
- Don't silently change a locator's strictness or multi-match behavior when
  replacing it — call out if the replacement matches a different number of
  elements than the original.
- No assertions inside the POM unless the project has an established,
  documented pattern for it — say so explicitly when you follow one.
- Judge class size by responsibility and reuse, not by a fixed locator
  count; split by component boundary, not for its own sake.
- Reuse existing Page Objects, fixtures, and project conventions instead of
  duplicating them.
- Preserve test intent and behavior when refactoring a test into a Page
  Object.
- State assumptions and verification items explicitly.
