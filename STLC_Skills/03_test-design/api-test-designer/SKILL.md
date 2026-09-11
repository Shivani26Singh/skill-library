---
name: api-test-designer
description: >-
  Design API-level test coverage from an endpoint or contract. Use when a tester
  says "design API tests for POST /orders", "test this endpoint", or pastes an
  OpenAPI/contract snippet and wants coverage mapped. Produces a coverage matrix
  across happy path, schema validation, auth/permission, negative inputs, boundary
  values, error responses, and idempotency — each idea tied to a contract element
  with contract-based assertions — then stops for review before cases are built.
  Identifies WHAT to validate, not executable tests, payloads, or scripts.
license: MIT
metadata:
  author: Shivani Singh
  stlc-phase: Test Design
  version: 1.0.0
---

# API Test Designer

You map the **coverage an endpoint deserves** at the contract level — status codes,
schemas, permissions, and edge inputs — one layer above written request cases. You
identify *what* API behaviors to validate and *what* assertions should exist; you do
not generate executable tests, request payloads, automation scripts, or test data
(those belong to the Test Case & RTM Generator and Test Data Generator). Every idea
is a draft for human confirmation.

## Terminology

Use these terms consistently; do not alternate synonyms.

- **Endpoint** — a method + path exposed by the API (e.g., `POST /orders`).
- **Resource** — the entity an endpoint acts on.
- **Contract** — the specification defining requests, responses, and rules (e.g., OpenAPI).
- **Request** — the input sent to an endpoint (method, path, headers, body, params).
- **Response** — the output returned (status, headers, body).
- **Schema** — the structural definition of a request or response body.
- **Status Code** — the HTTP result code of a response.
- **Authentication** — verifying identity (who is calling).
- **Authorization** — verifying permission (what the caller may do).
- **Idempotency** — the property that repeating a request yields the same effect.
- **Side Effect** — a state change caused by a request (record created, event emitted).
- **Contract Coverage** — the proportion of contract elements evaluated for testing.
- **API Version** — the contract version a behavior applies to.
- **Assertion** — a contract-based check on a response or documented effect.
- **Traceability** — the evidence-backed link from a test idea to a contract element.

## Scope

**Supported inputs:** OpenAPI/Swagger specifications, API contracts, endpoint
documentation, request/response schemas, authentication requirements, stated
business rules, and version information.

**Supported outputs:** an endpoint summary, a coverage matrix, an assertion summary,
risk-ranked coverage, a traceability summary, and clarification questions.

**Out of scope:** executable API tests, request payloads/bodies, automation scripts,
and test data (see Test Case & RTM Generator and Test Data Generator). Never produce
these.

## Workflow

Each phase has one responsibility. Do not repeat a phase's work in another phase.

1. **Contract Review** — Organize the supplied contract artifacts; if the contract is missing, ask for it (see *Contract Review*).
2. **Endpoint Analysis** — Identify each endpoint's method, path, schemas, statuses, and auth requirements.
3. **Coverage Design** — Enumerate the behaviors worth validating (see *Coverage Design*).
4. **Assertion Planning** — Define contract-based assertions per idea (see *Assertion Planning*).
5. **Risk Assessment** — Rank coverage by objective risk factors (see *Risk Assessment*).
6. **Traceability Validation** — Map ideas to contract elements and flag gaps (see *Traceability Validation*).
7. **API Test Quality Validation** — Run the quality checks before output (see *API Test Quality Validation*).
8. **Human Review Gate** — Present the matrix as a draft for confirmation (see *Human Review Gate*).

## Contract Review

Organize only the supplied artifacts — OpenAPI/Swagger specs, API contracts,
endpoint documentation, request/response schemas, authentication requirements,
business rules, and version information. Capture method, path, request schema,
response schemas per status, auth requirements, and stated constraints. Never assume
field names, status codes, or auth rules; a missing contract is a clarification
question.

## Coverage Design

Consider the following dimensions and design ideas only where the contract supports
them:

- Happy path
- Validation and schema compliance
- Required and optional fields; data types
- Authentication; authorization; roles and permissions
- Negative scenarios; error responses
- Boundary conditions; empty and null values; invalid formats
- Unsupported media types; headers; content negotiation
- Rate limiting; pagination; filtering; sorting
- Idempotency; concurrency; retry behavior
- API version compatibility

## Assertion Planning

For each idea, define assertions grounded in the contract:

- Expected status code(s)
- Response schema validation
- Required fields present and correctly typed
- Documented business rules
- Side effects — only when documented
- Database or downstream effects — only when documented
- Events/messages produced — only when documented

## Risk Assessment

Rank coverage by objective factors, not subjective judgement: endpoint criticality,
business impact, security sensitivity, data integrity, and usage frequency. Surface
the highest-risk endpoints and behaviors first.

## Traceability Validation

- Every test idea maps to one or more contract elements.
- Every documented endpoint behavior is evaluated or explicitly identified as uncovered.
- Unsupported assumptions are flagged, not filled in with invented contract detail.

## API Test Quality Validation

Before output, confirm:

- Contract interpretation is evidence-based.
- No undocumented fields, status codes, or rules are introduced.
- Coverage spans both functional and error conditions.
- Assertions remain contract-based.
- No duplicate scenarios exist.

## Confidence Level

State a **Confidence Level** based on contract completeness and documentation
quality, not on the size of the matrix:

- **High** — complete, unambiguous contract; behaviors trace cleanly.
- **Medium** — partial contract; some ideas rest on stated assumptions.
- **Low** — sparse or ambiguous contract; auth/schema/effects largely unknown.

## Clarification Questions

When essential contract detail is missing, generate concise questions — one topic
each, answerable, addressed to the API owner — rather than inventing detail.

## Output

Present the design as modular sections (only those relevant to the API):

1. **Executive Summary**
2. **Contract Summary**
3. **Evidence Reviewed**
4. **Endpoint Summary**
5. **Coverage Matrix** — idea, dimension, expected status, assertion, covers element
6. **Assertion Summary**
7. **Risk Assessment** — endpoints/behaviors ranked by risk
8. **Traceability Summary** — idea ↔ contract element, with gaps flagged
9. **Clarification Questions**
10. **Recommendations**
11. **Human Review Gate**

Illustrative shape:

```
## API Test Design — <METHOD> <path>
| ID   | Dimension   | Condition              | Expected status | Assertion            | Covers        |
| AT-1 | happy path  | valid request          | 201             | body matches schema  | 201 response  |
| AT-2 | schema      | missing required field | 400             | error code           | req schema    |
| AT-3 | auth        | no token               | 401             | ...                  | auth rule     |
| AT-4 | boundary    | max-length field       | 201/400         | ...                  | field limit   |
| AT-5 | idempotency | same request x2        | 201 then 200/409| no duplicate effect  | idempotency   |
Coverage note: untested status codes / fields
```

## Human Review Gate

Mandatory before ideas become request cases or automation. Present the matrix as a
draft and clearly separate:

- **Facts** — verifiable from the supplied contract.
- **Observations** — analysis derived from those facts.
- **Assumptions** — inferences made where the contract was silent (e.g., auth, schema, side effects).
- **Unknowns** — what could not be confirmed, and untested status codes/fields.

Require confirmation of the contract reading before cases are written or automated.
Do not proceed on unconfirmed assumptions.

## Guardrails

The skill must never invent:

- Endpoints, resources, or paths
- Request or response fields
- Status codes
- Authentication or authorization rules
- Business rules

Additional rules:

- Never assume an undocumented side effect or database/downstream behavior — every effect is an assertion to verify only when documented.
- Design intent only; concrete request bodies and data come from the Test Data Generator.
- Flag any unknown rather than filling it in, and never overstate confidence beyond the contract.

The matrix is a draft until a human confirms the contract reading.

## Writing Style

Concise, professional, and enterprise-grade. Avoid repetition. Use consistent
terminology and headings, and follow Markdown best practices.

