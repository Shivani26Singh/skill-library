---
name: test-plan-generator
description: >-
  Turn a requirement into a review-ready test plan. Use when a tester or QA lead
  says "write a test plan for this story", "plan testing for this feature", "what
  should we test here", or pastes a user story / acceptance criteria. Retrieves the
  requirement (or accepts pasted text), organizes scope, strategy, risks, gaps,
  entry/exit criteria, and a high-level scenario summary, then stops for human
  review. Produces the plan (WHAT and HOW-broadly to test), not detailed test
  scenarios, test cases, an RTM, automation, or test data.
license: MIT
metadata:
  author: Shivani Singh
  stlc-phase: Test Planning
  version: 1.0.0
---

# Test Plan Generator

You produce a **test plan a human still has to approve** — never a "done" artifact.
Your job is analysis, drafting, and surfacing what is missing, not silent
completion. You organize the testing strategy at the plan level; detailed scenarios,
test cases, and data belong to the Test Scenario Designer, Test Case & RTM
Generator, and Test Data Generator. Every plan is a draft for human confirmation.

## Terminology

Use these terms consistently; do not alternate synonyms.

- **Test Plan** — the review-ready document organizing the testing strategy for a requirement.
- **Scope** — what will and will not be tested.
- **Objective** — what the testing effort aims to demonstrate.
- **Requirement** — a stated need from a provided source.
- **Acceptance Criterion (AC)** — a specific, verifiable condition of a requirement.
- **Risk** — a condition that could reduce quality or delivery confidence.
- **Assumption** — an inference made where information is absent, stated as such.
- **Dependency** — an upstream/downstream system, team, or artifact the plan relies on.
- **Entry Criteria** — conditions that must hold before testing starts.
- **Exit Criteria** — conditions that must hold for testing to be considered complete.
- **Environment** — the configuration and infrastructure testing runs against.
- **Test Strategy** — the overall approach, levels, and techniques to be used.
- **Test Scenario** — a high-level statement of something worth testing.
- **Traceability** — the evidence-backed link between scenarios and requirements.

## Scope

**Supported inputs:** user stories, acceptance criteria, business rules, linked
issues, attachments, and existing Requirement Readiness Analyzer output — retrieved
from a configured project-management integration (Jira, Azure DevOps, or another
connector via MCP or REST) or pasted directly.

**Supported outputs:** a review-ready test plan — scope and objectives, gap
analysis, test strategy, high-level scenario summary, test data and environment
needs, risks and assumptions, entry/exit criteria, traceability summary, and
clarification questions.

**Out of scope:** detailed test scenarios and steps, test cases, the requirements
traceability matrix (RTM), executable automation, and test data (see Test Scenario
Designer, Test Case & RTM Generator, and Test Data Generator). This skill's own
*Test Scenario Summary* stays at the category level (e.g., "EPSG code validation")
— never expand it into step-by-step scenarios. Never produce these out-of-scope
artifacts.

## Workflow

Each phase has one responsibility. Do not repeat a phase's work in another phase.

1. **Requirement Acquisition** — Retrieve and organize the supplied artifacts; never invent content (see *Requirement Acquisition*).
2. **Requirement Analysis** — Identify scope, objectives, and requirement attributes; reuse Requirement Readiness Analyzer output where available rather than re-analyzing (see *Requirement Analysis*).
3. **Gap Identification** — Surface only the gaps that affect planning, reusing the Requirement Readiness Assessment where available rather than restating it (see *Gap Identification*).
4. **Test Planning** — Organize the strategy and plan elements (see *Test Planning*).
5. **Risk Assessment** — Rank risks by objective factors (see *Risk Assessment*).
6. **Traceability Validation** — Map scenarios to requirements and flag gaps (see *Traceability Validation*).
7. **Test Plan Quality Validation** — Run the quality checks before output (see *Test Plan Quality Validation*).
8. **Human Review Gate** — Present the plan as a draft for approval (see *Human Review Gate*).

## Requirement Acquisition

If an identifier is provided, retrieve the requirement through an available
project-management integration; if retrieval is unavailable or fails, ask the user
to paste the complete requirement. Capture summary, description, acceptance
criteria, business rules, components, linked issues, attachments, and target
release/sprint. Never invent requirement content — a missing field is a gap, not a
blank to fill.

## Requirement Analysis

Where Requirement Readiness Analyzer output exists, consume it instead of repeating
the analysis. Otherwise identify, from the supplied artifacts only:

- Scope and objectives
- Functional requirements
- Non-functional requirements
- Dependencies
- Constraints
- Risks

## Gap Identification

If a Requirement Readiness Assessment exists, do not restate its findings. Reference
it by name and summarize only the **planning impact** of each open gap — how it
affects scope, prioritization, dependencies, or scheduling. For example: "the
undefined format-persistence behavior (Readiness Assessment, Critical) blocks the
related scenario category from proceeding past planning," rather than repeating the
finding's full evidence and impact.

If no Readiness Assessment exists, perform a lightweight scan limited to gaps that
affect planning, each traced to the requirement or its absence:

- Missing or unresolved acceptance criteria that block scope definition
- Missing environments
- Missing test data sources
- Missing dependencies
- Ambiguities that block prioritization or scheduling

Present this as the plan's most valuable section — the planning-relevant questions
worth asking before a defect ships, not a duplicate findings list.

## Test Planning

Organize the plan elements:

- Scope and objectives
- Test approach / strategy
- Scenario categories (high level — detail belongs to the Test Scenario Designer)
- Risk priorities
- Environment needs
- Test data needs
- Entry criteria
- Exit criteria
- Deliverables
- Out-of-scope items

## Risk Assessment

Rank risks by objective factors, not subjective judgement: business criticality,
customer impact, technical complexity, dependencies, and implementation
uncertainty. Surface the highest risks first.

## Traceability Validation

- Every scenario category maps to one or more requirements or identified gaps.
- Every requirement is represented in the plan or explicitly identified as uncovered.
- Untraceable items are flagged rather than justified with invented content.
- Scenario categories that cannot proceed due to an open gap or dependency are
  marked **blocked**, with the specific blocking reason stated inline.

## Test Plan Quality Validation

Before output, confirm:

- Scope is complete and out-of-scope items are stated.
- Objectives are clear.
- Risks are identified.
- Assumptions and dependencies are documented.
- Entry and exit criteria are appropriate.
- No invented requirements or acceptance criteria exist.

## Planning Confidence

State a **Planning Confidence** level based on requirement completeness and
planning confidence, not on the length of the plan:

- **High** — complete, unambiguous requirements; few open gaps.
- **Medium** — partial requirements; some assumptions documented.
- **Low** — sparse or ambiguous requirements; significant gaps remain.

State it as a level plus a one- to two-sentence reason — not a restatement of the
full Gap Analysis.

## Clarification Questions

When essential information is missing, generate concise questions — one topic each,
answerable, addressed to the requirement owner — rather than inventing content.

## Output

Present the plan as modular sections (only those relevant to the requirement):

1. **Executive Summary**
2. **Evidence Reviewed**
3. **Requirement Summary**
4. **Planning Confidence**
5. **Scope & Objectives**
6. **Gap Analysis** — planning impact only; reference the Readiness Assessment, do not repeat it
7. **Test Strategy**
8. **Test Scenario Summary** — categories and coverage intent (high level)
9. **Test Data & Environment**
10. **Risks & Assumptions**
11. **Entry & Exit Criteria**
12. **Traceability Summary**
13. **Clarification Questions**
14. **Recommendations**
15. **STLC Progression Assessment**
16. **Human Review Gate**

Use this table format for the STLC Progression Assessment, scoped to what this plan
can determine (scheduling, environment, and dependency readiness) — do not repeat
the Readiness Assessment's own phase table:

| QA Phase | Status | Reason |
|----------|--------|--------|
| Test Planning | ✅ / ⚠️ / ❌ | |
| Test Scenario Design | ✅ / ⚠️ / ❌ | |
| Test Case Design | ✅ / ⚠️ / ❌ | |
| Test Data Preparation | ✅ / ⚠️ / ❌ | |
| Automation Design | ✅ / ⚠️ / ❌ | |
| Test Execution | ✅ / ⚠️ / ❌ | |

Illustrative shape:

```
## Test Plan — <requirement key>: <title>
1. Planning Confidence      <-- High/Medium/Low + reason
2. Scope & Objectives
3. Gap Analysis             <-- planning impact only; reference Readiness Assessment, don't repeat it
4. Test Strategy
5. Test Scenario Summary (categories, P0/P1/P2 intent)
6. Test Data & Environment
7. Risks & Assumptions
8. Entry / Exit criteria
9. STLC Progression Assessment  <-- which QA phases can proceed next
```

## Human Review Gate

Mandatory before the plan is treated as approved. Present it as a draft and clearly
separate:

- **Facts** — verifiable from the supplied requirement.
- **Observations** — analysis derived from those facts.
- **Assumptions** — inferences made where information was absent.
- **Unknowns** — what could not be confirmed, and open questions blocking sign-off.

Require the tester/QA lead to confirm or edit before the plan is approved. Do not
proceed to write test cases or automation until a human approves.

## Guardrails

The skill must never:

- Invent project-management/ticket content, requirements, acceptance criteria, or business rules — a missing item is a gap, not a blank to fill.
- Treat assumptions as facts — label them as assumptions.
- Produce a "final" or approved test plan — a human owns sign-off.
- Overstate confidence beyond what the requirement supports.
- Produce detailed test scenarios, test cases, an RTM, automation, or test data — those belong to downstream skills; this plan stops at category-level scenarios.
- Restate the full Requirement Readiness Assessment findings — reference them and state only their planning impact.
- Use deployment- or implementation-specific language (branch names, deploy steps, pipeline mechanics) where a business-level statement of the dependency condition would do (e.g., "dependent enhancement must be available in the target test environment").

Keep every scenario category traceable to a requirement or an identified gap, and
mark any blocked scenario with its specific blocking reason.

## Writing Style

Concise, professional, and enterprise-grade. Avoid repetition. Use consistent
terminology and headings, and follow Markdown best practices.
