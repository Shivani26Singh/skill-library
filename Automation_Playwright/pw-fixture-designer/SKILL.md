---
name: pw-fixture-designer
description: >-
  Designs reusable Playwright test fixtures — JavaScript or TypeScript,
  matched to the target project's conventions — providing common test
  dependencies such as authentication/session state, seeded test data, page
  objects, API-created resources, and environment setup. Use when an SDET
  says "create an auth fixture", "I need a logged-in page fixture", "set up
  test data fixtures", "share a page object via fixture", or wants to stop
  repeating login/setup in every test. Produces a fixtures module with
  correct scope and teardown — a draft the engineer wires in and runs.
license: MIT
metadata:
  author: Shivani Singh
  pack: playwright
  version: 1.0.0
---

# PW Fixture Designer

You design **fixtures the engineer must wire into the project and run** —
never a guaranteed-working setup. Fixtures should keep tests focused,
isolated, deterministic, reusable without hiding behavior, safe for parallel
execution, and cleaned up after use.

## When to use
- Login/auth setup is duplicated across specs.
- Tests need seeded data, a pre-authenticated context, or a shared Page
  Object.
- Multiple tests share the same dependency, or setup/teardown should be
  centralized.
- Someone says "create/design/refactor/improve a Playwright fixture".

## When *not* to use
- Generating a full test from a scenario → `pw-test-generator`.
- Building a standalone Page Object → `pw-page-object-builder`.
- Diagnosing an existing flaky test → `pw-flaky-debugger`.
- Analyzing a Playwright trace → `pw-trace-analyzer`.
- Testing an API as the primary objective → `pw-api-tester`.
- Mocking/intercepting network requests → `pw-network-mocker`.
- Configuring CI/CD → `pw-ci-configurator`.

Fixtures may support those workflows, but shouldn't be generated as a
substitute for the specialized skill.

## Language and project conventions
Support both **JavaScript and TypeScript**.

Before generating a fixture, inspect the project when files are available:
`playwright.config.js` / `.ts`, existing fixture modules, Page Objects, auth
setup, test-data utilities, helper modules, `package.json`. Follow the
project's naming and import conventions. Never convert JS ↔ TS unless
explicitly requested.

- **TypeScript** — use `test.extend<Fixtures>()`; type fixture values/params
  where useful, without over-typing.
- **JavaScript** — use `test.extend({...})`; no TS interfaces, annotations,
  or generics.

Fixture design and lifecycle stay conceptually identical between the two.

## Choosing fixture scope
- **Test-scoped (default).** Use when the fixture creates/modifies test
  data, provides a Page Object tied to a test's page, creates temporary
  resources, or depends on mutable state — each test gets its own instance,
  for isolation.
- **Worker-scoped.** Only when setup is expensive *and* sharing is
  safe — e.g. read-only initialization, or auth state that parallel tests in
  the same worker won't mutate. Never choose worker scope just because it's
  faster; if parallel tests can mutate or interfere with the shared
  resource, keep it test-scoped or isolate the resource instead.
- **Automatic.** Only when setup genuinely must run without being requested
  by the test. Don't make a fixture automatic purely for convenience — it
  hides setup and makes tests harder to debug.

## Authentication and session fixtures
Prefer Playwright's `storageState` (or an equivalent reuse mechanism) over
UI login in every test:

```
Authenticate → persist storage state → reuse it → start test with an authenticated context
```

Before sharing that state across tests, confirm it's safe: if tests mutate
user-specific state, use separate users/accounts, worker-specific accounts,
or test-scoped authentication instead of assuming one account can be shared
safely. Never hard-code credentials — use the project's environment
variables, secrets, or auth utilities.

## Test-data fixtures
Prefer creating data through a fast, reliable non-UI mechanism (an API call
or seed utility) over navigating the UI, unless UI creation is itself what
the test verifies:

```
fixture → API/seed utility → create data → test uses data → fixture cleans up
```

Never invent API endpoints, queries, seed scripts, or schemas. If the
project has no such mechanism, state the missing prerequisite and ask —
don't fabricate one.

## Setup/teardown lifecycle
Use the `use()` pattern correctly — arrange before `await use(value)`, tear
down after:

```javascript
export const test = base.extend({
  resource: async ({ request }, use) => {
    const resource = await createResource(request);   // setup
    await use(resource);
    await deleteResource(request, resource.id);        // teardown — runs even if the test fails
  },
});
```

Every disposable resource (API-created records, temp users/files, backend
resources) needs a defined cleanup strategy. Never silently ignore a cleanup
failure — state the limitation if cleanup can't be guaranteed.

## Composing fixtures
Prefer small, composable fixtures with one clear responsibility over a
single fixture that does everything (avoid names like `doEverything` /
`setupAll`; prefer `authenticatedPage`, `seededResource`, `testUser`).
Fixtures may depend on other fixtures (e.g.
`authenticatedSession → seededResource → pageObject`) when that makes setup
clearer.

A Page Object may be exposed through a fixture when multiple tests need the
same construction — reuse an existing Page Object rather than duplicating
one; the Page Object itself stays responsible only for page interaction, not
test setup or assertions.

Not every repeated line needs a fixture — a stateless helper (formatting
data, building a payload) is often more appropriate than wrapping it as a
fixture.

## Isolation and parallel execution
No fixture should require another test to run first. Before sharing any
resource, ask: can two tests modify it simultaneously, can one test
invalidate it for another, is it unique per worker, is auth state mutable?
If sharing creates risk, isolate the resource — never sacrifice isolation
just to save time.

## Fixture configuration
Identify every required input (base URL, auth state, API endpoint, seed
utility, test account, env config) and state whether each is already
available in the project, expected from an env var, expected from an
existing utility, or required from the engineer. Never invent values.

## Output format
1. **Fixture purpose** — what it provides and why.
2. **Scope decision** — test-scoped / worker-scoped / automatic, with the
   isolation/concurrency reasoning.
3. **Dependencies** — existing fixtures, APIs, seed utilities, env vars,
   auth state, Page Objects, test data.
4. **Generated fixture** — JavaScript or TypeScript, per the project/user's
   request.
5. **Integration notes** — where to import it, how it's used in the
   existing suite.
6. **Cleanup** — what's created and how it's torn down.
7. **Assumptions** — anything that couldn't be confirmed from the available
   project info.

### Example (JavaScript)
```javascript
import { test as base, expect } from '@playwright/test';
import { ExamplePage } from './pages/example-page.js';

export const test = base.extend({
  examplePage: async ({ page }, use) => {
    await use(new ExamplePage(page));
  },
  seededResourceId: async ({ request }, use) => {
    const response = await request.post('/test-resource');   // replace with the project's real endpoint
    if (!response.ok()) throw new Error('Failed to create test resource');
    const resource = await response.json();
    await use(resource.id);
    await request.delete(`/test-resource/${resource.id}`);   // replace with the project's real cleanup
  },
});
export { expect };
```

### Example (TypeScript)
```typescript
import { test as base, expect } from '@playwright/test';
import { ExamplePage } from './pages/example-page';

type Fixtures = { examplePage: ExamplePage; seededResourceId: string };

export const test = base.extend<Fixtures>({
  examplePage: async ({ page }, use) => {
    await use(new ExamplePage(page));
  },
  seededResourceId: async ({ request }, use) => {
    const response = await request.post('/test-resource');   // replace with the project's real endpoint
    if (!response.ok()) throw new Error('Failed to create test resource');
    const resource: { id: string } = await response.json();
    await use(resource.id);
    await request.delete(`/test-resource/${resource.id}`);   // replace with the project's real cleanup
  },
});
export { expect };
```

The endpoints, response shapes, and Page Object above are illustrative
placeholders — verify against the real project.

## Guardrails
- Draft only — never claim a fixture works without running it in the target
  project.
- Never invent endpoints, credentials, env vars, seed scripts, queries,
  response shapes, Page Objects, or auth mechanisms.
- Match the project's actual JS/TS convention; never convert one to the
  other unless asked, and never introduce TypeScript syntax into JavaScript
  output.
- Default to test scope; use worker scope only when sharing is demonstrably
  safe, and never share mutable state without weighing concurrency.
- Prefer `storageState` over UI login in every test; never hard-code
  credentials.
- Prefer API/seed mechanisms over UI-created prerequisite data, unless UI
  creation is the behavior under test.
- Always define and execute a cleanup strategy — teardown must run even when
  the test fails; never silently swallow a cleanup failure.
- No `waitForTimeout` or arbitrary sleeps in setup/teardown; no dependency
  on test execution order.
- Keep fixtures focused and composable; don't hide substantial test behavior
  inside one to shorten a test; don't build a fixture where a stateless
  helper would do.
- State assumptions and missing prerequisites explicitly.
