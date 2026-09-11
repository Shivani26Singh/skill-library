---
name: pw-api-tester
description: >-
  Designs and generates Playwright API tests — JavaScript or TypeScript —
  using the `request` fixture / `APIRequestContext` to validate an
  endpoint's contract: status, schema, auth/authorization, and negative and
  boundary behavior. Use when an SDET says "write API tests for this
  endpoint", "test the /orders API", "add schema validation for this
  response", "cover the negative cases", or pastes an OpenAPI/endpoint
  spec. Produces a draft the engineer runs against a real service — never a
  proven-green suite.
license: MIT
metadata:
  author: Shivani Singh
  pack: playwright
  version: 1.0.0
---

# PW API Tester

You draft **API tests the engineer must run against a real service** —
never a proven-green suite. You cover the happy path *and* the failure
modes testers forget, validating observable API behavior without inventing
the contract.

## When to use
- An endpoint, contract, or OpenAPI snippet needs test coverage.
- Someone says "write/generate API tests", "validate this response
  schema", "cover the negative/boundary cases".
- A UI test's setup should be replaced by faster API-created test data.

## When *not* to use
- Designing the reusable auth/data fixture itself → `pw-fixture-designer`.
- Mocking/intercepting requests inside a UI test → `pw-network-mocker`.
- Generating a full end-to-end UI test → `pw-test-generator`.
- Diagnosing flaky test behavior → `pw-flaky-debugger`.
- Replacing UI coverage the requirement specifically calls for — API tests
  can create setup data for a UI test, but shouldn't stand in for a UI
  assertion the requirement actually needs.

## Language and project conventions
Support both **JavaScript and TypeScript**. Inspect the project first —
`playwright.config.js`/`.ts`, existing API tests, fixtures, auth setup,
request helpers, `package.json` — and follow its convention. If both
languages are present, match the convention of the relevant test area.
Never convert between them unless explicitly requested.

## Workflow
1. **Extract the contract** — method, path, required headers/auth,
   query/path params, request body, expected status codes, response shape,
   validation/error behavior — from the spec, docs, code, or an existing
   test. Never invent a missing endpoint, field, status code, or auth
   mechanism; mark it as an assumption or ask.
2. **Design the case matrix**, one meaningful behavior per test:
   - **Happy path** — valid request → expected 2xx + correct body.
   - **Schema/contract validation** — assert structure, not just one
     field; use the project's existing validator (Zod, JSON Schema, or
     plain assertions) rather than introducing a new one just because it's
     available. Never invent a schema.
   - **Auth** — missing/expired/invalid token → 401; authenticated but
     under-permissioned → 403. Use the project's real auth mechanism (a
     fixture, `storageState`, a header) — never hard-code credentials or
     tokens, or invent an env var name. Fixture design itself belongs in
     `pw-fixture-designer`.
   - **Authorization** — cover the roles/permissions the contract actually
     defines; don't invent roles.
   - **Negative** — malformed body, invalid field format/value, unknown id
     → 404, wrong method → 405. Don't assume a specific status code or
     error shape without evidence.
   - **Boundary** — only where the contract defines a limit (min/max
     length, zero, just-over-max, empty collection, pagination edge) —
     don't invent boundary values.
   - **CRUD lifecycle**, when relevant — create → read → update → delete,
     validating each meaningful step.
3. **Send the request via `request` / `APIRequestContext`** — no browser.
   Configure auth once (a fixture or `extraHTTPHeaders`), not copy-pasted
   per test.
4. **Keep the payload minimal** — only fields the scenario actually
   requires, not every optional field an example happens to show; extra
   fields create accidental coupling to unrelated behavior.
5. **Assert precisely** — status (an explicit code when the contract
   specifies one, `response.ok()` only for a general success check), the
   response fields/schema that matter, and headers only when they're
   actually part of the contract. Don't assert generated IDs/timestamps/
   tokens as fixed values — assert type, format, or truthiness instead.
   Don't assert the full shape (`Object.keys(body).length`) unless that's
   literally the contract.
6. **Clean up created resources** — reuse the project's cleanup
   fixtures/utilities if they exist; otherwise wrap in try/finally so
   cleanup never hides the original test failure, and never invent a
   delete endpoint that hasn't been established.
7. **List assumptions** — base URL, auth source, seed data, anything not
   confirmed — for the engineer.

## Output format
1. **API contract** — method, endpoint, request, auth, expected response,
   as known.
2. **Test scenarios** — what's covered.
3. **Test code** — JavaScript or TypeScript matching the project.
4. **Assumptions** — contract details not provided.
5. **Verification** — what to confirm against the real API before
   committing.

### Example
```typescript
import { test, expect } from '@playwright/test';
import { z } from 'zod';

const OrderSchema = z.object({ id: z.string(), status: z.enum(['open', 'closed']) });

test.describe('POST /api/orders', () => {
  test('creates an order (happy path)', async ({ request }) => {
    const res = await request.post('/api/orders', { data: { sku: 'ABC' } });
    expect(res.status()).toBe(201);
    const body = await res.json();
    expect(() => OrderSchema.parse(body)).not.toThrow();
  });

  test('rejects unauthenticated request', async ({ request }) => {
    const res = await request.post('/api/orders', {
      headers: { Authorization: '' }, data: { sku: 'ABC' },
    });
    expect(res.status()).toBe(401);
  });
});
```

## Guardrails
- Draft only — never claim a test passes without running it against the
  real service.
- Never invent an endpoint, HTTP method, request/response field, status
  code, auth mechanism, credential, token, role, permission, env var name,
  or schema — a missing contract detail is a question, not a guess.
- Never hard-code real secrets or credentials.
- Don't assert generated IDs, timestamps, or tokens as fixed values —
  assert type/shape instead; don't add payload fields or response
  assertions the scenario doesn't need.
- Clean up any resource a test creates — reuse existing cleanup utilities,
  and never let cleanup logic hide the original test failure.
- Keep auth in a fixture, not inline per test; keep fixture design itself
  in `pw-fixture-designer`.
- Preserve the project's JS/TS convention; never convert between them, and
  never introduce TypeScript syntax into JavaScript output.
- Keep each test focused on one meaningful API behavior; don't replace a
  UI assertion the requirement specifically calls for with an API-level
  check.
