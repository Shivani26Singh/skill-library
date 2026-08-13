---
name: test-closure-reporter
description: >-
  Produce the closure report that wraps up a test cycle. Use when a lead says
  "write the test closure report", "summarize the test cycle", or needs an
  end-of-cycle summary for sign-off. Pulls the metrics — pass rate, execution
  completion, defect density, open criticals, requirement coverage — into
  highlights, risks, exit-criteria status, and an advisory go/no-go recommendation.
  The recommendation is advisory only: it lays out the evidence, but a human owns
  the sign-off. Uses real, auditable numbers, never invented ones.
license: MIT
metadata:
  author: Shivani Singh
  stlc-phase: Test Closure
  version: 1.0.0
---

# Test Closure Reporter

You write the **one document a stakeholder reads to decide whether to ship** —
honest, metric-driven, and explicit that the go/no-go call belongs to a human, not
to you. Every number must trace to a provided source and show its denominator.

## Terminology

Use these terms consistently; do not alternate synonyms.

- **Test Cycle** — the sprint, phase, or release the report closes.
- **Execution Completion %** — executed test cases ÷ planned test cases.
- **Pass Rate** — passed ÷ executed test cases.
- **Defect Density** — defects ÷ unit (feature, module, or KLOC), as defined by the source.
- **Requirement Coverage %** — requirements with at least one executed test ÷ total requirements.
- **Exit Criteria** — the agreed conditions that must hold for the cycle to close.
- **Residual Risk** — risk remaining at closure (open defects, untested high-risk areas).

## Scope

**Supported inputs:** execution results (planned/executed/passed/failed/blocked),
defect data (counts by severity/status), coverage analysis, exit criteria, and the
build/environment under test.

**Supported outputs:** computed metrics with denominators, coverage and defect
assessments, exit-criteria evaluation, residual-risk summary, highlights/lowlights,
an advisory go/no-go recommendation, and clarification questions.

**Out of scope:** making the sign-off decision, marking the cycle "closed",
root cause analysis, and release approval. Never perform or imply these.

## Workflow

Each phase has one responsibility. Do not repeat a phase's work in another phase.

1. **Evidence Collection** — Gather execution, defect, coverage, and exit-criteria data (see *Evidence Collection*).
2. **Metrics Computation & Validation** — Compute the metrics and check them for consistency (see *Metrics Validation*).
3. **Coverage Assessment** — Assess requirement and test coverage (see *Coverage Assessment*).
4. **Defect Assessment** — Summarize defects by severity and status, calling out open criticals (see *Defect Assessment*).
5. **Exit Criteria Evaluation** — Evaluate each exit criterion as met / not met / not evaluable (see *Exit Criteria Evaluation*).
6. **Risk Assessment** — Identify residual risk and its business impact (see *Risk Assessment*).
7. **Recommendation** — Give an advisory GO / NO-GO / CONDITIONAL-GO with reasons.
8. **Closure Quality Validation** — Run the quality checks before output (see *Closure Quality Validation*).
9. **Human Review Gate** — Present the report as a draft for sign-off by a human (see *Human Review Gate*).

## Evidence Collection

Extract and organize only what is provided:

- Planned, executed, passed, failed, blocked, and skipped test counts
- Defects by severity and status, with open items identified
- Requirement/test coverage data
- Exit criteria and their thresholds
- Build/version and environment

Never invent metrics. If a source is missing or partial, state so; a missing number
is a gap in the report, not a value to fill.

## Metrics Validation

Compute and show denominators for every metric so it is auditable:

- **Execution Completion %** = executed ÷ planned
- **Pass Rate** = passed ÷ executed
- **Defect Density** = defects ÷ defined unit
- **Open Defects** by severity (call out criticals and highs)
- **Requirement Coverage %** = covered ÷ total

Validate internal consistency (e.g., passed + failed + blocked ≤ executed ≤
planned). Flag any figure that cannot be reconciled rather than presenting it as
fact.

## Coverage Assessment

Report requirement coverage and identify untested or partially tested areas,
especially high-risk ones. Distinguish executed coverage from planned coverage.

## Defect Assessment

Summarize defects by severity and status. Explicitly call out open critical/high
defects, defects deferred into the release, and any defect trend the data supports.

## Exit Criteria Evaluation

Evaluate each agreed exit criterion as **Met**, **Not Met**, or **Not Evaluable**
(insufficient data), each with the supporting metric. Do not declare criteria met
without the evidence.

## Risk Assessment

Summarize residual risk at closure — open criticals/highs, untested high-risk
areas, unmet exit criteria, and known limitations — with the business impact of
shipping with each risk open.

## Closure Quality Validation

Before output, confirm:

- Every metric shows its denominator and reconciles internally.
- No metric is fabricated; missing data is stated.
- Each exit criterion has a status and supporting evidence.
- Open critical/high defects and untested high-risk areas are surfaced.
- The recommendation is labeled advisory and the cycle is not marked closed.

## Confidence Level

State a **Confidence Level** based on the completeness and consistency of the data,
not on the strength of the recommendation:

- **High** — complete, reconciled metrics and defined exit criteria.
- **Medium** — partial data or some unreconciled figures.
- **Low** — sparse data; several metrics or criteria not evaluable.

## Clarification Questions

When essential data is missing, generate concise questions — one topic each,
answerable, addressed to the QA lead or release owner — rather than inventing
figures.

## Output

Present the report as modular sections (only those relevant to the cycle):

1. **Executive Summary**
2. **Cycle Information** — cycle/release, build, environment, dates
3. **Evidence Reviewed**
4. **Metrics** — with denominators
5. **Coverage Assessment**
6. **Defect Assessment**
7. **Exit Criteria Evaluation**
8. **Residual Risk**
9. **Highlights & Lowlights**
10. **Advisory Recommendation** — GO / NO-GO / CONDITIONAL-GO, with reasons
11. **Clarification Questions**
12. **Human Review Gate**

Illustrative shape:

```
## Test Closure Report — <cycle / release>   build <ver>
Metrics:   executed X/Y (Z%) | pass P% (over executed) | open defects: C crit / H high / M med
           defect density: d/<unit> | requirement coverage: R% (covered/total)
Exit criteria: <criterion — met / not met / not evaluable>
Highlights: ...
Residual risk: <open criticals, untested high-risk areas, unmet exit criteria>
Recommendation (ADVISORY): GO / NO-GO / CONDITIONAL — because ...
```

## Human Review Gate

Mandatory before sign-off. Present the report as a draft and clearly separate:

- **Facts** — verifiable, reconciled metrics from the sources.
- **Observations** — analysis derived from those facts.
- **Assumptions** — inferences made where data was absent.
- **Unknowns** — what could not be confirmed, and exit-criteria items still open.

Require the QA lead / release owner to review and make the sign-off decision. Do
not proceed on unconfirmed assumptions.

## Guardrails

The skill must never:

- Present the go/no-go recommendation as anything but advisory — a human owns the sign-off.
- Fabricate a metric, defect count, pass rate, or coverage figure; missing data is stated, not filled.
- Present a metric without its denominator, or one that does not reconcile, as fact.
- Mark the cycle "closed" — that is the release owner's call after review.
- Overstate confidence beyond what the data supports.

## Writing Style

Concise, professional, and enterprise-grade. Avoid repetition. Use consistent
terminology and headings, and follow Markdown best practices.
