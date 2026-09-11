---
name: pw-visual-regression
description: >-
  Sets up and reviews Playwright visual/screenshot regression testing —
  JavaScript or TypeScript — to catch meaningful visual regressions while
  minimizing false positives from nondeterministic rendering or dynamic
  content. Use when an SDET says "add visual regression", "snapshot this
  component", "set up toHaveScreenshot", "mask the dynamic parts of this
  page", "why does my screenshot test keep failing", or "manage baselines".
  Produces snapshot tests with masking, thresholds, and a baseline
  strategy — a draft the engineer runs to generate and review the first
  baselines.
license: MIT
metadata:
  author: Shivani Singh
  pack: playwright
  version: 1.0.0
---

# PW Visual Regression

You set up **snapshot tests whose first baselines the engineer must
generate and eyeball** — never trust an auto-approved baseline. You make
snapshots deterministic, and visual assertions complement functional ones
rather than replacing them.

## When to use
- A page or component needs pixel/visual regression coverage.
- Flaky snapshot diffs need masking or threshold tuning.
- Someone says "add visual regression", "manage/update baselines", "why
  does my screenshot test keep failing".

## When *not* to use
- Generating the underlying Playwright test → `pw-test-generator`.
- Fixing a brittle locator used to find the screenshot target →
  `pw-locator-fixer`.
- Diagnosing general test flakiness → `pw-flaky-debugger`.
- Analyzing a trace → `pw-trace-analyzer`.
- Controlling network responses that feed the page → `pw-network-mocker`.
- Building the Page Object or fixture a visual test reuses →
  `pw-page-object-builder` / `pw-fixture-designer` (reuse what exists;
  don't design new ones here).

Don't use visual regression as just another way to assert functional
behavior — keep a functional assertion (`toBeVisible`, `toHaveText`) for
behavior, and the screenshot for appearance.

## Language and project conventions
Support both **JavaScript and TypeScript** — preserve the project's
existing language and conventions; never convert between them, and never
introduce TypeScript syntax into JavaScript output.

## Workflow
1. **Pick the smallest stable target** — an element or component locator
   over a full page where possible; less surface means fewer false diffs.
2. **Reach a deterministic state before snapping.** Wait on a web-first
   assertion (`await expect(heading).toBeVisible()`) first — never add an
   arbitrary delay because a screenshot occasionally differs.
3. **Control rendering conditions** as tightly as practical: viewport,
   device scale factor, fonts, OS/browser version, locale, timezone, color
   scheme, reduced-motion settings, and application data. The more these
   vary between baseline generation and comparison, the less reliable the
   result — generate baselines in the CI environment, not just locally.
4. **Neutralize dynamic content** — timestamps, avatars, ads, live
   counters, loading indicators, rotating content:
   - `mask` only the smallest region that's actually dynamic; never mask
     content the test is meant to validate, and never mask a large area
     just to make a diff go away.
   - `animations: 'disabled'` unless the animation itself is what the test
     validates — disabling it there would defeat the test's purpose.
   - Prefer controlled/deterministic test data over live or random data.
   - Never invent a selector, test ID, or masked region that doesn't exist.
5. **Set thresholds deliberately** (`maxDiffPixels` / `maxDiffPixelRatio` /
   `threshold`), not sprinkled ad hoc and never bumped just to make a
   failing test pass. Before adjusting one: inspect the actual diff,
   determine why the pixels differ, decide whether that difference is
   meaningful, and only then adjust — a large tolerance can hide a real
   regression.
6. **Classify every screenshot failure** before touching a baseline:
   - **Expected change** — an intentional UI change; update the baseline
     after verifying it.
   - **Unexpected regression** — don't update the baseline; report the bug.
   - **Test instability** — e.g. a timestamp differs between runs;
     stabilize or mask the dynamic region instead of updating.
   - **Environment difference** — e.g. font rendering differs by platform;
     standardize the rendering environment instead of accepting the diff.
7. **Generate baselines intentionally** via `--update-snapshots`, then
   **review each PNG by eye** before committing — an unreviewed baseline
   can lock in a bug forever. Document the update flow so baselines are
   refreshed on purpose, per platform.

## Output format
1. **Visual target** — what's being compared.
2. **Stable state** — how the test reaches the intended UI state before
   snapping.
3. **Screenshot test** — the Playwright code.
4. **Dynamic content** — what needs stabilizing or masking.
5. **Baseline strategy** — when/how the baseline is created or updated.
6. **Tolerance** — thresholds, only when there's a clear reason for them.
7. **Verification** — how to review a failure and tell an expected change
   from a regression, instability, or an environment difference.

### Example
```typescript
import { test, expect } from '@playwright/test';

test('dashboard card matches baseline', async ({ page }) => {
  await page.goto('/dashboard');
  const card = page.getByTestId('summary-card');
  await expect(card).toBeVisible();                       // web-first: wait for render
  await expect(card).toHaveScreenshot('summary-card.png', {
    animations: 'disabled',
    mask: [page.getByTestId('last-updated')],             // hide volatile timestamp
    maxDiffPixelRatio: 0.01,
  });
});
```
```
# generate/refresh baselines, then review the PNGs before committing
npx playwright test --update-snapshots
```

## Guardrails
- Baselines are **generated then human-reviewed** — never auto-approve;
  never update one merely because a test failed.
- Never invent a route, selector, test ID, accessible name, application
  data, or baseline file that doesn't exist.
- Never use a large tolerance, or `waitForTimeout()`, to hide an
  unstable or unreviewed diff.
- Don't mask large areas unnecessarily, and never mask content the test is
  actually meant to validate.
- Don't replace a functional assertion with a screenshot — keep both.
- Investigate *why* a diff occurred before changing a threshold or a
  baseline; prefer the smallest screenshot target that gives meaningful
  coverage.
- Keep rendering conditions consistent where practical (viewport, fonts,
  OS/browser, locale, timezone, color scheme).
- Reuse existing Page Objects and fixtures rather than designing new ones
  here — that belongs to `pw-page-object-builder` / `pw-fixture-designer`.
- Preserve the project's JS/TS convention; never convert between them.
- State assumptions explicitly when the UI or rendering environment can't
  be verified.
