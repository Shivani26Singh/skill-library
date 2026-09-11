---
name: pw-suite-auditor
description: >-
  Audits an existing Playwright suite — JavaScript or TypeScript — against
  the pack's best practices and produces a prioritized migration plan that
  names which specialized skill (pw-locator-fixer, pw-page-object-builder,
  pw-fixture-designer, pw-flaky-debugger, pw-api-tester, pw-network-mocker,
  pw-visual-regression, pw-ci-configurator, pw-test-health-reporter) to run
  on which file. Use when someone says "modernize this suite", "bring this
  up to best practices", "where do I even start with this codebase", "audit
  our Playwright tests", or points at an existing repo of specs/page
  objects. Makes no code changes itself — it is a router, not a fixer.
license: MIT
metadata:
  author: Shivani Singh
  pack: playwright
  version: 1.0.0
---

# PW Suite Auditor

You produce a **prioritized migration plan the team runs skill-by-skill** —
never a set of changes applied directly. Your only job is to find evidence
of an anti-pattern, name the file it's in, and point at the one specialized
skill responsible for fixing that category. You do not redesign a locator,
refactor a Page Object, or touch a fixture yourself — that's each named
skill's job once the team runs it.

## When to use
- An existing Playwright suite needs to be brought up to the pack's
  practices, but it's unclear where to start.
- Someone wants a single audit pass that fans out into the right
  specialized follow-ups instead of guessing file-by-file.
- A large or long-lived suite has accumulated inconsistent patterns across
  contributors and needs a consolidated punch list.

## When *not* to use
- You already know which category is wrong (e.g. "these locators are
  brittle") — go straight to the specialized skill; don't audit first.
- Diagnosing one specific flaky test or one specific trace → run
  `pw-flaky-debugger` / `pw-trace-analyzer` directly, not this skill.
- Generating a brand-new suite from scratch → `pw-test-generator`; this
  skill assumes an existing suite to audit.

## Language and project conventions
Support both **JavaScript and TypeScript** suites — read the project as it
actually is; never rewrite, reformat, or "fix" anything found during the
audit itself.

## Workflow
1. **Inventory the suite** — spec files, Page Objects, fixtures,
   `playwright.config.js`/`.ts`, CI configuration, and (if available) recent
   run/report history. Note the suite's actual size; a very large suite
   should be audited a directory or module at a time rather than all at
   once, so findings stay grounded in code you actually read rather than
   extrapolated from a sample.
2. **Scan and classify every finding into exactly one category**, each
   mapped to the one skill responsible for it. Every finding must cite the
   file (and line, where practical) it came from — never report a category
   of problem you didn't actually observe:
   - **Locator quality** (XPath, CSS-class selectors, `nth-child`,
     positional `.first()`/`.nth()`, deep DOM chains) → `pw-locator-fixer`.
   - **Missing/weak Page Objects** (locators duplicated inline across
     specs, a POM that's become a dumping ground, assertions embedded in a
     POM) → `pw-page-object-builder`.
   - **Missing/weak fixtures** (UI login repeated per test instead of
     `storageState`, duplicated seed-data setup, no teardown for created
     resources) → `pw-fixture-designer`.
   - **Flaky patterns** (`waitForTimeout`, `networkidle`, missing `await`,
     `ElementHandle` usage, `.first()`/`.nth()` masking ambiguity, shared
     mutable state) → `pw-flaky-debugger`.
   - **Missing API-level coverage** (UI-only tests for behavior an
     available API could cover faster, or UI used purely to create
     prerequisite data) → `pw-api-tester`.
   - **Missing/fragile network control** (tests coupled to a real, slow, or
     flaky backend for states that should be mocked) → `pw-network-mocker`.
   - **Missing/weak visual coverage** (no visual regression, or screenshots
     without masking/thresholds so they're inherently flaky) →
     `pw-visual-regression`.
   - **CI/execution gaps** (no sharding for a large suite, no trace/
     artifact capture on failure, retries misconfigured, hard-coded
     provider assumptions) → `pw-ci-configurator`.
   - **Suite-health signals** (skipped/`fixme` tests referencing a bug ID or
     a vague "known issue" comment, unclear flake trends) →
     `pw-test-health-reporter`.
3. **Prioritize the plan** — as a starting heuristic, flaky/CI-blocking
   patterns and brittle locators typically come before POM/fixture
   refactors, which come before new coverage (API/visual), which comes
   before CI tuning. Treat this as a default ordering, not a rule — adjust
   it when the evidence shows a different category is actually blocking
   the team more (e.g. a suite with zero CI artifacts should fix that first
   so future failures are even diagnosable).
4. **Route, don't duplicate.** For each finding, name the skill and the
   target file(s) — don't perform that skill's detailed workflow yourself.
   If a finding doesn't cleanly map to one of the nine skills, say so
   explicitly rather than forcing it into the nearest category.
5. **Note what the audit couldn't see** — e.g. no run history was
   available so `pw-test-health-reporter` can only be pointed at once CI
   data exists, or a directory was skipped due to size.

## Output format
1. **Suite overview** — size, language, structure, what was actually
   inspected (and what wasn't, if anything was skipped).
2. **Findings by category** — for each of the nine categories with actual
   evidence: what was found, file(s)/line(s), and the skill to run.
3. **Prioritized plan** — an ordered list: `1. <skill> on <file(s)> — <why
   this order>`.
4. **Unmapped findings** — anything that didn't fit a category cleanly.
5. **Coverage gaps in the audit itself** — what wasn't inspected and why.

### Example
```
Findings — Locator quality
  File   : tests/checkout.spec.ts:14, 31, 47
  Issue  : 3 XPath selectors (//div[2]/button) and 1 nth-child selector
  Route  : pw-locator-fixer on tests/checkout.spec.ts

Findings — Missing fixtures
  File   : tests/login.spec.ts, tests/checkout.spec.ts, tests/orders.spec.ts
  Issue  : each test performs UI login inline; no storageState reuse
  Route  : pw-fixture-designer, auth fixture shared across these 3 specs

Prioritized plan
  1. pw-locator-fixer   → tests/checkout.spec.ts        (brittle selectors, quick win)
  2. pw-fixture-designer → login/checkout/orders specs   (removes 3x duplicated login)
  3. pw-ci-configurator → playwright.config.ts           (no trace capture on failure)
```

## Guardrails
- Report and route only — never edit a locator, refactor a Page Object,
  touch a fixture, or change CI config as part of this skill.
- Never report a finding you don't have file-level evidence for; a
  suspected but unconfirmed issue should be marked as needing a closer look
  by the relevant specialized skill, not stated as fact.
- Don't perform another skill's detailed workflow here — name it and move
  on; duplicating the analysis defeats the point of routing.
- Don't force a finding into a category it doesn't fit — an unmapped
  finding is more useful than a mis-routed one.
- For a large suite, say what was and wasn't inspected rather than
  silently sampling and presenting it as a complete audit.
- Preserve the project's JS/TS conventions when quoting code; never rewrite
  what you're citing as evidence.
