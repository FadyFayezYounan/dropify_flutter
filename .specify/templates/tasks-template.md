---

description: "Task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Tests are mandatory for Dropify Flutter. Every widget or behavior
change MUST include widget tests before implementation. Visual behavior that can
regress MUST include golden tests before implementation.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Package source**: `lib/`, `lib/src/`, and public exports in `lib/dropify_flutter.dart`
- **Tests**: `test/` and `test/goldens/`
- **Example app**: `example/`
- Paths shown below assume this Flutter package layout - adjust based on plan.md structure

<!-- 
  ============================================================================
  IMPORTANT: The tasks below are SAMPLE TASKS for illustration purposes only.
  
  The /speckit-tasks command MUST replace these with actual tasks based on:
  - User stories from spec.md (with their priorities P1, P2, P3...)
  - Feature requirements from plan.md
  - Entities from data-model.md
  - Public API, widget behavior, and async contracts from plan.md
  
  Tasks MUST be organized by user story so each story can be:
  - Implemented independently
  - Tested independently
  - Delivered as an MVP increment
  
  DO NOT keep these sample tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create project structure per implementation plan
- [ ] T002 Initialize [language] project with [framework] dependencies
- [ ] T003 [P] Configure linting, formatting, widget test, and golden test tools

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

Examples of foundational tasks (adjust based on your project):

- [ ] T004 Establish shared widget test harness and Material app wrapper
- [ ] T005 [P] Configure golden test baselines and tolerances
- [ ] T006 [P] Create fake async fetchers for debounce, retry, stale-response, and pagination tests
- [ ] T007 Create base models, controllers, or theme fixtures that all stories depend on
- [ ] T008 Configure error, empty, loading, and retry state test helpers
- [ ] T009 Confirm public API export policy through `lib/dropify_flutter.dart`
- [ ] T010 Establish public API export surface through `lib/dropify_flutter.dart`
- [ ] T011 Configure shared `DropifyTheme` / `DropifyThemeData` test fixtures

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - [Title] (Priority: P1) 🎯 MVP

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 1 (MANDATORY - write before implementation)

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T012 [P] [US1] Widget test for [behavior] in test/[feature]_test.dart
- [ ] T013 [P] [US1] Golden test for [visual state] in test/goldens/[feature]_golden_test.dart
- [ ] T014 [P] [US1] Accessibility and keyboard navigation test in test/[feature]_a11y_test.dart

### Implementation for User Story 1

- [ ] T015 [P] [US1] Create [Entity1] model in lib/src/[area]/[entity1].dart
- [ ] T016 [P] [US1] Create [Entity2] model in lib/src/[area]/[entity2].dart
- [ ] T017 [US1] Implement [Widget/API] in lib/src/[area]/[feature].dart (depends on T015, T016)
- [ ] T018 [US1] Export public API through lib/dropify_flutter.dart when required
- [ ] T019 [US1] Add validation and error handling
- [ ] T020 [US1] Update example app demo for this behavior

**Checkpoint**: At this point, User Story 1 MUST be fully functional and testable independently

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 2 (MANDATORY - write before implementation)

- [ ] T021 [P] [US2] Widget test for [behavior] in test/[feature]_test.dart
- [ ] T022 [P] [US2] Golden test for [visual state] in test/goldens/[feature]_golden_test.dart
- [ ] T023 [P] [US2] Async safety test for debounce, stale responses, retry, or pagination in test/[feature]_async_test.dart

### Implementation for User Story 2

- [ ] T024 [P] [US2] Create [Entity] model in lib/src/[area]/[entity].dart
- [ ] T025 [US2] Implement [Widget/API] in lib/src/[area]/[feature].dart
- [ ] T026 [US2] Preserve value-based selection identity and shared theming
- [ ] T027 [US2] Integrate with User Story 1 components (if needed)

**Checkpoint**: At this point, User Stories 1 AND 2 MUST both work independently

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 3 (MANDATORY - write before implementation)

- [ ] T028 [P] [US3] Widget test for [behavior] in test/[feature]_test.dart
- [ ] T029 [P] [US3] Golden test for [visual state] in test/goldens/[feature]_golden_test.dart

### Implementation for User Story 3

- [ ] T030 [P] [US3] Create [Entity] model in lib/src/[area]/[entity].dart
- [ ] T031 [US3] Implement [Widget/API] in lib/src/[area]/[feature].dart
- [ ] T032 [US3] Update documentation and examples

**Checkpoint**: All user stories MUST now be independently functional

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] TXXX [P] Documentation updates in docs/
- [ ] TXXX Code cleanup and refactoring
- [ ] TXXX Performance optimization across all stories
- [ ] TXXX [P] Additional unit tests in test/
- [ ] TXXX [P] Run `dart format .` (dartfmt) and verify no formatting diff
- [ ] TXXX [P] Run `dart analyze` and verify zero issues
- [ ] TXXX [P] Run widget and golden test suites
- [ ] TXXX [P] Compile the example app and verify all six variants are demoed
- [ ] TXXX [P] Check pub.dev package quality impact for public API or docs changes
- [ ] TXXX Security hardening
- [ ] TXXX Run quickstart.md validation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but MUST remain independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but MUST remain independently testable

### Within Each User Story

- Widget tests and required golden tests MUST be written and FAIL before implementation
- Models, controllers, and support types before widgets
- Internal implementation before public exports
- Core implementation before example app integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together:
Task: "Widget test for [behavior] in test/[feature]_test.dart"
Task: "Golden test for [visual state] in test/goldens/[feature]_golden_test.dart"
Task: "Accessibility and keyboard navigation test in test/[feature]_a11y_test.dart"

# Launch all models or support types for User Story 1 together:
Task: "Create [Entity1] model in lib/src/[area]/[entity1].dart"
Task: "Create [Entity2] model in lib/src/[area]/[entity2].dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Demo in the example app if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Demo (MVP!)
3. Add User Story 2 → Test independently → Demo
4. Add User Story 3 → Test independently → Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story MUST be independently completable and testable
- Verify tests fail before implementing
- Keep public API changes semver-compatible unless the plan includes a breaking-change release path
- Preserve `DropifyTheme` / `DropifyThemeData` and the single import entry point
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
