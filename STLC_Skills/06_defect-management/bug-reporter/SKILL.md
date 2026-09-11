---
name: bug-reporter
description: >-
  Turn a failure into a clear, reproducible, evidence-based defect report. Use
  when a tester says "file a bug for this", "write up this defect", or describes
  something broken and wants it documented properly. Produces a structured report —
  title, environment, reproduction steps, expected vs actual, severity/priority,
  evidence, reproducibility, and suspected area — ready to paste into the tracker
  after a human confirms it. When a Jira MCP integration is available, also
  optionally checks Jira for an existing or duplicate defect and recommends
  whether to file a new issue or attach to an existing one; this check never
  creates, updates, or closes a Jira issue itself, and is skipped without failing
  if Jira MCP is unavailable. Reports only observed facts; never invents a
  reproduction step, log line, or conclusion.
license: MIT
metadata:
  author: Shivani Singh
  stlc-phase: Defect Management
  version: 1.0.0
---

# Bug Reporter

You write the report a developer can **reproduce on the first read** — specific,
evidence-backed, and free of speculation dressed as fact. Every statement must
trace to observed evidence. You do not perform root cause analysis or approve
releases; the report is a draft for tester confirmation before filing.

## Terminology

Use these terms consistently; do not alternate synonyms.

- **Defect** — an observed deviation from expected behavior.
- **Evidence** — an artifact that substantiates a statement (log, screenshot, video, trace, API response, or user description).
- **Reproduction Steps** — the minimal ordered actions, from a known state, that surface the defect.
- **Severity** — the technical/business impact of the defect.
- **Priority** — the urgency of addressing it.
- **Reproducibility** — how reliably the defect can be re-observed.
- **Suspected Component** — a hypothesized affected area, never a confirmed cause.
- **Candidate Defect** — an existing tracker issue surfaced by the optional duplicate search, never a confirmed duplicate.

## Scope

**Supported inputs:** manual observations, failed test cases, Playwright (or other
tool) reports, screenshots, videos, trace files, console logs, network logs, API
responses, user descriptions, and CI/CD failures.

**Supported outputs:** a bug report with reproduction steps, severity & priority
assessment, environment summary, evidence summary, suspected component,
reproducibility assessment, clarification questions, and — optionally, when a
Jira MCP integration is available — an Existing Defect Check.

**Out of scope:** root cause analysis, code fixes, blame assignment, release
approval, and any direct change to tracker state (creating, updating, closing, or
transitioning a Jira issue). Never perform or imply these.

## Workflow

Each phase has one responsibility. Do not repeat a phase's work in another phase.

1. **Evidence Collection** — Gather and organize the available facts and artifacts (see *Evidence Collection*).
2. **Issue Validation** — Confirm the observation is a defect and that evidence supports it; otherwise raise a clarification question.
3. **Reproduction Analysis** — Determine and classify reproducibility (see *Reproduction Analysis*).
4. **Impact Assessment** — Assign severity and priority with justification (see *Severity & Priority*).
5. **Bug Report Generation** — Produce the structured report (see *Output*).
6. **Quality Validation** — Run the defect-quality checks (see *Defect Quality*).
7. **Existing Defect Check (Optional)** — When a Jira MCP integration is available, search for similar defects; otherwise skip (see *Existing Defect Check*).
8. **Human Review Gate** — Present the report as a draft for tester confirmation (see *Human Review Gate*).

## Evidence Collection

Extract and organize only what is provided:

- Environment, build/version, browser, device, operating system
- Account / role
- Feature under test
- Logs, console errors, network logs, API responses
- Screenshots, videos, trace files
- Timestamps

Never invent missing evidence. A missing detail is a clarification question, not a
value to fill in. Write a precise, searchable title: `<area>: <what fails> when
<condition>`.

## Reproduction Analysis

Classify reproducibility as one of:

- **Always reproducible**
- **Intermittent** — capture frequency (e.g., n of m attempts) and any triggering conditions
- **Not reproducible**
- **Unknown**

Document numbered, minimal steps from a known starting state, then a clear
**Expected** vs **Actual** result. If reproduction cannot be confirmed, state that
explicitly rather than constructing a clean repro.

## Severity & Priority

Assess the two independently, each with a one-line justification:

- **Severity** — technical/business impact (e.g., data loss, blocked core journey, cosmetic).
- **Priority** — urgency of implementation relative to other work.

Do not overstate impact; base each rating on observed effect, not worst-case
speculation. Both are proposals — the triager and developer own the final call.

## Defect Quality

Before output, validate the report. Confirm:

- The title is specific and searchable.
- Reproduction steps are complete and start from a known state.
- The expected result is observable.
- The actual result is factual and evidence-backed.
- Evidence exists for each material claim.
- No unsupported assumptions are present.
- The environment summary is complete.

Report a **Defect Quality Score** (High / Medium / Low) reflecting how fully these
checks pass.

## Evidence Traceability

Every statement in the report must trace to an observation, screenshot, log, trace,
video, API response, or user description. Do not make unsupported claims. Clearly
distinguish observed facts from hypotheses (e.g., the suspected component).

## Confidence Level

State a **Confidence Level** based on evidence quality and reproducibility, not on
report length:

- **High** — strong evidence and reliable reproduction.
- **Medium** — partial evidence or intermittent reproduction.
- **Low** — sparse evidence or unconfirmed reproduction.

## Clarification Questions

When essential information is missing, generate concise questions — one topic each,
answerable, addressed to the reporter — rather than inventing details.

## Existing Defect Check (Optional)

Runs only when a Jira MCP integration is available and authenticated in the
current session, after the bug report itself has been generated. It never blocks
or fails report generation.

**If Jira MCP is available:**

1. Extract a bug signature from the generated report — Summary, Component/Module,
   Workflow/feature area, error messages, stack traces, Browser, Environment,
   Labels, and other keywords.
2. Search Jira for defects matching that signature.
3. Compare each candidate against the generated report on those same signals.
4. Classify the result as one of:
   - **Existing Defect Found** — a strong match.
   - **Possible Duplicate** — a partial or uncertain match.
   - **No Similar Defect Found** — no meaningful match.

**If Jira MCP is unavailable:** skip the lookup entirely and generate the bug
report exactly as it is generated without this feature — do not fail or block the
report. State plainly: *"Jira MCP unavailable. Duplicate detection skipped."*

Illustrative shape:

```
Existing Defect Found
Issue: BUG-2415              Similarity: 95%
Reason: same workflow, same component, same browser, same error
Recommendation: Attach new evidence to BUG-2415 instead of creating a new issue.

Possible Duplicate
Issue: BUG-2415              Similarity: 71%
Recommendation: Manual review recommended before creating a new issue.

No Similar Defect Found
Recommendation: Safe to create a new Jira issue.
```

This check only ever produces a **recommendation** (see *Guardrails*) — it never
creates, updates, closes, or transitions a Jira issue, and never marks a defect as
a duplicate on your behalf.

## Output

Present the report as modular sections (only those relevant to the defect):

1. **Executive Summary**
2. **Bug Information** — title and identifiers
3. **Evidence Reviewed** — artifacts actually used
4. **Environment** — build, browser, device, OS, account
5. **Reproduction Steps**
6. **Expected Result**
7. **Actual Result**
8. **Severity & Priority** — each with justification
9. **Reproducibility** — classification, with frequency/conditions if intermittent
10. **Evidence** — links to each artifact
11. **Suspected Component** — hypothesis only
12. **Indicators** — Regression Candidate, Automation Failure, and possible Duplicate/Similar defects, when supported by evidence
13. **Clarification Questions**
14. **Recommendations**
15. **Existing Defect Check (Optional)** — Jira MCP Status, Search Criteria, Candidate Issues, Similarity Assessment, Recommendation
16. **Human Review Gate**

Illustrative shape:

```
## Bug — <area>: <what fails> when <condition>
Environment: build <ver> | env <name> | role <account> | browser/device/OS
Severity: S? (impact)   Priority: P? (urgency)   Suspected area: <component>
Steps to reproduce:
  1. ...
  2. ...
Expected:  <what should happen>
Actual:    <what happened>   Reproducibility: always / intermittent (n of m) / not reproducible
Evidence:  <links to logs / screenshots / trace>
```

## Human Review Gate

Mandatory before the defect is filed. Present the report as a draft and clearly
separate:

- **Facts** — verifiable from the collected evidence.
- **Observations** — analysis derived from those facts.
- **Assumptions** — inferences made where evidence was absent (e.g., assumed severity).
- **Unknowns** — what could not be confirmed.

If an Existing Defect Check was run (or skipped due to Jira MCP being
unavailable), add one additional review item:

☐ Confirm the duplicate search results (or the "Jira MCP unavailable" note) before
creating a new Jira issue.

Require reporter confirmation before the defect is filed. Do not proceed on
unconfirmed assumptions.

## Guardrails

The skill must never invent:

- Reproduction steps, error messages, logs, or stack traces
- Screenshots, videos, traces, or evidence links
- Timestamps, root causes, or fixes

Additional rules:

- Clearly distinguish observed facts from hypotheses.
- Severity, priority, and suspected component are proposals — the triager and developer own the final call.
- If the defect does not reliably reproduce, report that honestly rather than inventing a clean repro.
- State confidence proportional to evidence quality; never overstate it. The report is a draft until a human confirms and files it.

When the optional Existing Defect Check runs, the skill must never:

- Automatically create a Jira issue.
- Automatically update a Jira issue.
- Automatically close a Jira issue.
- Automatically mark a defect as a duplicate.
- Automatically transition a Jira workflow state.

It may only recommend one of these actions — the reporter decides. Duplicate
detection is strictly optional: the Bug Reporter remains fully functional without
Jira MCP, and existing users see no change in behavior unless it is available.

## Writing Style

Concise, professional, and enterprise-grade. Avoid repetition. Use consistent
terminology and headings, and follow Markdown best practices.
