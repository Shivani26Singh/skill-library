---
name: pw-mobile-tester
description: >-
  Sets up Playwright mobile/responsive web testing — device emulation
  across real device descriptors, touch/gesture interactions, breakpoint
  and orientation coverage, network throttling, geolocation, and
  mobile-specific accessibility (touch target size). Use when an SDET says
  "test this on mobile", "check the responsive breakpoints", "simulate a
  swipe/tap", "test under slow 3G", or "test geolocation on a phone".
  Applies only when the application actually has a responsive/mobile web
  UI to test — produces device-project config and test drafts the
  engineer runs against the real app.
license: MIT
metadata:
  author: Shivani Singh
  pack: playwright
  version: 1.0.0
---

# PW Mobile Tester

You set up **mobile/responsive coverage the engineer must run against the
real app** — device emulation is not a substitute for testing on a real
device before shipping a mobile-critical flow. Confirm the application
genuinely has a responsive/mobile UI before reaching for this skill; it
isn't a default addition to every suite.

## When to use
- The application has a responsive or mobile web UI that needs
  breakpoint, touch, or orientation coverage.
- Someone asks to simulate a tap/swipe/pinch, test under throttled
  network, or test geolocation-driven behavior.
- Visual regression or accessibility checks need to run across device
  profiles, not just desktop.

## When *not* to use
- The application has no meaningful responsive/mobile surface — don't add
  mobile projects for their own sake.
- General visual regression discipline (masking, thresholds, baseline
  review) → `pw-visual-regression`; this skill only adds *which device
  profiles* to run it against.
- General CI/project wiring (sharding, retries, reporters) →
  `pw-ci-configurator`; this skill only adds the mobile `projects` entries.
- Native mobile apps (iOS/Android app binaries) — out of scope; this is
  mobile *web* only, via Playwright's browser emulation.

## Workflow
1. **Use Playwright's built-in device descriptors**
   (`devices['iPhone 14']`, `devices['Pixel 7']`, etc.) — never hand-roll
   a viewport/user-agent/scale-factor combination; the descriptors keep
   touch support, scale factor, and UA consistent and correct.
2. **Cover real breakpoints, not one.** At minimum: a small phone
   (~320–375px), a standard/large phone (~390–430px), and a tablet
   (~768px+). Add a landscape variant for layouts where orientation bugs
   are plausible — many only appear rotated.
3. **Simulate real touch, not mouse clicks.** Use `locator.tap()` /
   `page.touchscreen` for tap and gesture-dependent UI — `.click()`
   doesn't exercise touch-specific behavior. Build swipe/long-press as an
   explicit sequence (`touchscreen` down → `mouse.move` steps → up) only
   when the UI genuinely depends on the gesture; don't gesture-simulate a
   plain button.
4. **Throttle network only for evidence-driven scenarios** — CDP
   `Network.emulateNetworkConditions` (Chromium-only; state this
   limitation) to verify a loading state or offline fallback actually
   appears, not as a default added to every test.
5. **Test geolocation-driven behavior** via context-level `geolocation` +
   `permissions: ['geolocation']`, including the permission-denied
   fallback path — don't test only the happy path where location is
   granted.
6. **Check mobile accessibility** — interactive elements should meet a
   44×44 CSS-pixel minimum touch target; automate this as a sweep over
   clickable elements rather than spot-checking a few.
7. **Reuse `pw-visual-regression`'s discipline for per-device
   screenshots** (masking, thresholds, diff classification) — this skill
   only decides *which device profiles* get a screenshot, not how the
   comparison itself is judged.
8. **Be honest about performance metrics.** LCP and CLS are measurable in
   a synthetic run; FID is not — it requires a real user interaction and
   cannot be faked with a hardcoded value. Prefer TTFB/LCP/CLS, or note
   that INP needs a real interaction harness if it matters.
9. **Run mobile tests selectively in CI** — a full matrix of devices for
   every test is expensive; run smoke coverage broadly and detailed
   coverage on representative devices, per `pw-ci-configurator`'s
   sharding/cost guidance.

## Output shape
```typescript
// playwright.config.ts — mobile device projects
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  projects: [
    { name: 'iphone-se', use: { ...devices['iPhone SE'] } },        // small phone
    { name: 'iphone-14', use: { ...devices['iPhone 14'] } },        // standard phone
    { name: 'pixel-7', use: { ...devices['Pixel 7'] } },            // Android
    { name: 'ipad-pro', use: { ...devices['iPad Pro 11'] } },       // tablet
    { name: 'iphone-14-landscape', use: { ...devices['iPhone 14 landscape'] } },
  ],
});
```
```typescript
test.describe('responsive breakpoints', () => {
  const breakpoints = [
    { name: 'small-phone', width: 320, height: 568 },
    { name: 'standard-phone', width: 390, height: 844 },
    { name: 'tablet', width: 768, height: 1024 },
  ];

  for (const bp of breakpoints) {
    test(`renders correctly at ${bp.name}`, async ({ page }) => {
      await page.setViewportSize(bp);
      await page.goto('/');
      // toggle assertion by width, then let pw-visual-regression own the screenshot comparison
      await expect(page).toHaveScreenshot(`homepage-${bp.name}.png`);
    });
  }
});

test('shows nearby stores based on granted geolocation', async ({ browser }) => {
  const context = await browser.newContext({
    ...devices['iPhone 14'],
    geolocation: { latitude: 40.7128, longitude: -74.006 },
    permissions: ['geolocation'],
  });
  const page = await context.newPage();
  await page.goto('/store-locator');
  await page.getByRole('button', { name: 'Find nearby stores' }).click();
  await expect(page.getByTestId('store-list')).not.toBeEmpty();
});
```

## Guardrails
- Confirm the app actually has a responsive/mobile UI before adding this
  coverage — it's not a default addition to every Playwright suite.
- Never hand-roll viewport/UA/scale-factor values when a Playwright device
  descriptor exists for that device.
- Never use `.click()` where the UI genuinely depends on touch/gesture
  behavior — but don't gesture-simulate elements that work the same under
  a click.
- Never fabricate a performance metric — FID cannot be measured without a
  real user interaction; don't hardcode it to 0 and present it as a
  measurement.
- Never treat CDP network throttling as available cross-browser — it's
  Chromium-only; say so.
- Defer screenshot-comparison discipline (masking, thresholds, diff
  classification) to `pw-visual-regression`, and CI cost/sharding
  tradeoffs to `pw-ci-configurator` — this skill only adds the device
  dimension to each.
- Never invent a selector, route, or app behavior not shown — mark
  unconfirmed elements for engineer verification, same as every other
  skill in this pack.
