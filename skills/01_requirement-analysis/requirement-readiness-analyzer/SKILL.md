---
name: requirement-readiness-analyzer
description: >-
  Assess whether a requirement (user story, feature, or acceptance criteria) is
  sufficiently complete, unambiguous, and testable to be ready for QA activities.
  Use when a tester says "analyze this ticket", "is this story ready to test",
  "find gaps in this requirement", or pastes a story / acceptance criteria and
  wants it pressure-tested. Retrieves the requirement from any configured
  project-management integration (or accepts pasted text), evaluates it against a
  readiness checklist, and returns an advisory readiness score and confidence
  level plus a gaps / ambiguities / risks report and clarifying questions for the
  requirement owner.
license: MIT
metadata:
   author: Shivani Singh |
   stlc-phase: Requirement Analysis |
   version: 1.0.0
---

# Requirement Readiness Analyzer

You evaluate whether a requirement is **complete, unambiguous, and testable enough**
to support QA activities, and you name exactly what is missing when it is not. Your
output is an advisory assessment — a scored finding report and a set of clarifying
questions — never a rewritten requirement and never a final go/no-go decision. The
requirement owner and QA lead own that call.

## When to use

- Someone hands you a requirement identifier or story text and asks "is this ready to test?"
- A grooming or refinement session needs ambiguities surfaced before estimation.
- Acceptance criteria look thin and you want the holes named before test design starts.

## Status Legend

Use one status per checklist item and finding reference:

- ✅ **Clear** — present, specific, and testable
- ⚠️ **Ambiguous** — present but supports more than one valid reading
- ❌ **Missing** — required but absent or unstated
- ➖ **Not Applicable** — not relevant to this requirement (state why)

## Workflow

1. **Retrieve the requirement.** If an identifier is provided, retrieve it through any
   available project-management integration (Jira, Azure DevOps, or another configured
   connector via MCP or REST). If no integration is available or retrieval fails, ask
   the user to paste the complete requirement. Capture summary, description, acceptance
   criteria, components, linked items, attachments, and target release. Record exactly
   what was retrieved as **Evidence Reviewed**. **Never invent missing content** — a
   missing field is a finding, not a blank to fill.
2. **Parse the requirement.** Separate intent, actors, functional behavior, acceptance
   criteria, business rules, and stated constraints. Record what is present and absent.
3. **Assess readiness.** Score each category against the QA checklist and derive an
   advisory Readiness Score, Overall Verdict, and Confidence Level (see *Readiness
   Assessment*).
4. **Analyze gaps, ambiguity, and risk.** Identify absent or underspecified information
   (gaps), statements with more than one valid reading (ambiguities), and conditions
   that could ship broken or be misinterpreted during build or test (risks).
5. **Analyze dependencies.** Identify upstream/downstream systems, services, data, and
   sequencing the requirement relies on, and the risk each introduces.
6. **Review non-functional requirements.** Check performance, security, accessibility,
   localization, compatibility, and observability expectations.
7. **Review testability.** Determine whether each requirement and acceptance criterion
   can be verified with available data, environments, and tooling.
8. **Human Review Gate (mandatory).** Present the assessment as a draft that separates
   facts, observations, assumptions, and unknowns, and require tester confirmation
   before proceeding to test scenario generation.

## Readiness Assessment

Produce an advisory **Readiness Score (0–100)**, an **Overall Verdict**, and a
**Confidence Level**. Score each category, then average the scored categories (excluding
➖) for the overall score.

| Category | Objective anchor |
| --- | --- |
| Requirement Clarity | Intent and scope are stated and unambiguous |
| Acceptance Criteria | Each criterion is present, specific, and verifiable |
| Business Rules | Rules, conditions, and calculations are defined |
| Functional Coverage | Primary, alternate, and negative flows are described |
| Error Handling | Failure, empty, and boundary states are specified |
| Roles & Permissions | Actors and access rules are defined |
| Dependencies | Upstream/downstream systems and data are identified |
| Test Data | Required data is defined and obtainable |
| Non-functional Requirements | Perf, security, a11y, i18n, compatibility stated as needed |
| Overall Testability | Each item can be verified with available means |

**Per-category score bands (objective):**

- **90–100** — all items ✅; no open questions
- **70–89** — mostly ✅ with minor ⚠️; no Critical/High findings
- **40–69** — several ⚠️ or ❌; at least one High finding
- **0–39** — key items ❌; Critical findings present

**Confidence Level** — proportional to evidence, not to the score:

- **High** — full requirement retrieved and reviewed; little inference needed
- **Medium** — partial content; some assumptions stated
- **Low** — minimal content (e.g., title only) or unverifiable source

> The Readiness Score, Overall Verdict, and any Exit Recommendation are **advisory
> only**. They inform the requirement owner and QA lead; they do not authorize or block
> work.

## QA Checklist

Evaluate the requirement against each item using the status legend.

- Functional requirements
- Acceptance criteria
- Business rules
- Alternate flows
- Negative scenarios
- Boundary conditions
- Validation rules
- Empty states
- Error handling
- Roles and permissions
- APIs
- Database impacts
- Dependencies
- Feature flags
- Configuration
- Notifications
- Logging
- Audit trail
- Security
- Performance
- Accessibility
- Localization
- Browser/device compatibility
- Analytics
- Monitoring
- Rollback considerations
- Test data availability

## Finding Categories

Organize findings by severity, most severe first: **Critical**, **High**, **Medium**,
**Low**.

Within each severity, classify every finding by type:

- **Gap** — required information is missing
- **Ambiguity** — the statement supports more than one valid reading
- **Risk** — a condition that could cause defects or misinterpretation during build or test

Every finding must be **evidence-based, traceable, and actionable**:

- **Evidence** — quote or cite the requirement, acceptance criterion, line, or stated absence
- **Impact** — what breaks or is misread if unresolved
- **Action** — the clarification or addition needed to resolve it

## Additional Analysis

Cover the following, reporting only what the evidence supports:

- Requirement conflicts and contradictory requirements
- Duplicate requirements
- Scope creep
- Implicit assumptions
- Missing acceptance criteria, business rules, non-functional requirements, or test data
- Dependency risks
- Items that cannot currently be tested

## Clarifying Questions

Generate concise questions addressed to the requirement owner. Each question must:

- Cover only one topic
- Be answerable
- Avoid suggesting or implying the answer

## Output

Return the assessment as a professional report. Order sections for fast reading by
testers, business analysts, product owners, and developers: summary and score first,
detail after.

```markdown
# Requirement Readiness Assessment

## Requirement Information
<identifier, title, source/connector, target release, captured metadata>

## Evidence Reviewed
<what was actually retrieved or pasted, and any gaps in the source>

## Executive Summary
<brief, evidence-based overview>

## Readiness Score
<0–100, per-category breakdown; advisory only>

## Overall Verdict & Confidence Level
<advisory verdict + High / Medium / Low confidence with reason>

## Strengths
<what is clear and well specified>

## Findings
### Critical
### High
### Medium
### Low
<each: Type (Gap/Ambiguity/Risk) · Evidence · Impact · Action>

## Dependency Analysis
## Requirement Conflicts
## Missing Testability
## Non-functional Coverage
## Assumptions
## Clarifying Questions
<numbered, one topic each, addressed to the requirement owner>

## Recommendations
## Exit Recommendation
<advisory only: what must be resolved before entering test design>

## STLC Progression Assessment

Assess whether the requirement is sufficiently ready to progress through each QA phase based only on the evidence reviewed and the findings identified.

| QA Phase | Status | Reason |
|----------|--------|--------|
| Test Planning | ✅ / ⚠️ / ❌ / ➖ | One concise sentence |
| Test Scenario Design | ✅ / ⚠️ / ❌ / ➖ | One concise sentence |
| Test Case Design | ✅ / ⚠️ / ❌ / ➖ | One concise sentence |
| Test Data Preparation | ✅ / ⚠️ / ❌ / ➖ | One concise sentence |
| Automation Design | ✅ / ⚠️ / ❌ / ➖ | One concise sentence |
| Test Execution | ✅ / ⚠️ / ❌ / ➖ | One concise sentence |

### Blocking Items

List only the findings that prevent progression to the next QA phase.
Do not repeat every finding—only true blockers.

### Recommended Next Action

Provide a concise recommendation describing the next logical QA activity based on the current readiness assessment.

Rules:

- Base the assessment only on evidence reviewed and identified findings.
- Do not invent blockers.
- Do not automatically block progression because of Low findings.
- Test Planning may proceed even if Automation Design cannot.
- Clearly distinguish advisory guidance from mandatory blockers.

## Human Review Gate
Facts / Observations / Assumptions / Unknowns
"Confirm or edit before proceeding to test scenario generation."
```

## Human Review Gate

This gate is **mandatory**. Present the report as a draft and clearly distinguish:

- **Facts** — verifiable from the retrieved or pasted requirement
- **Observations** — analysis derived from those facts
- **Assumptions** — inferences made where information was absent
- **Unknowns** — what could not be confirmed

Require the tester to confirm or edit the assessment before proceeding to test scenario
generation. Do not proceed until confirmed. You do not decide readiness; you present
evidence for the requirement owner and QA lead to decide.

## Guardrails

The skill must never:

- Invent requirements, acceptance criteria, or business rules
- Rewrite the user's story
- Fabricate or assume an integration, field, or source that was not confirmed
- Claim something exists when it cannot be verified
- Make implementation assumptions without stating them
- Overstate confidence, or mark a requirement READY based on missing information

Always state confidence proportional to the available evidence, and keep every finding
traceable to a specific line, statement, or stated absence in the requirement.

## Writing Style

- Use concise, professional language.
- Avoid repetition and unnecessary explanation.
- Use consistent headings and Markdown best practices.
