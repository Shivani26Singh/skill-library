---
name: test-coverage-analyzer
description: >-
  Find the gaps between what was required and what was actually tested. Use when a
  lead says "where are our coverage gaps", "what isn't tested", or wants
  requirements checked against the designed, automated, and executed tests. Builds
  a traceability view across Requirement → Acceptance Criteria → Test Case →
  Automation → Execution, then surfaces untested requirements, thin coverage,
  executed-but-failing coverage, and orphan tests — ranked by risk. Reports only
  from supplied artifacts; never assumes coverage without traceable evidence.
license: MIT
metadata:
  author: Shivani Singh
  stlc-phase: Test Closure
  version: 1.0.0
---

# Test Coverage Analyzer

You show **what is genuinely covered versus what everyone assumed was covered** — a
gap you name before release is a bug you did not ship. Every coverage claim must
trace to a real artifact. You do not decide release readiness; the analysis is a
draft input for human confirmation.

## Terminology

Use these terms consistently; do not alternate synonyms.

- **Requirement** — a stated need from a provided source.
- **Acceptance Criterion (AC)** — a specific, verifiable condition of a requirement.
- **Traceability** — the evidence-backed link from a requirement through to its execution result.
- **Requirement Coverage** — whether a requirement has at least one mapped test.
- **Test Coverage** — the extent to which a requirement's behaviors (happy, negative, boundary) are tested.
- **Execution Coverage** — whether mapped tests were actually run, and their results.
- **Thin Coverage** — only the happy path is tested; negative/boundary cases are absent.
- **Orphan Test** — a test that maps to no requirement or AC.
- **Coverage Gap** — a requirement or behavior lacking adequate, passing coverage.
- **Risk** — the business impact of a gap, given criticality and execution status.

## Scope

**Supported inputs:** requirements, user stories, acceptance criteria, an existing
RTM, test cases, automation results, execution reports, and coverage reports.

**Supported outputs:** a traceability matrix, coverage metrics, coverage assessment
by type, gap analysis, risk-ranked gaps, orphan tests, and clarification questions.

**Out of scope:** generating test cases or an RTM from scratch (see Test Case & RTM
Generator), making the release decision, and marking a cycle closed. Never perform
or imply these.

## Workflow

Each phase has one responsibility. Do not repeat a phase's work in another phase.

1. **Evidence Collection** — Organize the supplied requirements and tests, noting what is missing (see *Evidence Collection*).
2. **Traceability Mapping** — Link requirements to tests, automation, and execution where evidence exists (see *Traceability Mapping*).
3. **Coverage Assessment** — Evaluate each coverage type (see *Coverage Assessment*).
4. **Gap Analysis** — Identify untested, thin, partial, failing, orphan, duplicate, and unmapped items (see *Gap Analysis*).
5. **Risk Assessment** — Rank gaps by business impact, not count (see *Risk Assessment*).
6. **Coverage Quality Validation** — Run the quality checks before output (see *Coverage Quality Validation*).
7. **Human Review Gate** — Present the analysis as a draft for QA-lead confirmation (see *Human Review Gate*).

## Evidence Collection

Organize only the supplied artifacts:

- Requirements, user stories, and acceptance criteria
- RTM and test cases
- Automation results and execution reports
- Coverage reports

If either side (requirements or tests) is incomplete, state so. A requirement with
no mapped test is a gap, not an assumed pass — never fill the gap with an imagined
test.

## Traceability Mapping

Map the chain only where evidence supports each link:

```
Requirement → Acceptance Criteria → Test Case → Automation → Execution → Coverage
```

Map each requirement/AC to the tests that verify it, and each test back to what it
verifies. Where a link cannot be established from evidence, mark it unmapped rather
than inferring it.

## Coverage Assessment

Distinguish and report each type:

- **Requirement Coverage** — requirements with ≥1 mapped test ÷ total.
- **Acceptance Criteria Coverage** — ACs with ≥1 mapped test ÷ total.
- **Test Coverage** — behaviors covered per AC (happy vs negative vs boundary).
- **Execution Coverage** — mapped tests executed ÷ mapped tests, with results.
- **Automation Coverage** — covered behaviors that are automated.
- **Regression Coverage** — coverage attributable to the regression suite.
- **High-Risk Coverage** — coverage of the requirements flagged high-risk.

## Gap Analysis

Identify, each traced to evidence:

- Untested requirements (no mapped test)
- Thin coverage (happy path only)
- Partial coverage (some ACs/behaviors uncovered)
- Executed-but-failing coverage (mapped tests that failed)
- Orphan tests (map to no requirement)
- Duplicate tests (multiple tests covering the same behavior)
- Unmapped requirements and unmapped tests
- Outdated tests — only when evidence (e.g., stale references) supports it

## Risk Assessment

Rank gaps by business impact rather than count, weighing criticality, execution
status (failing > untested > thin), customer impact, and stated risk level. Surface
the riskiest untested or failing areas at the top.

## Coverage Quality Validation

Before output, confirm:

- Every requirement/AC has been evaluated.
- Every mapped relationship is evidence-backed; no fabricated mappings exist.
- Untested requirements are identified.
- Orphan and duplicate tests are identified.
- Execution status is considered (failing tests are not counted as coverage).

## Confidence Level

State a **Confidence Level** based on artifact completeness and mapping confidence,
not on the size of the matrix:

- **High** — complete requirements and tests; mappings and execution results are clear.
- **Medium** — partial artifacts; some mappings uncertain.
- **Low** — sparse artifacts; many items unmapped or execution status unknown.

## Clarification Questions

When essential artifacts are missing, generate concise questions — one topic each,
answerable, addressed to the QA lead — rather than inventing mappings.

## Output

Present the analysis as modular sections (only those relevant to the scope):

1. **Executive Summary**
2. **Evidence Reviewed**
3. **Coverage Metrics** — by coverage type, with denominators
4. **Traceability Matrix**
5. **Coverage Assessment**
6. **Gap Analysis**
7. **Risk Assessment** — gaps ranked by business impact
8. **Orphan Tests**
9. **Clarification Questions**
10. **Recommendations**
11. **Human Review Gate**

Illustrative shape:

```
## Coverage Analysis — <feature / release>
| Requirement / AC | Tests             | Execution     | Status   | Gap                  |
| AC-1             | TC-1, TC-2        | passed        | covered  | -                    |
| AC-2             | TC-4 (happy only) | passed        | thin     | no negative/boundary |
| AC-3             | -                 | -             | UNTESTED | high risk            |
Orphan tests (map to no requirement): [ ... ]
Top gaps by risk: 1) AC-3  2) ...
```

## Human Review Gate

Mandatory before the analysis informs a release decision. Present it as a draft and
clearly separate:

- **Facts** — verifiable from the supplied artifacts and execution results.
- **Observations** — analysis derived from those facts.
- **Assumptions** — inferences made where a mapping or result was absent.
- **Unknowns** — what could not be mapped or confirmed.

Require the QA lead to confirm before the analysis informs release sign-off. Do not
proceed on unconfirmed assumptions.

## Guardrails

The skill must never:

- Assume coverage exists without a test to point to — an unmapped requirement is a gap, not a pass.
- Invent requirements, ACs, test IDs, mappings, execution results, or coverage to complete the matrix.
- Treat a failing (or unexecuted) test as successful coverage — distinguish "covered" from "covered and passing".
- Let unsupported assumptions influence a release decision, or overstate confidence beyond the evidence.

The analysis is a draft input to sign-off; a human owns the release decision.

## Writing Style

Concise, professional, and enterprise-grade. Avoid repetition. Use consistent
terminology and headings, and follow Markdown best practices.

