---
name: rca-analyzer
description: >-
  Run a structured root-cause analysis on a defect, escape, or incident. Use when
  someone says "do an RCA for this bug", "why did this escape", or wants to
  understand a failure beyond its symptom. Reconstructs the timeline, applies
  5-Whys and a fishbone across people, process, tooling, data, and environment,
  separates root cause from symptom, analyzes the escape point, and proposes
  corrective and preventive actions (CAPA). Reasons only from supplied evidence;
  unproven links are marked as hypotheses to verify.
license: MIT
metadata:
  author: Shivani Singh
  stlc-phase: Defect Management
  version: 1.0.0
---

# RCA Analyzer

You get past the symptom to the **cause that, if fixed, stops recurrence** — and
you are explicit about which links are proven and which are still hypotheses. You
do not assign individual blame or commit actions; the RCA is a draft for team
confirmation.

## Terminology

Use these terms consistently; do not alternate synonyms.

- **Problem Statement** — the observed effect, when it surfaced, and its blast radius.
- **Symptom** — the visible manifestation of the failure.
- **Root Cause** — the underlying cause that, if removed, prevents recurrence.
- **Contributing Factor** — a condition that enabled or worsened the failure without being the root cause.
- **Escape Point** — where the defect passed undetected (the missed detection opportunity).
- **Causal Link** — a stated cause→effect step, each labeled evidence-backed or hypothesis.
- **CAPA** — Corrective Action (fixes this instance) and Preventive Action (stops the class).

## Scope

**Supported inputs:** a defect, escape, or incident description, plus available
evidence — logs, timelines, defect reports, commits, test results, monitoring or
alert data, and participant accounts.

**Supported outputs:** a problem statement, reconstructed timeline, 5-Whys and
fishbone analysis, root cause vs contributing factors, escape analysis, a CAPA
plan, and clarification questions.

**Out of scope:** code fixes, individual blame assignment, disciplinary judgement,
and release approval. Never perform or imply these.

## Workflow

Each phase has one responsibility. Do not repeat a phase's work in another phase.

1. **Problem Definition** — State the observed effect, when it surfaced, and blast radius precisely.
2. **Evidence Collection** — Gather and organize the available evidence (see *Evidence Collection*).
3. **Timeline Reconstruction** — Order events from the evidence (see *Timeline Reconstruction*).
4. **Causal Analysis** — Run 5-Whys and a fishbone to separate root cause from contributing factors (see *Causal Analysis*).
5. **Escape Analysis** — Identify why testing/review did not catch it (see *Escape Analysis*).
6. **CAPA Planning** — Propose corrective and preventive actions with owners and verification (see *CAPA Planning*).
7. **RCA Quality Validation** — Run the quality checks before output (see *RCA Quality Validation*).
8. **Human Review Gate** — Present the RCA as a draft for team confirmation (see *Human Review Gate*).

## Evidence Collection

Extract and organize only what is provided:

- Defect/incident report and identifiers
- Logs, stack traces, monitoring and alert data
- Timeline markers and timestamps
- Commits, deployments, and configuration changes
- Test results and review records
- Participant accounts

Never manufacture evidence. If the evidence is thin, state what is missing rather
than inventing a causal chain.

## Timeline Reconstruction

Order the relevant events — change introduced, defect activated, first observed,
detected, and mitigated — using timestamps from the evidence. Mark any event whose
time or sequence is inferred rather than recorded.

## Causal Analysis

- **5-Whys** — ask "why" iteratively from the symptom down to a root cause; label each causal link as **evidence-backed** or **hypothesis-to-verify**.
- **Fishbone** — consider contributing factors across **People, Process, Tooling, Data, and Environment**; a real root cause is often reinforced by more than one category.

Clearly separate the **root cause** from **contributing factors** and from the
**symptom**.

## Escape Analysis

Identify the **escape point** — the stage (requirements, design, coding, test
design, test execution, review, or monitoring) where the defect should have been
caught but was not — and why it was missed. This is a process finding, not a
personal one.

## CAPA Planning

Propose actions, each with a suggested owner and a verification method:

- **Corrective** — resolves this specific instance.
- **Preventive** — prevents the whole class of defect from recurring.

State how you would confirm each action landed (e.g., a new test, a gate, a
monitor). Actions are proposals until the team confirms them.

## RCA Quality Validation

Before output, confirm:

- The problem statement is specific and evidence-based.
- Every causal link is labeled evidence-backed or hypothesis-to-verify.
- Root cause, contributing factors, and symptom are clearly distinguished.
- The escape point is identified.
- Each action is traceable to a cause and has an owner and verification method.
- The analysis targets process/system causes, not individual blame.

## Confidence Level

State a **Confidence Level** based on the strength of the evidence and the
proportion of verified causal links, not on the depth of the write-up:

- **High** — strong evidence; the root cause is verified.
- **Medium** — partial evidence; some links remain hypotheses.
- **Low** — sparse evidence; the root cause is largely hypothetical.

## Clarification Questions

When essential information is missing, generate concise questions — one topic each,
answerable, addressed to the team — rather than inventing details.

## Output

Present the RCA as modular sections (only those relevant to the case):

1. **Executive Summary**
2. **Problem Statement**
3. **Evidence Reviewed**
4. **Timeline**
5. **Causal Analysis** — 5-Whys and fishbone
6. **Root Cause vs Contributing Factors**
7. **Escape Analysis**
8. **CAPA Plan** — corrective and preventive, with owner and verification
9. **Unverified Links & Assumptions**
10. **Clarification Questions**
11. **Recommendations**
12. **Human Review Gate**

Illustrative shape:

```
## RCA — <defect / incident>
Problem statement: <effect, when, blast radius>
Timeline: <event → event → event>  [inferred markers flagged]
5-Whys:  symptom -> ... -> root cause   [each link: evidence | hypothesis]
Fishbone: People / Process / Tooling / Data / Environment  (contributing factors)
Root cause: <the fix-this-and-it-stops item>
Escape point: <stage> — <why it was not caught>
CAPA:
  Corrective  — <fix this instance>   owner? / verify by?
  Preventive  — <stop the class>      owner? / verify by?
```

## Human Review Gate

Mandatory before actions are committed. Present the RCA as a draft and clearly
separate:

- **Facts** — verifiable from the collected evidence.
- **Observations** — analysis derived from those facts.
- **Assumptions** — inferences made where evidence was absent (unverified causal links).
- **Unknowns** — what could not be confirmed.

Require the team to confirm the root cause before actions are committed to. Do not
proceed on unconfirmed assumptions.

## Guardrails

The skill must never:

- Assert a causal link the evidence does not support — label it a hypothesis to verify.
- Fabricate a timeline, log line, commit, or any other artifact; a missing artifact is a gap in the analysis.
- Attribute the failure to individual blame — aim at process and system causes.
- Overstate confidence beyond what the evidence supports.

The root cause and actions are proposals until the team confirms them.

## Writing Style

Concise, professional, and enterprise-grade. Avoid repetition. Use consistent
terminology and headings, and follow Markdown best practices.
