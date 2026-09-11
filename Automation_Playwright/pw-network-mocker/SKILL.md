---
name: pw-network-mocker
description: >-
  Designs Playwright route interception and mocking — JavaScript or
  TypeScript — to make UI tests deterministic without diverging from the
  real API contract. Use when an SDET says "mock this API", "stub the
  /orders response", "force a 500 error state", "make this test
  deterministic without the backend", or "intercept network calls".
  Produces `page.route`/`fulfill` handlers to stub responses, simulate
  errors/slow/aborted states, and remove backend flakiness — a draft the
  engineer wires in and verifies against the real contract.
license: MIT
metadata:
  author: Shivani Singh
  pack: playwright
  version: 1.0.0
---

# PW Network Mocker

You draft **route mocks the engineer must wire in and verify** — never a
proven setup. A mock controls one dependency so the UI behavior can be
tested; it is not itself the assertion, and it must not diverge from the
real API contract.

## When to use
- A test depends on a slow, flaky, or unavailable backend.
- You need to force an error/empty/loading state the real API rarely
  returns on demand.
- Someone says "mock/stub/intercept this request".

## When *not* to use
- Testing the API directly (not through a UI test) → `pw-api-tester`.
- Designing the fixture/setup architecture around a reused mock →
  `pw-fixture-designer`.
- Diagnosing general test flakiness → `pw-flaky-debugger`.
- Generating a complete Playwright test → `pw-test-generator`.

A mock should support the UI scenario under test — it should not become a
substitute for API testing, and it should not be used to paper over a real
integration problem.

## Language and project conventions
Support both **JavaScript and TypeScript** — preserve the project's
existing language and conventions; never convert between them, and never
introduce TypeScript syntax into JavaScript output.

## Workflow
1. **Identify the dependency** — which request the UI triggers, when, what
   response it expects, and which UI state the test is validating.
2. **Match the real request.** Verify method, URL/path, query parameters,
   request body, and response structure from application code, network
   evidence, a trace, or an existing test — never invent an endpoint or
   shape based on what "seems likely"; state the assumption if it can't be
   verified.
3. **Register the route before the triggering action** — never after the
   navigation/action that fires the request.
4. **Choose the right interception mode:**
   - `route.fulfill()` — return a fully controlled response (success, empty,
     error). The body must match the structure the UI actually expects;
     never invent a field the UI doesn't support.
   - `route.fetch()` then `fulfill()` — let the real response come back and
     tweak only the part the scenario needs, instead of hand-authoring a
     large response from scratch.
   - `route.continue()` — pass the request through unmodified, or inspect
     it conditionally; use this when the real backend behavior is what the
     test should actually validate.
   - `route.abort()` — simulate the network itself failing (unavailable
     dependency, interrupted request). Don't use `abort()` when the
     scenario is really about an HTTP error response — that's a `fulfill()`
     with a 4xx/5xx status instead.
5. **Cover the states that matter**, each as its own deterministic test:
   success, empty list, validation/auth/server errors (401/403/404/409/422/
   500 — only the ones the app's actual error model supports), and
   slow/aborted requests for loading states. A delay should be an
   intentional latency simulation, not an arbitrary number, and never use
   `waitForTimeout()` in the test to "wait for" the mock.
6. **Scope route matching tightly.** Prefer a specific pattern
   (`**/api/users`) over a catch-all (`**/api/**`); when multiple methods or
   query parameters share a path, branch on `route.request().method()` or
   the parsed query string rather than mocking indiscriminately. Never
   accidentally intercept an unrelated request.
7. **Keep mock data minimal, realistic, and deterministic** — only the
   fields the scenario needs, matching the real contract; don't build data
   that would put the UI into a state the real API can't actually produce.
8. **Assert the resulting UI behavior**, not that the route was merely
   registered or called.
9. **Keep mocks scoped to the smallest useful test.** Register at the test
   level by default; only consider moving a reused mock into a fixture if
   it's genuinely shared, and leave that fixture's design to
   `pw-fixture-designer` rather than building it here.
10. **Flag contract drift.** If a mock looks inconsistent with the real API
    (docs, existing API tests, real traffic), say so — don't silently
    redesign the mock around an assumption.
11. **List assumptions** — which fields/params/headers were confirmed vs.
    guessed — for the engineer to verify against the real network tab or
    contract.

## Output format
1. **Dependency** — the request being controlled.
2. **Scenario** — the UI state under test.
3. **Mock** — the route interception code.
4. **Expected UI behavior** — what the test should verify.
5. **Assumptions** — request/response details that couldn't be confirmed.
6. **Verification** — how to confirm the mock matches the real contract.

### Example
```typescript
import { test, expect } from '@playwright/test';

test('shows an error banner when orders API fails', async ({ page }) => {
  await page.route('**/api/orders', (route) =>
    route.fulfill({
      status: 500,
      contentType: 'application/json',
      body: JSON.stringify({ error: 'internal' }),
    }));

  await page.goto('/orders');
  await expect(page.getByTestId('orders-error')).toBeVisible();
});

test('renders empty state', async ({ page }) => {
  await page.route('**/api/orders', (route) =>
    route.fulfill({ status: 200, body: JSON.stringify([]) }));
  await page.goto('/orders');
  await expect(page.getByText('No orders yet')).toBeVisible();
});
```

## Guardrails
- Draft only — never assume a request URL, method, query parameter, body,
  or response schema; confirm against the real network tab/contract.
- Never fabricate a response shape, field, status code, or auth requirement
  that diverges from production — a passing mock against a wrong schema is
  a false green.
- Never hard-code real secrets or credentials in a mock.
- Register routes before the triggering action; keep matching as narrow as
  practical and never accidentally intercept an unrelated request.
- No `waitForTimeout()` or arbitrary delay to synchronize with a mock;
  assert on the resulting UI state instead.
- Don't mock every dependency by default — over-mocking hides real
  integration problems and lets an invalid contract pass unnoticed. Don't
  use retries to compensate for an incorrect mock.
- Keep mock data minimal, realistic, and deterministic; don't silently
  redesign a mock around an assumption — flag suspected contract drift
  instead.
- Preserve the project's JS/TS convention; never convert between them.
- Keep fixture architecture in `pw-fixture-designer` — don't build one here
  just because a route is reused.
