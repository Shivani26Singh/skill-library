---
name: pw-ci-configurator
description: >-
  Designs CI-platform-neutral Playwright execution — JavaScript or
  TypeScript — covering parallelism, sharding, retries, reporters, and
  failure artifacts, without assuming a specific CI provider. Use when an
  SDET says "set up Playwright in CI", "shard my tests across jobs",
  "upload traces and the HTML report", "run browsers in a matrix", "how do
  I keep screenshots when CI fails", or asks to configure Playwright
  execution generally. Produces `playwright.config` changes and an
  execution strategy — provider-specific YAML/scripts only when the
  platform is actually known.
license: MIT
metadata:
  author: Shivani Singh
  pack: playwright
  version: 1.0.0
---

# PW CI Configurator

You design a **CI execution strategy the engineer must adapt to their
pipeline and run** — never a guaranteed-green setup, and never tied to one
CI provider unless the user names one. You wire in the right parallelism,
retries, reporting, and artifacts for the goal at hand — no more.

## When to use
- A Playwright suite needs to run reliably and efficiently in CI.
- A slow suite should be sharded/parallelized, or needs better retries.
- Someone wants trace/screenshot/video/report artifacts preserved on
  failure.

## When *not* to use
- Generating the tests themselves → `pw-test-generator`.
- Designing auth/data fixtures → `pw-fixture-designer`.
- Diagnosing why a specific test is flaky → `pw-flaky-debugger`.
- Analyzing a trace in depth → `pw-trace-analyzer`.
- Visual baseline/screenshot comparison strategy → `pw-visual-regression`.

## Stay CI-platform neutral
Don't assume GitHub Actions (or any provider) unless the user names one.
First check the project for existing CI config to infer the platform; if it
can't be determined, keep the guidance and `playwright.config` changes
platform-neutral and state what CI-specific information (the provider,
runner OS, secret mechanism) is still needed. Only emit provider-specific
YAML/scripts once the platform is actually known — GitHub Actions, GitLab
CI, Azure Pipelines, Jenkins, Buildkite, or another system capable of
running Playwright are all in scope.

## Language and project conventions
Support both **JavaScript and TypeScript** for `playwright.config` and any
scripts — inspect the project's existing config, `package.json`, and CI
setup first, follow its conventions, and never convert between languages
unless requested.

## Workflow
1. **Inspect what already exists** — `playwright.config`, `package.json`,
   any current CI configuration, reporter setup, artifact handling, worker/
   retry settings. Don't replace an existing design without understanding
   why it's there.
2. **Identify the actual goal**, since it drives every other choice: fastest
   PR feedback (focused suite, moderate parallelism, useful failure
   artifacts) vs. maximum coverage on a nightly/scheduled run (full
   regression, sharding, comprehensive artifacts) vs. release validation.
   Don't add complexity without a clear benefit for that goal.
3. **Choose workers vs. sharding deliberately — they're not the same:**
   - **Workers** parallelize tests *within* one CI job
     (`npx playwright test --workers=4`). Don't automatically maximize
     workers — too many causes CPU/memory contention, test-data collisions,
     and unstable browser execution, which can be *slower* overall.
   - **Sharding** splits the suite *across* CI jobs
     (`--shard=1/4`, `--shard=2/4`, ...). Worth it for a large suite on
     multiple machines where wall-clock time matters; not automatically
     beneficial for a small suite once startup overhead is counted. The
     two can combine when the platform supports it.
4. **Set retries intentionally**, e.g.
   `retries: process.env.CI ? 2 : 0` — to absorb genuine infra flakiness,
   never to paper over a repeatable failure. A passing retry doesn't mean
   the test is healthy; a race condition, bad sync, shared state, unstable
   data, a bad locator, or a real defect still needs fixing (that
   investigation is `pw-flaky-debugger`'s job, not this skill's).
5. **Configure failure artifacts at the cheapest strategy that's still
   useful** — `trace: 'on-first-retry'` (or `retain-on-failure`) rather
   than tracing every test, `screenshot: 'only-on-failure'`, video only
   when traces/screenshots aren't enough. Don't collect everything for
   every run if storage/execution cost matters, and never discard failure
   artifacts or hide a failed shard.
6. **Pick reporters for how results are consumed** — a machine-readable
   reporter (`json`/`junit`) for external systems, `html` for humans. When
   sharding, each job emits a **blob** report; add a separate merge step to
   produce one unified report — don't introduce blob/merge when sharding
   isn't in use.
7. **Match test selection to the trigger context** — PR: smoke/focused
   regression; main branch: broader regression; scheduled: full
   regression; release: release-validation suite. Use the project's
   existing tags/projects/directories; don't invent new test tags.
8. **Handle environment and secrets explicitly** — base URL, credentials,
   auth state, feature flags via the CI platform's own secret/env
   mechanism; never hard-code a secret into config, test files, CI YAML, or
   a shell script, and don't invent an environment variable name that
   isn't already established in the project.
9. **Install only what's needed** — the project's actual package manager
   and lockfile (`npm ci` / `yarn install --frozen-lockfile` /
   `pnpm install --frozen-lockfile`, not a switch between them), and only
   the Playwright browsers actually used, not the full set by default.
10. **Diagnose before adjusting timeouts.** A slow CI run can come from
    app performance, infra, poor test synchronization, too many workers, or
    resource contention — raise a timeout only once the longer operation is
    understood and justified, not as a blanket fix.
11. **Never let CI hide a real failure** — don't ignore Playwright's exit
    code, mark a failed run green, or silently continue past failures.
    Retain the artifacts actually needed to diagnose a failure, but don't
    retain large artifacts indefinitely without a reason.
12. **Measure before and after a significant CI change** — more
    parallelism doesn't automatically mean faster; validate the assumption
    rather than asserting it.

## Output format
1. **Execution strategy** — what runs, how it's parallelized, whether
   sharding is used, the retry strategy.
2. **Playwright configuration** — only the relevant `playwright.config`
   changes.
3. **CI configuration** — provider-specific config only when the platform
   is known; otherwise describe the steps conceptually.
4. **Artifacts** — traces, screenshots, videos, reports and their
   retention.
5. **Assumptions** — unknown CI/project details.
6. **Validation** — how to confirm tests run, shards complete, reports
   merge, artifacts persist, and failures actually fail the pipeline.

### Example (platform-neutral)
```typescript
import { defineConfig } from '@playwright/test';

export default defineConfig({
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 4 : undefined,
  reporter: process.env.CI ? [['blob'], ['junit', { outputFile: 'results.xml' }]] : [['list']],
  use: {
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
});
```
```
# conceptual CI steps — translate to the actual platform once known
install dependencies (project's package manager, frozen lockfile)
install only the Playwright browsers this suite uses
run: npx playwright test --shard=<index>/<total> --reporter=blob
always: upload the blob report / trace / screenshot artifacts
merge-reports job: combine per-shard blob reports into one HTML report
```

## Guardrails
- Don't assume a CI provider, and don't emit provider-specific
  configuration when the provider isn't known — keep it generic and say
  what's still needed.
- Never hard-code a credential, secret, or environment variable value;
  never invent an environment variable name the project doesn't already
  use.
- Never hide a Playwright failure — don't ignore exit codes, mark failures
  as passing, or discard failure artifacts; upload artifacts with
  "always run" semantics or evidence is lost on the runs that matter.
- Never use retries to mask a flaky test — that's a `pw-flaky-debugger`
  investigation, not a CI-config fix.
- Don't blindly maximize workers, blindly increase timeouts, or add
  sharding/artifact collection a suite's size doesn't justify.
- Follow the project's actual package manager and existing conventions;
  never switch package managers or convert JS ↔ TS unless asked.
- Keep detailed trace diagnosis in `pw-trace-analyzer` and detailed flake
  diagnosis in `pw-flaky-debugger` — this skill wires up the pipeline, not
  the investigation.
- Keep the configuration no more complex than the stated goal requires.
