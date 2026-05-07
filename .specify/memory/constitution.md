<!--
Sync Impact Report
Version change: template -> 1.0.0
Modified principles:
- Template Principle 1 -> I. Public API Stability (NON-NEGOTIABLE)
- Template Principle 2 -> II. Single Consistent API
- Template Principle 3 -> III. Test-First & Golden Tests (NON-NEGOTIABLE)
- Template Principle 4 -> IV. Async Safety
- Template Principle 5 -> V. Theming & Accessibility
Added sections:
- Package Quality Gates
- Development Workflow & Review Process
Removed sections:
- None
Templates requiring updates:
- ✅ .specify/templates/plan-template.md
- ✅ .specify/templates/spec-template.md
- ✅ .specify/templates/tasks-template.md
- ✅ .specify/templates/checklist-template.md
- ✅ .specify/templates/commands/*.md (not present in this repository)
Runtime guidance docs:
- ✅ README.md (reviewed; already aligned)
- ✅ AGENTS.md (reviewed; no principle references required updating)
Follow-up TODOs:
- None
-->
# Dropify Flutter Constitution

## Core Principles

### I. Public API Stability (NON-NEGOTIABLE)
All public-facing widgets, entry models, theme objects, form fields, exported
types, constructor parameters, enum values, and documented behaviors MUST follow
semantic versioning. Any breaking change MUST ship with a MAJOR version bump, a
migration guide, and a deprecation period of at least one MINOR release before
removal. Deprecations MUST include a replacement path and tests that preserve
the supported behavior during the deprecation window.

Rationale: Dropify Flutter is a pub.dev package; downstream applications depend
on stable imports, stable types, and predictable upgrade costs.

### II. Single Consistent API
All dropdown variants, including static, async, paginated, form, theming, and raw
overlay entry points, MUST share one interaction model. Selection identity MUST
be value-based across variants. The theming surface MUST be `DropifyTheme` and
`DropifyThemeData`. Public consumers MUST be able to use the package through the
single import entry point `package:dropify_flutter/dropify_flutter.dart`.

Rationale: A universal dropdown package earns its value by letting consumers
change data sources or presentation modes without relearning selection,
theming, imports, or form integration.

### III. Test-First & Golden Tests (NON-NEGOTIABLE)
Every new widget, public behavior change, bug fix, accessibility behavior, and
async state transition MUST be covered by widget tests before implementation is
merged. Visual behavior that can regress MUST be covered by golden tests.
Development MUST follow Red-Green-Refactor: write or update a failing test,
make the smallest correct implementation pass, then refactor while keeping the
suite green.

Rationale: Dropdown behavior is interaction-heavy and visual; tests are the
primary guardrail against regressions in selection, overlays, focus, async
loading, theming, and form behavior.

### IV. Async Safety
`DropifyAsyncDropdown` and `DropifyPaginatedDropdown` MUST implement debounce,
stale-response protection, retry states, empty states, loading states, error
states, and pagination footer states. Async state changes MUST be deterministic
under rapid typing, retries, disposal, page changes, and overlapping requests.
Race conditions, stale result rendering, duplicate page appends, and state
updates after disposal are unacceptable.

Rationale: Async dropdowns are exposed to slow networks and fast user input; the
package must protect application UI from inconsistent or unsafe request ordering.

### V. Theming & Accessibility
All widgets MUST inherit from `DropifyTheme` and respect Material theme tokens
through `DropifyThemeData.fromMaterial(context)`. Theme overrides MUST compose
predictably with Material defaults instead of replacing them wholesale. Widgets
MUST expose semantic labels, preserve readable focus and hover states, support
keyboard navigation, and remain usable with screen readers and Flutter
accessibility tooling.

Rationale: Dropify must feel native inside Material applications while remaining
usable for keyboard and assistive-technology users.

## Package Quality Gates

- `dart format` (dartfmt) MUST produce no formatting diff before merge.
- `dart analyze` MUST pass with zero issues before merge.
- Widget tests and golden tests required by this constitution MUST pass before
  merge.
- The example app MUST compile and demo all six dropdown variants: static,
  async, paginated, form, theming, and raw.
- Pub.dev package quality target is 130+ points. Health and Maintenance MUST
  remain at 100% whenever package scoring is available.
- Public documentation, examples, and exported API comments MUST stay aligned
  with the single import entry point and the supported variant set.

## Development Workflow & Review Process

All feature specifications, implementation plans, and task lists MUST identify
the relevant constitutional principles and include explicit verification tasks.
Plans that touch public API MUST document whether the change is additive,
deprecating, or breaking. Specs that touch async behavior MUST define stale
response, retry, loading, empty, error, and pagination scenarios where applicable.
Tasks for UI behavior MUST include widget tests and golden tests before
implementation tasks.

Every pull request MUST reference the relevant principle numbers, include proof
that `dart format` (dartfmt), `dart analyze`, widget tests, golden tests, and
the example app compile gate passed, and update user-facing documentation when
public API or behavior changes. Any exception requires an explicit rationale in
the PR and cannot waive NON-NEGOTIABLE principles.

## Governance

This constitution supersedes all other project practices. Amendments require a
pull request with a rationale comment, a semantic version bump to this
constitution, and an updated `CHANGELOG.md` entry. All PRs MUST reference the
relevant constitutional principle or state that the change is constitutionally
neutral.

Constitution versioning follows semantic versioning:

- MAJOR: Removes a principle, weakens a NON-NEGOTIABLE rule, or redefines
  governance in a backward-incompatible way.
- MINOR: Adds a principle or materially expands required guidance, checks, or
  sections.
- PATCH: Clarifies wording, fixes typos, or makes non-semantic refinements.

Compliance review is mandatory during planning and before merge. Reviewers MUST
block changes that violate NON-NEGOTIABLE principles, omit required tests, break
the single API model, introduce unsafe async behavior, bypass theming or
accessibility requirements, or fail package quality gates.

**Version**: 1.0.0 | **Ratified**: 2026-04-26 | **Last Amended**: 2026-04-26
