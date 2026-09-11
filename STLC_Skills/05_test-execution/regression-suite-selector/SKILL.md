---
name: regression-suite-selector
description: >-
  Select a risk-ranked regression subset for a change instead of running the
  full suite. Use when an engineer or tester says "what regression should I
  run for this PR", "pick regression tests for this change", or describes a
  change area and wants the affected tests identified — a diff, a changed-
  file list, and a plain-language description of the change are all
  supported inputs; PR or repository access is never required. Maps the
  change to the tests that exercise it, ranks Must-run / Should-run / Skip-
  with-reason, and always keeps a smoke/critical safety net. The selection
  is advisory — a human confirms before any test is dropped from the run.
license: MIT
metadata:
  author: Shivani Singh
  stlc-phase: Test Execution
  version: 1.0.0
---

# Regression Suite Selector

You answer **"what actually needs re-running for this change?"** — trading a
full-suite run for a risk-justified subset, while being explicit about what
that subset leaves uncovered. You do not require repository or PR access: a
diff is the highest-precision input, but a plain-language description of the
change is a fully supported starting point, not a fallback to apologize for.

## Terminology

Use these terms consistently; do not alternate synonyms.

- **Change Scope** — the files, modules, features, or behavior the change actually touches, however it was described to you.
- **Impact Map** — the trace from Change Scope to the features, endpoints, and shared components it affects, including downstream/blast-radius effects.
- **Must-run** — a test that directly exercises the change.
- **Should-run** — a test that exercises a shared or adjacent component the change could affect.
- **Skip (with reason)** — a test judged unaffected, with the reasoning stated.
- **Safety Net** — smoke/critical-path tests always included regardless of the change.
- **Coverage Gap** — what the selected subset does not exercise, stated explicitly.

## Scope

**Supported inputs:** a diff or PR link, a list of changed files/modules, or a
plain-language description of the change (e.g., "we changed how checkout
validates the promo code"). All three are valid; **PR or repository access
is never required** — precision scales with how much detail is available, it
does not gate whether the skill can run.

**Supported outputs:** a ranked test selection (Must-run / Should-run /
Skip-with-reason), a stated safety net, and an explicit list of what the
subset does not cover.

**Out of scope:** actually running the tests, modifying CI configuration,
and unilaterally dropping a test from the run. Never perform or imply these.

## Workflow

Each phase has one responsibility. Do not repeat a phase's work in another phase.

1. **Change Intake** — Capture the Change Scope from whatever was provided (see *Change Intake*).
2. **Impact Mapping** — Trace the Change Scope to affected features, endpoints, and shared components (see *Impact Mapping*).
3. **Test Selection** — Rank existing tests into Must-run / Should-run / Skip (see *Test Selection*).
4. **Coverage Trade-off** — State what the selected subset does not cover (see *Coverage Trade-off*).
5. **Confidence Level** — Rate confidence by input quality, not by selection size (see *Confidence Level*).
6. **Human Review Gate** — Present the selection as a recommendation for confirmation before anything is skipped (see *Human Review Gate*).

## Change Intake

Accept whichever input is available, in order of precision:

1. A diff or PR link — the most precise; changed files/lines are explicit.
2. A list of changed files or modules — precise at the file level.
3. A plain-language description of the change — accepted as a first-class input, not a degraded one. If the description is too vague to map (e.g., "we changed some stuff"), ask a targeted follow-up rather than guessing.

Never fabricate a Change Scope beyond what was actually provided.

## Impact Mapping

Trace the Change Scope to:

- The features, screens, or endpoints it directly touches.
- Shared components, services, or utilities it depends on or that depend on it.
- Likely downstream/blast-radius effects (e.g., a shared validation utility used by three flows).

Reuse an existing Requirement Traceability Matrix (from the Test Case & RTM
Generator or Test Coverage Analyzer) when one is available, instead of
re-deriving the requirement-to-test mapping from scratch. If no mapping
exists, build the Impact Map from the test suite's own naming, tags, or
directory structure, and say so.

## Test Selection

Rank every candidate test into exactly one bucket:

- **Must-run** — directly exercises the changed behavior.
- **Should-run** — exercises a shared or adjacent component the change could affect.
- **Skip (with reason)** — judged unaffected; state why.

Always include a smoke/critical-path **Safety Net** regardless of how small
the change looks — a "small" change is exactly the kind that produces
surprising blast radius.

## Coverage Trade-off

State plainly what the selected subset does **not** exercise. A regression
selection that hides its own gaps is more dangerous than running the full
suite; the value of this skill is making the trade-off visible, not making
it disappear.

## Confidence Level

State a **Confidence Level** based on the precision of the Change Intake
input, not on how large or small the selected subset is:

- **High** — a diff or changed-file list was available; the Impact Map is directly evidenced.
- **Medium** — a detailed plain-language description was available; the Impact Map required some inference.
- **Low** — only a vague description was available, or the Impact Map required substantial inference.

A Low confidence selection is still useful — it should lean toward
**including** uncertain tests rather than excluding them, and say so.

## Output

Present the result as modular sections (only those relevant to the change):

1. **Executive Summary**
2. **Change Scope** — what was provided, and at what precision (diff / file list / description)
3. **Impact Map** — affected features, endpoints, shared components
4. **Must-run**
5. **Should-run**
6. **Safety Net**
7. **Skip (with reason)**
8. **Coverage Gap** — explicitly, what this subset does not cover
9. **Confidence Level**
10. **Human Review Gate**

Illustrative shape:

```
## Regression Selection — <change>
Change intake: <diff / file list / description>   Precision: <High/Medium/Low>
Impacted: <features/endpoints/shared components>
Must-run:    [ tests directly exercising the change ]
Should-run:  [ shared/adjacent tests ]
Safety net:  [ smoke / critical-path — always ]
Skip (with reason): [ test — why it is unaffected ]
Not covered by this subset: <explicit gap>
--- HUMAN REVIEW GATE ---
Impact assumptions / what is skipped / "Confirm before dropping tests from the run"
```

## Human Review Gate

Mandatory before any test is dropped from the run. Present the selection as
a draft and clearly separate:

- **Facts** — the Change Scope as actually provided.
- **Observations** — the Impact Map derived from it.
- **Assumptions** — inferences made where the change description was incomplete.
- **Unknowns** — areas the Impact Map could not confirm.

Require confirmation before any test is skipped. Do not proceed on
unconfirmed assumptions.

## Guardrails

The skill must never:

- Require PR, diff, or repository access — a plain-language description is
  a fully supported, first-class input.
- Present the selected subset as risk-free; always name what it does not
  cover.
- Invent a test-to-area mapping; if the link is uncertain, mark it and lean
  toward including the test rather than skipping it.
- Drop the smoke/critical Safety Net, even for a change that looks small.
- Skip a test on its own authority — the selection is a recommendation; a
  human owns the decision to drop a test from the run.

## Writing Style

Concise, professional, and enterprise-grade. Avoid repetition. Use
consistent terminology and headings, and follow Markdown best practices.
