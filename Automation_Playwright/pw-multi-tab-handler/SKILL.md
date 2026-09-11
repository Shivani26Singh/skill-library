---
name: pw-multi-tab-handler
description: >-
  Writes race-free Playwright code for any flow that opens a second tab,
  popup, or window — target="_blank" links, "open in new window" buttons,
  OAuth/SSO consent screens, payment redirects, and PDF preview tabs. Use
  when an SDET says "my test can't find the element after this link opens
  a new tab", "handle this OAuth popup", "window.open breaks my test", or
  a test needs to manage several open tabs at once. Produces code that
  subscribes to the new-page event before triggering the action, never
  after — a draft the engineer verifies against the real flow.
license: MIT
metadata:
  author: Shivani Singh
  pack: playwright
  version: 1.0.0
---

# PW Multi-Tab Handler

You write **race-free tab/popup-handling code the engineer must verify**
against the real flow — never assume a selector, OAuth field, or redirect
URL exists. The one rule underneath every pattern here: a new page is an
**event to subscribe to before the click**, never something to poll for
afterward.

## When to use
- A click opens a new tab/window (`target="_blank"`, `window.open`, a
  payment or SSO redirect) and the test needs to interact with it.
- Several tabs are open at once and the test needs to switch between them
  reliably.
- Someone reports a popup test that hangs, times out, or is flaky.

## When *not* to use
- Generating the rest of the test around this flow → `pw-test-generator`.
- The flakiness isn't tab-related (timing, shared state, missing await
  elsewhere) → `pw-flaky-debugger`.
- The tab-opening element itself has a brittle locator →
  `pw-locator-fixer`.

## Workflow
1. **Subscribe before you act.** Register `context.waitForEvent('page')` or
   `page.waitForEvent('popup')` *before* the triggering action, and await
   both together with `Promise.all([...])`. Subscribing after the click is
   a race — the event may already have fired.
2. **Prefer `page.waitForEvent('popup')`** over `context.waitForEvent('page')`
   when one specific element triggers the new window (e.g. `window.open`) —
   it scopes the wait to the exact opener rather than any new page in the
   context.
3. **Always `await newPage.waitForLoadState()`** before any locator or URL
   assertion — the page object resolves the instant the tab exists, not
   when it has content.
4. **Hold a reference, never index by position.** `context.pages()[1]` is
   not portable across Chromium/Firefox/WebKit; capture and use the
   returned `Page` object.
5. **For an OAuth/SSO popup**, drive the provider's screen inside the
   popup, then wait on `popup.waitForEvent('close')` as the signal auth
   finished before asserting on the main page — with a generous timeout,
   since provider redirects are slow. Prefer replaying a saved
   `storageState` from one login in global setup over driving the popup in
   every test.
6. **Close popups you opened** (or rely on context teardown) — leaked tabs
   slow the suite and can steal modal focus.
7. **All tabs in one `BrowserContext` share cookies/storage** — a
   cross-origin OAuth popup still arrives as a `page` event; it never
   needs a new context, which would throw away the session.

## Output shape
```typescript
import { test, expect } from '@playwright/test';

test('opens docs in a new tab', async ({ context, page }) => {
  await page.goto('/app');

  // Subscribe BEFORE the click, await both together.
  const [newPage] = await Promise.all([
    context.waitForEvent('page'),
    page.getByRole('link', { name: 'Open docs' }).click(),
  ]);

  await newPage.waitForLoadState('domcontentloaded'); // page exists immediately; content doesn't
  await expect(newPage).toHaveURL(/\/docs/);
  await newPage.close();
});

test('logs in via an OAuth popup', async ({ page }) => {
  const popupPromise = page.waitForEvent('popup');
  await page.getByRole('button', { name: 'Continue with Google' }).click();
  const oauth = await popupPromise;

  await oauth.waitForLoadState('domcontentloaded');
  // ... drive the provider's consent screen inside `oauth` ...

  await oauth.waitForEvent('close'); // provider closes itself; wait for that first
  await expect(page.getByText('Signed in as')).toBeVisible({ timeout: 15_000 });
});
```

A reusable helper keeps this pattern out of every test:
```typescript
export async function openInNewTab(
  context: BrowserContext,
  action: () => Promise<void>,
  loadState: 'load' | 'domcontentloaded' | 'networkidle' = 'domcontentloaded',
): Promise<Page> {
  const [newPage] = await Promise.all([context.waitForEvent('page'), action()]);
  await newPage.waitForLoadState(loadState);
  return newPage;
}
```

## Guardrails
- Never invent a selector, OAuth field, or redirect URL you weren't
  shown — this is a draft the engineer verifies against the real flow.
- Never subscribe to the page/popup event after the triggering click —
  that's the race this skill exists to prevent.
- Never use `waitForTimeout` to "wait for the tab to open," and never
  select a tab by `context.pages()` index — hold the returned reference.
- Never spawn a fresh `browser.newContext()` for an OAuth popup — it
  discards the session cookies the flow needs.
- Assert on a new page only after `waitForLoadState` — the page object
  existing is not the same as its content being ready.
